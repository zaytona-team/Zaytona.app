"""Integration tests for the users namespace.

Endpoint tested:
  GET /users/me/items   Distinct items this user has personally added,
                         across all their groups, most recently used
                         first (US: "my items" quick-add catalog).
"""
import time
import uuid
from datetime import datetime, timedelta, timezone

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


def _make_user(app) -> str:
    suffix = uuid.uuid4().hex[:10]
    phone_suffix = str(uuid.uuid4().int)[:8]
    with app.app_context():
        user = User(
            first_name="Test", last_name="User",
            email=f"{suffix}@test.invalid", phone=f"+9665{phone_suffix}",
        )
        db.session.add(user)
        db.session.commit()
        return user.user_id


def _make_group(app, created_by, name="Test Group") -> str:
    with app.app_context():
        group = Group(
            name=name, created_by=created_by,
            invite_code=uuid.uuid4().hex[:6].upper(), type="household",
        )
        db.session.add(group)
        db.session.commit()
        return group.group_id


def _add_member(app, group_id, user_id, role="member"):
    with app.app_context():
        db.session.add(GroupMember(group_id=group_id, user_id=user_id, role=role))
        db.session.commit()


def _make_list(app, group_id, created_by) -> str:
    with app.app_context():
        lst = ShoppingList(name="Test List", group_id=group_id, created_by=created_by, status="active")
        db.session.add(lst)
        db.session.commit()
        return lst.list_id


def _make_list_item(app, list_id, added_by, *, name, category_id=None, brand=None,
                     image_url=None, created_at=None) -> str:
    with app.app_context():
        item = ListItem(
            list_id=list_id, added_by=added_by, name=name,
            category_id=category_id, brand=brand, image_url=image_url,
        )
        db.session.add(item)
        db.session.commit()
        # created_at has a server-ish default set on insert — override it
        # after the fact so tests can control ordering deterministically.
        if created_at is not None:
            item.created_at = created_at
            db.session.commit()
        return item.list_item_id


def _token_for(app, user_id: str) -> str:
    now = int(time.time())
    payload = {"sub": str(user_id), "iat": now, "exp": now + 3600}
    with app.app_context():
        return jwt.encode(payload, app.config["SECRET_KEY"], algorithm="HS256")


def _auth(app, user_id: str) -> dict:
    return {"Authorization": f"Bearer {_token_for(app, user_id)}"}


# ══════════════════════════════════════════════════════════════
# GET /users/me/items
# ══════════════════════════════════════════════════════════════


def test_my_items_requires_auth(client):
    resp = client.get("/api/v1/users/me/items")
    assert resp.status_code == 401


def test_my_items_empty_for_new_user(app, client):
    user_id = _make_user(app)
    resp = client.get("/api/v1/users/me/items", headers=_auth(app, user_id))
    assert resp.status_code == 200
    assert resp.get_json() == []


def test_my_items_only_returns_items_this_user_added(app, client):
    """Items other members added to a shared list must not appear."""
    me_id = _make_user(app)
    other_id = _make_user(app)
    group_id = _make_group(app, me_id)
    _add_member(app, group_id, me_id, role="admin")
    _add_member(app, group_id, other_id, role="member")
    list_id = _make_list(app, group_id, me_id)

    _make_list_item(app, list_id, me_id, name="Milk")
    _make_list_item(app, list_id, other_id, name="Bread")

    resp = client.get("/api/v1/users/me/items", headers=_auth(app, me_id))
    assert resp.status_code == 200
    names = [row["name"] for row in resp.get_json()]
    assert names == ["Milk"]


def test_my_items_spans_multiple_groups(app, client):
    """Items added in any of the user's groups all show up here."""
    me_id = _make_user(app)
    group_a = _make_group(app, me_id, name="Group A")
    group_b = _make_group(app, me_id, name="Group B")
    _add_member(app, group_a, me_id, role="admin")
    _add_member(app, group_b, me_id, role="admin")
    list_a = _make_list(app, group_a, me_id)
    list_b = _make_list(app, group_b, me_id)

    _make_list_item(app, list_a, me_id, name="Milk")
    _make_list_item(app, list_b, me_id, name="Eggs")

    resp = client.get("/api/v1/users/me/items", headers=_auth(app, me_id))
    names = {row["name"] for row in resp.get_json()}
    assert names == {"Milk", "Eggs"}


def test_my_items_dedupes_case_insensitively_keeping_most_recent(app, client):
    """Adding "Milk" then "milk" collapses to one entry — the more
    recent add's data wins, matching check_duplicate_active's same-item
    rule elsewhere in the codebase."""
    me_id = _make_user(app)
    group_id = _make_group(app, me_id)
    _add_member(app, group_id, me_id, role="admin")
    list_id = _make_list(app, group_id, me_id)

    now = datetime.now(timezone.utc)
    _make_list_item(
        app, list_id, me_id, name="Milk", brand="Almarai",
        created_at=now - timedelta(days=2),
    )
    _make_list_item(
        app, list_id, me_id, name="milk", brand="Nadec",
        created_at=now,
    )

    resp = client.get("/api/v1/users/me/items", headers=_auth(app, me_id))
    data = resp.get_json()
    assert len(data) == 1
    assert data[0]["brand"] == "Nadec"  # the more recent of the two


def test_my_items_most_recently_used_first(app, client):
    me_id = _make_user(app)
    group_id = _make_group(app, me_id)
    _add_member(app, group_id, me_id, role="admin")
    list_id = _make_list(app, group_id, me_id)

    now = datetime.now(timezone.utc)
    _make_list_item(app, list_id, me_id, name="Flour", created_at=now - timedelta(days=5))
    _make_list_item(app, list_id, me_id, name="Sugar", created_at=now - timedelta(days=1))
    _make_list_item(app, list_id, me_id, name="Salt", created_at=now - timedelta(days=3))

    resp = client.get("/api/v1/users/me/items", headers=_auth(app, me_id))
    names = [row["name"] for row in resp.get_json()]
    assert names == ["Sugar", "Salt", "Flour"]


def test_my_items_response_shape(app, client):
    """Per the spec: name, category_id, brand, image_url, last-used timestamp."""
    me_id = _make_user(app)
    group_id = _make_group(app, me_id)
    _add_member(app, group_id, me_id, role="admin")
    list_id = _make_list(app, group_id, me_id)
    _make_list_item(
        app, list_id, me_id, name="Milk", brand="Almarai",
        image_url="https://cdn.test/milk.jpg",
    )

    resp = client.get("/api/v1/users/me/items", headers=_auth(app, me_id))
    row = resp.get_json()[0]
    assert set(row.keys()) == {"name", "category_id", "brand", "image_url", "last_used_at"}
    assert row["name"] == "Milk"
    assert row["brand"] == "Almarai"
    assert row["image_url"] == "https://cdn.test/milk.jpg"
    assert row["last_used_at"] is not None
