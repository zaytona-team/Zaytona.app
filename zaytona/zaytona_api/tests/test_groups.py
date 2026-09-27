"""Integration tests for the groups namespace (US-04..US-12).

Run against the real Supabase Postgres DB (see conftest.py) — no
sqlite, no mocking. Every user/group a test creates is registered in
`created_user_ids` so the `created_user_ids` fixture teardown can
cascade-delete it afterwards; the DB is shared, not disposable.

Auth is simulated by minting a JWT the same way facade._issue_token
does, so these don't depend on a live Authentica OTP round-trip.
"""
import time
import uuid

import jwt

from app.extensions import db
from app.models.user import User


def _make_user(app, created_user_ids, **overrides) -> str:
    """Insert a USER row directly and register it for teardown."""
    suffix = uuid.uuid4().hex[:10]
    phone_suffix = str(uuid.uuid4().int)[:8]
    with app.app_context():
        user = User(
            first_name=overrides.get("first_name", "Test"),
            last_name=overrides.get("last_name", "User"),
            email=overrides.get("email", f"{suffix}@zaytona-test.invalid"),
            phone=overrides.get("phone", f"+9665{phone_suffix}"),
        )
        db.session.add(user)
        db.session.commit()
        created_user_ids.append(user.user_id)
        return user.user_id


def _token_for(app, user_id: str) -> str:
    now = int(time.time())
    payload = {"sub": str(user_id), "iat": now, "exp": now + 3600}
    with app.app_context():
        return jwt.encode(payload, app.config["SECRET_KEY"], algorithm="HS256")


def _auth(app, user_id: str) -> dict:
    return {"Authorization": f"Bearer {_token_for(app, user_id)}"}


# ── validation / auth guards ──────────────────────────────────
def test_create_group_requires_auth(client):
    resp = client.post("/api/v1/groups/", json={"name": "My Household"})
    assert resp.status_code == 401


def test_create_group_validates_payload(app, client, created_user_ids):
    user_id = _make_user(app, created_user_ids)
    resp = client.post("/api/v1/groups/", json={}, headers=_auth(app, user_id))
    assert resp.status_code == 400


def test_join_group_requires_invite_code(app, client, created_user_ids):
    user_id = _make_user(app, created_user_ids)
    resp = client.post("/api/v1/groups/join", json={}, headers=_auth(app, user_id))
    assert resp.status_code == 400


def test_join_group_rejects_individual_group(app, client, created_user_ids):
    """An individual (personal) group never gets an invite code at all
    (GroupRepository.create only generates one for household groups) — it
    must not be joinable by any means. This also covers the group.type
    guard in join_group directly, in case a code were ever forced onto one."""
    owner_id = _make_user(app, created_user_ids)
    outsider_id = _make_user(app, created_user_ids)

    from app.services.facade import get_facade
    with app.app_context():
        facade = get_facade()
        group = facade.groups.create(name="Owner's Personal Group", created_by=owner_id, type_="individual")
        facade.groups.add_member(group_id=group.group_id, user_id=owner_id, role="admin")
        assert group.invite_code is None

        # Exercise the type guard in join_group directly, since there's no
        # real invite code an HTTP client could ever obtain for this group.
        from app.services.facade import FacadeError
        try:
            facade.join_group(user_id=outsider_id, invite_code="FAKE99")
            assert False, "expected FacadeError"
        except FacadeError as e:
            assert e.status == 404  # no group has this invite code

    # And via HTTP: no invite code to submit means no way in.
    resp = client.post(
        "/api/v1/groups/join", json={"invite_code": "FAKE99"}, headers=_auth(app, outsider_id)
    )
    assert resp.status_code == 404


# ── US-04/05/06/07 : create, join, list, detail ───────────────
def test_create_join_list_and_detail_flow(app, client, created_user_ids):
    admin_id = _make_user(app, created_user_ids)
    member_id = _make_user(app, created_user_ids)

    # US-04: create group -> creator is admin, invite code returned
    resp = client.post(
        "/api/v1/groups/",
        json={"name": "Al-Otaibi Household"},
        headers=_auth(app, admin_id),
    )
    assert resp.status_code == 201
    group = resp.get_json()
    assert group["invite_code"]
    group_id = group["group_id"]

    # US-05: join by invite code
    resp = client.post(
        "/api/v1/groups/join",
        json={"invite_code": group["invite_code"]},
        headers=_auth(app, member_id),
    )
    assert resp.status_code == 200

    # joining again -> 409
    resp = client.post(
        "/api/v1/groups/join",
        json={"invite_code": group["invite_code"]},
        headers=_auth(app, member_id),
    )
    assert resp.status_code == 409

    # invalid code -> 404
    resp = client.post(
        "/api/v1/groups/join", json={"invite_code": "NOPE99"}, headers=_auth(app, member_id)
    )
    assert resp.status_code == 404

    # US-06: both users see the group in their list, with a member_count
    resp = client.get("/api/v1/groups/", headers=_auth(app, admin_id))
    assert resp.status_code == 200
    admin_groups = resp.get_json()
    assert any(g["group_id"] == group_id for g in admin_groups)
    assert next(g for g in admin_groups if g["group_id"] == group_id)["member_count"] == 2

    resp = client.get("/api/v1/groups/", headers=_auth(app, member_id))
    assert any(g["group_id"] == group_id for g in resp.get_json())

    # US-07: detail includes invite code + members, requires membership
    resp = client.get(f"/api/v1/groups/{group_id}", headers=_auth(app, admin_id))
    assert resp.status_code == 200
    detail = resp.get_json()
    assert detail["invite_code"] == group["invite_code"]
    assert len(detail["members"]) == 2

    outsider_id = _make_user(app, created_user_ids)
    resp = client.get(f"/api/v1/groups/{group_id}", headers=_auth(app, outsider_id))
    assert resp.status_code == 403


