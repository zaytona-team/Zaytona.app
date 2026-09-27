"""Integration tests for the lists namespace (US-13, US-14, US-15).

Routes follow the Internal API Table:
  POST   /groups/<group_id>/lists     (US-13)
  GET    /groups/<group_id>/lists
  GET    /lists/<list_id>
  PATCH  /lists/<list_id>             (US-14)
  PATCH  /lists/<list_id>/complete    (US-15)

Coverage:
  * US-13: any member can create a list
  * US-14: only admin can edit list name
  * US-15: any member can close out the current trip (idempotent); the
    list itself is a persistent container, reused trip after trip
  * Default group list cap (5 lists max)
  * Authorization guards (membership, admin role)
  * Validation (empty name, invalid UUID)
"""
import time
import uuid

import jwt
import pytest

from app import create_app
from app.config import Config
from app.extensions import db
from app.models.group import Group
from app.models.group_member import GroupMember
from app.models.list_item import ListItem
from app.models.shopping_list import ShoppingList
from app.models.user import User


class TestConfig(Config):
    TESTING = True
    SQLALCHEMY_DATABASE_URI = "sqlite:///:memory:"
    SQLALCHEMY_ENGINE_OPTIONS = {}


@pytest.fixture
def app():
    return create_app(TestConfig)


@pytest.fixture
def client(app):
    return app.test_client()


# ── Helpers ──────────────────────────────────────────────────


def _make_user(app, **overrides) -> str:
    """Insert a USER row and return its id."""
    suffix = uuid.uuid4().hex[:10]
    phone_suffix = str(uuid.uuid4().int)[:8]
    with app.app_context():
        user = User(
            first_name=overrides.get("first_name", "Test"),
            last_name=overrides.get("last_name", "User"),
            email=overrides.get("email", f"{suffix}@test.invalid"),
            phone=overrides.get("phone", f"+9665{phone_suffix}"),
        )
        db.session.add(user)
        db.session.commit()
        return user.user_id


def _make_group(app, created_by_user_id, name="Test Group", type_="household") -> str:
    """Insert a GROUP row and return its id."""
    with app.app_context():
        group = Group(
            name=name,
            created_by=created_by_user_id,
            invite_code=uuid.uuid4().hex[:6].upper(),
            type=type_,
        )
        db.session.add(group)
        db.session.commit()
        return group.group_id


def _add_member(app, group_id, user_id, role="member"):
    """Add a user to a group with the given role."""
    with app.app_context():
        member = GroupMember(group_id=group_id, user_id=user_id, role=role)
        db.session.add(member)
        db.session.commit()


def _token_for(app, user_id: str) -> str:
    """Mint a JWT for the given user."""
    now = int(time.time())
    payload = {"sub": str(user_id), "iat": now, "exp": now + 3600}
    with app.app_context():
        return jwt.encode(payload, app.config["SECRET_KEY"], algorithm="HS256")


def _auth(app, user_id: str) -> dict:
    return {"Authorization": f"Bearer {_token_for(app, user_id)}"}


def _make_list(app, group_id, created_by, name="Test List") -> str:
    """Insert a SHOPPING_LIST row and return its id."""
    with app.app_context():
        lst = ShoppingList(
            name=name, group_id=group_id, created_by=created_by, status="active"
        )
        db.session.add(lst)
        db.session.commit()
        return lst.list_id


def _make_item(app, list_id, added_by, name="Milk", is_bought=False, bought_by=None) -> str:
    """Insert a LIST_ITEM row and return its id."""
    with app.app_context():
        item = ListItem(
            list_id=list_id,
            name=name,
            added_by=added_by,
            is_bought=is_bought,
            bought_by=bought_by,
        )
        db.session.add(item)
        db.session.commit()
        return item.list_item_id


# ── US-13: Create list (nested under /groups/<id>/lists) ────


def test_create_list_requires_auth(client):
    resp = client.post("/api/v1/groups/some-group/lists", json={"name": "X"})
    assert resp.status_code == 401


