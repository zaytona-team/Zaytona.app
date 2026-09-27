"""Integration tests for the histories namespace (LIST_ACTION activity log).

Endpoint tested:
  GET /api/v1/lists/<list_id>/history

Coverage:
  * Auth required (401)
  * Membership required (403)
  * 404 for a missing/invalid list
  * create/update/purchase/delete on items each write a history entry
  * deleted entries keep a name snapshot in metadata (list_item_id is gone)
  * newest-first ordering
  * ?list_item_id= filters to one item's history
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


# ── Helpers (mirrors tests/test_items.py) ──────────────────────


def _make_user(app, **overrides) -> str:
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
    with app.app_context():
        member = GroupMember(group_id=group_id, user_id=user_id, role=role)
        db.session.add(member)
        db.session.commit()


def _token_for(app, user_id: str) -> str:
    now = int(time.time())
    payload = {"sub": str(user_id), "iat": now, "exp": now + 3600}
    with app.app_context():
        return jwt.encode(payload, app.config["SECRET_KEY"], algorithm="HS256")


def _auth(app, user_id: str) -> dict:
    return {"Authorization": f"Bearer {_token_for(app, user_id)}"}


def _make_list(app, group_id, created_by, name="Test List") -> str:
    with app.app_context():
        lst = ShoppingList(name=name, group_id=group_id, created_by=created_by, status="active")
        db.session.add(lst)
        db.session.commit()
        return lst.list_id


# ══════════════════════════════════════════════════════════════
# GET /lists/<list_id>/history
# ══════════════════════════════════════════════════════════════


def test_history_requires_auth(client):
    resp = client.get("/api/v1/lists/some-list-id/history")
    assert resp.status_code == 401


def test_history_requires_membership(app, client):
    owner_id = _make_user(app)
    outsider_id = _make_user(app)
    group_id = _make_group(app, owner_id)
    _add_member(app, group_id, owner_id, role="admin")
    list_id = _make_list(app, group_id, owner_id)

    resp = client.get(f"/api/v1/lists/{list_id}/history", headers=_auth(app, outsider_id))
    assert resp.status_code == 403


def test_history_404_for_missing_list(app, client):
    user_id = _make_user(app)
    resp = client.get(
        f"/api/v1/lists/{uuid.uuid4()}/history", headers=_auth(app, user_id)
    )
    assert resp.status_code == 404


def test_history_empty_for_new_list(app, client):
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)

    resp = client.get(f"/api/v1/lists/{list_id}/history", headers=_auth(app, user_id))
    assert resp.status_code == 200
    assert resp.get_json() == []


def test_add_item_writes_created_entry(app, client):
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)

    resp = client.post(
        f"/api/v1/lists/{list_id}/items",
        json={"name": "Milk", "quantity": 2, "unit": "L"},
        headers=_auth(app, user_id),
    )
    item_id = resp.get_json()["list_item_id"]

    hist = client.get(f"/api/v1/lists/{list_id}/history", headers=_auth(app, user_id)).get_json()
    assert len(hist) == 1
    assert hist[0]["action"] == "created"
    assert hist[0]["list_item_id"] == item_id
    assert hist[0]["user_id"] == user_id


def test_full_item_lifecycle_writes_ordered_history(app, client):
    """created -> updated -> consumed -> deleted, newest first."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)

    item_id = client.post(
        f"/api/v1/lists/{list_id}/items",
        json={"name": "Eggs", "quantity": 1, "unit": "pcs"},
        headers=_auth(app, user_id),
    ).get_json()["list_item_id"]

    client.patch(
        f"/api/v1/lists/{list_id}/items/{item_id}",
        json={"quantity": 12},
        headers=_auth(app, user_id),
    )
    client.patch(
        f"/api/v1/lists/{list_id}/items/{item_id}/purchase", headers=_auth(app, user_id)
    )
    client.delete(f"/api/v1/lists/{list_id}/items/{item_id}", headers=_auth(app, user_id))

    hist = client.get(f"/api/v1/lists/{list_id}/history", headers=_auth(app, user_id)).get_json()
    actions = [h["action"] for h in hist]
    assert actions == ["deleted", "consumed", "updated", "created"]

    # Deleted entry: item is gone, so list_item_id is None but the name
    # travels in metadata instead (see facade.delete_list_item).
    deleted_entry = hist[0]
    assert deleted_entry["list_item_id"] is None
    assert deleted_entry["metadata"]["name"] == "Eggs"

    # Earlier entries still carry the real item id.
    assert hist[1]["list_item_id"] == item_id
    assert hist[2]["list_item_id"] == item_id
    # update_list_item's history metadata always includes the item's
    # current name alongside whatever fields actually changed (see
    # ItemFacadeMixin.update_list_item), not just the changed fields.
    assert hist[2]["metadata"] == {"quantity": 12.0, "name": "Eggs"}


def test_bulk_delete_writes_one_combined_entry(app, client):
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)

    for name in ("Bread", "Butter"):
        client.post(
            f"/api/v1/lists/{list_id}/items",
            json={"name": name},
            headers=_auth(app, user_id),
        )

    client.delete(f"/api/v1/lists/{list_id}/items", headers=_auth(app, user_id))

    hist = client.get(f"/api/v1/lists/{list_id}/history", headers=_auth(app, user_id)).get_json()
    deleted_entries = [h for h in hist if h["action"] == "deleted"]
    assert len(deleted_entries) == 1
    entry = deleted_entries[0]
    assert entry["metadata"]["count"] == 2
    assert sorted(i["name"] for i in entry["metadata"]["items"]) == ["Bread", "Butter"]


def test_history_filters_by_list_item_id(app, client):
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)

    item_a = client.post(
        f"/api/v1/lists/{list_id}/items", json={"name": "A"}, headers=_auth(app, user_id)
    ).get_json()["list_item_id"]
    client.post(
        f"/api/v1/lists/{list_id}/items", json={"name": "B"}, headers=_auth(app, user_id)
    )

    hist = client.get(
        f"/api/v1/lists/{list_id}/history?list_item_id={item_a}", headers=_auth(app, user_id)
    ).get_json()
    assert len(hist) == 1
    assert hist[0]["list_item_id"] == item_a