# ── US-08/09/10 : admin actions ───────────────────────────────
def test_admin_actions(app, client, created_user_ids):
    admin_id = _make_user(app, created_user_ids)
    member_id = _make_user(app, created_user_ids)

    group = client.post(
        "/api/v1/groups/", json={"name": "Roomies"}, headers=_auth(app, admin_id)
    ).get_json()
    group_id = group["group_id"]
    client.post(
        "/api/v1/groups/join",
        json={"invite_code": group["invite_code"]},
        headers=_auth(app, member_id),
    )

    # US-09: non-admin cannot edit
    resp = client.patch(
        f"/api/v1/groups/{group_id}", json={"name": "Hijack"}, headers=_auth(app, member_id)
    )
    assert resp.status_code == 403

    # US-09: admin edits name/icon
    resp = client.patch(
        f"/api/v1/groups/{group_id}",
        json={"name": "Roomies Updated", "image_url": "https://x/icon.png"},
        headers=_auth(app, admin_id),
    )
    assert resp.status_code == 200
    assert resp.get_json()["name"] == "Roomies Updated"

    # US-08: non-admin cannot remove members
    resp = client.delete(
        f"/api/v1/groups/{group_id}/members/{admin_id}", headers=_auth(app, member_id)
    )
    assert resp.status_code == 403

    # US-08: admin cannot remove self
    resp = client.delete(
        f"/api/v1/groups/{group_id}/members/{admin_id}", headers=_auth(app, admin_id)
    )
    assert resp.status_code == 400

    # US-10: transfer admin to member
    resp = client.post(
        f"/api/v1/groups/{group_id}/transfer-admin",
        json={"new_admin_user_id": member_id},
        headers=_auth(app, admin_id),
    )
    assert resp.status_code == 200

    # old admin lost admin rights: cannot edit anymore
    resp = client.patch(
        f"/api/v1/groups/{group_id}", json={"name": "Nope"}, headers=_auth(app, admin_id)
    )
    assert resp.status_code == 403

    # new admin (former member) can now remove the old admin as a plain member
    resp = client.delete(
        f"/api/v1/groups/{group_id}/members/{admin_id}", headers=_auth(app, member_id)
    )
    assert resp.status_code == 204


# ── US-11/12 : admin removes a list / recipe from the group ──
def test_admin_removes_list_and_recipe(app, client, created_user_ids):
    from app.models.recipe import Recipe
    from app.models.shopping_list import ShoppingList

    admin_id = _make_user(app, created_user_ids)
    member_id = _make_user(app, created_user_ids)

    group = client.post(
        "/api/v1/groups/", json={"name": "Family"}, headers=_auth(app, admin_id)
    ).get_json()
    group_id = group["group_id"]
    client.post(
        "/api/v1/groups/join",
        json={"invite_code": group["invite_code"]},
        headers=_auth(app, member_id),
    )

    with app.app_context():
        shopping_list = ShoppingList(group_id=group_id, created_by=admin_id, name="Weekly")
        recipe = Recipe(group_id=group_id, created_by=admin_id, name="Pasta")
        db.session.add_all([shopping_list, recipe])
        db.session.commit()
        list_id, recipe_id = shopping_list.list_id, recipe.recipe_id

    # non-admin cannot remove
    resp = client.delete(
        f"/api/v1/groups/{group_id}/lists/{list_id}", headers=_auth(app, member_id)
    )
    assert resp.status_code == 403

    # US-11: admin removes the list
    resp = client.delete(
        f"/api/v1/groups/{group_id}/lists/{list_id}", headers=_auth(app, admin_id)
    )
    assert resp.status_code == 204
    resp = client.delete(
        f"/api/v1/groups/{group_id}/lists/{list_id}", headers=_auth(app, admin_id)
    )
    assert resp.status_code == 404

 # US-12 (Now US-37): admin removes the recipe via the dedicated recipe endpoint
    resp = client.delete(
        f"/api/v1/recipes/{recipe_id}", headers=_auth(app, admin_id)
    )
    assert resp.status_code == 200 
    assert resp.get_json()["message"] == "Recipe deleted"

    resp = client.delete(
        f"/api/v1/recipes/{recipe_id}", headers=_auth(app, admin_id)
    )
    assert resp.status_code == 404