def test_create_list_validates_payload(app, client):
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")

    resp = client.post(
        f"/api/v1/groups/{group_id}/lists",
        json={},
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 400


def test_create_list_requires_membership(app, client):
    """A user who is NOT a member of the group cannot create a list."""
    user_id = _make_user(app)
    other_user_id = _make_user(app)
    group_id = _make_group(app, other_user_id)
    # user_id is NOT added to the group

    resp = client.post(
        f"/api/v1/groups/{group_id}/lists",
        json={"name": "Weekly"},
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 403


def test_create_list_success_for_member(app, client):
    """US-13: any member (not just admin) can create a list."""
    admin_id = _make_user(app)
    member_id = _make_user(app)
    group_id = _make_group(app, admin_id)
    _add_member(app, group_id, admin_id, role="admin")
    _add_member(app, group_id, member_id, role="member")

    # Member (not admin) creates the list
    resp = client.post(
        f"/api/v1/groups/{group_id}/lists",
        json={"name": "Weekly Groceries"},
        headers=_auth(app, member_id),
    )
    assert resp.status_code == 201
    data = resp.get_json()
    assert data["name"] == "Weekly Groceries"
    assert data["group_id"] == group_id
    assert data["created_by"] == member_id
    assert data["status"] == "active"


def test_create_list_rejects_empty_name(app, client):
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")

    resp = client.post(
        f"/api/v1/groups/{group_id}/lists",
        json={"name": "   "},
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 400


def test_create_list_default_group_capped_at_5(app, client):
    """Default (individual) groups are capped at 5 lists.

    Per documentation: "Default group is capped at 5 lists"
    """
    user_id = _make_user(app)
    # Create a default (individual) group
    group_id = _make_group(app, user_id, type_="individual")
    _add_member(app, group_id, user_id, role="admin")

    # Create 5 lists — should all succeed
    for i in range(5):
        resp = client.post(
            f"/api/v1/groups/{group_id}/lists",
            json={"name": f"List {i+1}"},
            headers=_auth(app, user_id),
        )
        assert resp.status_code == 201

    # 6th list must fail with 409
    resp = client.post(
        f"/api/v1/groups/{group_id}/lists",
        json={"name": "List 6 — should fail"},
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 409


def test_create_list_shared_group_has_no_cap(app, client):
    """Shared (premium) groups can have more than 5 lists."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id, type_="household")
    _add_member(app, group_id, user_id, role="admin")

    # Create 6 lists — should all succeed for shared groups
    for i in range(6):
        resp = client.post(
            f"/api/v1/groups/{group_id}/lists",
            json={"name": f"List {i+1}"},
            headers=_auth(app, user_id),
        )
        assert resp.status_code == 201


# ── GET /groups/<group_id>/lists ─────────────────────────────


def test_list_lists_returns_only_group_lists(app, client):
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    _make_list(app, group_id, user_id, "List A")
    _make_list(app, group_id, user_id, "List B")

    resp = client.get(
        f"/api/v1/groups/{group_id}/lists",
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 200
    data = resp.get_json()
    assert len(data) == 2


def test_list_lists_filters_by_status(app, client):
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    _make_list(app, group_id, user_id, "Active One")

    with app.app_context():
        completed = ShoppingList(
            name="Done One",
            group_id=group_id,
            created_by=user_id,
            status="completed",
        )
        db.session.add(completed)
        db.session.commit()

    resp = client.get(
        f"/api/v1/groups/{group_id}/lists?status=active",
        headers=_auth(app, user_id),
    )
    data = resp.get_json()
    assert len(data) == 1
    assert data[0]["name"] == "Active One"


def test_list_lists_rejects_invalid_status(app, client):
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")

    resp = client.get(
        f"/api/v1/groups/{group_id}/lists?status=bogus",
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 400


# ── GET /lists/<id> ──────────────────────────────────────────


def test_get_list_success(app, client):
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id, "My List")

    resp = client.get(f"/api/v1/lists/{list_id}", headers=_auth(app, user_id))
    assert resp.status_code == 200
    assert resp.get_json()["name"] == "My List"


def test_get_list_403_for_non_member(app, client):
    owner_id = _make_user(app)
    outsider_id = _make_user(app)
    group_id = _make_group(app, owner_id)
    _add_member(app, group_id, owner_id, role="admin")
    list_id = _make_list(app, group_id, owner_id)

    resp = client.get(f"/api/v1/lists/{list_id}", headers=_auth(app, outsider_id))
    assert resp.status_code == 403


def test_get_list_404_for_invalid_uuid(app, client):
    user_id = _make_user(app)
    resp = client.get("/api/v1/lists/not-a-uuid", headers=_auth(app, user_id))
    assert resp.status_code == 404


# ── US-14: Admin edits list name ─────────────────────────────


def test_update_list_requires_admin(app, client):
    admin_id = _make_user(app)
    member_id = _make_user(app)
    group_id = _make_group(app, admin_id)
    _add_member(app, group_id, admin_id, role="admin")
    _add_member(app, group_id, member_id, role="member")
    list_id = _make_list(app, group_id, admin_id)

    resp = client.patch(
        f"/api/v1/lists/{list_id}",
        json={"name": "Hijacked"},
        headers=_auth(app, member_id),
    )
    assert resp.status_code == 403


def test_update_list_success_for_admin(app, client):
    admin_id = _make_user(app)
    group_id = _make_group(app, admin_id)
    _add_member(app, group_id, admin_id, role="admin")
    list_id = _make_list(app, group_id, admin_id, "Original")

    resp = client.patch(
        f"/api/v1/lists/{list_id}",
        json={"name": "Renamed"},
        headers=_auth(app, admin_id),
    )
    assert resp.status_code == 200
    assert resp.get_json()["name"] == "Renamed"


def test_update_list_rejects_empty_name(app, client):
    admin_id = _make_user(app)
    group_id = _make_group(app, admin_id)
    _add_member(app, group_id, admin_id, role="admin")
    list_id = _make_list(app, group_id, admin_id)

    resp = client.patch(
        f"/api/v1/lists/{list_id}",
        json={"name": "   "},
        headers=_auth(app, admin_id),
    )
    assert resp.status_code == 400


# ── US-15: Any member closes the list ────────────────────────


def test_complete_list_by_member(app, client):
    """US-15: any member (not just admin) can close out the current trip.
    The list itself stays 'active' — closing a trip attributes whatever
    was bought to a completed Trip, it doesn't touch the list."""
    admin_id = _make_user(app)
    buyer_id = _make_user(app)
    group_id = _make_group(app, admin_id)
    _add_member(app, group_id, admin_id, role="admin")
    _add_member(app, group_id, buyer_id, role="member")
    list_id = _make_list(app, group_id, admin_id)
    _make_item(app, list_id, admin_id, name="Milk", is_bought=True, bought_by=buyer_id)

    resp = client.patch(
        f"/api/v1/lists/{list_id}/complete",
        headers=_auth(app, buyer_id),
    )
    assert resp.status_code == 200
    data = resp.get_json()
    assert data["status"] == "active"

    trips = client.get(
        f"/api/v1/lists/{list_id}/trips", headers=_auth(app, buyer_id)
    ).get_json()
    assert len(trips) == 1
    assert trips[0]["buyer_id"] == buyer_id
    assert [i["name"] for i in trips[0]["items"]] == ["Milk"]


def test_complete_list_is_idempotent(app, client):
    """Calling complete again with nothing new bought doesn't create a
    second trip."""
    admin_id = _make_user(app)
    group_id = _make_group(app, admin_id)
    _add_member(app, group_id, admin_id, role="admin")
    list_id = _make_list(app, group_id, admin_id)
    _make_item(app, list_id, admin_id, is_bought=True, bought_by=admin_id)

    client.patch(f"/api/v1/lists/{list_id}/complete", headers=_auth(app, admin_id))
    resp = client.patch(
        f"/api/v1/lists/{list_id}/complete", headers=_auth(app, admin_id)
    )
    assert resp.status_code == 200

    trips = client.get(
        f"/api/v1/lists/{list_id}/trips", headers=_auth(app, admin_id)
    ).get_json()
    assert len(trips) == 1


def test_complete_list_noop_when_nothing_bought(app, client):
    """Closing a list with nothing bought and no trip in progress creates
    no trip at all — there's nothing to record."""
    admin_id = _make_user(app)
    group_id = _make_group(app, admin_id)
    _add_member(app, group_id, admin_id, role="admin")
    list_id = _make_list(app, group_id, admin_id)

    resp = client.patch(
        f"/api/v1/lists/{list_id}/complete", headers=_auth(app, admin_id)
    )
    assert resp.status_code == 200

    trips = client.get(
        f"/api/v1/lists/{list_id}/trips", headers=_auth(app, admin_id)
    ).get_json()
    assert trips == []


def test_complete_list_reused_across_trips_scopes_items_correctly(app, client):
    """The core guarantee of the persistent-list model: the same list
    used for two separate trips must not leak one trip's bought items
    into the other's history entry, and unbought items are left alone
    (no rollover to a new list) as the list's own current state."""
    admin_id = _make_user(app)
    group_id = _make_group(app, admin_id)
    _add_member(app, group_id, admin_id, role="admin")
    list_id = _make_list(app, group_id, admin_id)

    _make_item(app, list_id, admin_id, name="Milk", is_bought=True, bought_by=admin_id)
    client.patch(f"/api/v1/lists/{list_id}/complete", headers=_auth(app, admin_id))

    _make_item(app, list_id, admin_id, name="Eggs", is_bought=True, bought_by=admin_id)
    _make_item(app, list_id, admin_id, name="Bread", is_bought=False)
    client.patch(f"/api/v1/lists/{list_id}/complete", headers=_auth(app, admin_id))

    trips = client.get(
        f"/api/v1/lists/{list_id}/trips", headers=_auth(app, admin_id)
    ).get_json()
    assert len(trips) == 2
    assert {trip["items"][0]["name"] for trip in trips} == {"Milk", "Eggs"}
    for trip in trips:
        assert trip["item_count"] == 1

    # The current-list view (GET .../items) intentionally excludes items
    # already claimed by a completed trip — they live under trip history
    # instead (asserted above), not here (see ItemRepository.list_by_list_id).
    # Only "Bread", never claimed by any trip, is still the list's own state.
    items = client.get(
        f"/api/v1/lists/{list_id}/items", headers=_auth(app, admin_id)
    ).get_json()
    assert {i["name"] for i in items} == {"Bread"}


def test_complete_list_403_for_non_member(app, client):
    owner_id = _make_user(app)
    outsider_id = _make_user(app)
    group_id = _make_group(app, owner_id)
    _add_member(app, group_id, owner_id, role="admin")
    list_id = _make_list(app, group_id, owner_id)

    resp = client.patch(
        f"/api/v1/lists/{list_id}/complete", headers=_auth(app, outsider_id)
    )
    assert resp.status_code == 403