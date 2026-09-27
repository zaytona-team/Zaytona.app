"""Integration tests for the items namespace (US-16, US-21, US-22, US-23, US-25, US-26).

Endpoints tested (all nested under /lists/<list_id>/items):
  POST   /                                Add item (US-16, US-21, US-22)
  GET    /                                List items with optional filter
  PATCH  /<item_id>                       Update item
  DELETE /<item_id>                       Delete single item
  DELETE /                                Bulk delete all items (US-23)
  PATCH  /<item_id>/purchase              Mark as bought (US-26)

Coverage:
  * US-16: Manual addition with validation (name, quantity, unit)
  * US-21: Image URL support
  * US-22: Urgent flag
  * US-23: Bulk delete
  * US-25: Duplicate warning (non-blocking, 209 status)
  * US-26: Mark as purchased with buyer tracking
  * Authorization guards (membership required)
  * Validation (empty name, quantity <= 0, invalid unit)
"""
import io
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
from app.services.providers.supabase_storage_provider import SupabaseStorageProvider


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


def _make_list_item(app, list_id, added_by, name="Test Item", quantity=1.0, unit="pcs",
                    is_urgent=False, is_bought=False) -> str:
    """Insert a LIST_ITEM row and return its id."""
    with app.app_context():
        item = ListItem(
            list_id=list_id,
            added_by=added_by,
            name=name,
            quantity=quantity,
            unit=unit,
            is_urgent=is_urgent,
            is_bought=is_bought,
        )
        db.session.add(item)
        db.session.commit()
        return item.list_item_id


# ══════════════════════════════════════════════════════════════
# POST /lists/<list_id>/items — Add item (US-16, US-21, US-22, US-25)
# ══════════════════════════════════════════════════════════════


def test_add_item_requires_auth(client):
    """Unauthenticated request must return 401."""
    resp = client.post(
        "/api/v1/lists/some-list-id/items",
        json={"name": "Milk"},
    )
    assert resp.status_code == 401


def test_add_item_requires_membership(app, client):
    """User who is NOT a member of the group cannot add items."""
    owner_id = _make_user(app)
    outsider_id = _make_user(app)
    group_id = _make_group(app, owner_id)
    _add_member(app, group_id, owner_id, role="admin")
    list_id = _make_list(app, group_id, owner_id)

    resp = client.post(
        f"/api/v1/lists/{list_id}/items",
        json={"name": "Milk"},
        headers=_auth(app, outsider_id),
    )
    assert resp.status_code == 403


def test_add_item_requires_name(app, client):
    """Item name is required (400 if missing)."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)

    resp = client.post(
        f"/api/v1/lists/{list_id}/items",
        json={"quantity": 2},
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 400


def test_add_item_rejects_empty_name(app, client):
    """Whitespace-only name must be rejected (400)."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)

    resp = client.post(
        f"/api/v1/lists/{list_id}/items",
        json={"name": "   "},
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 400


def test_add_item_rejects_zero_quantity(app, client):
    """Quantity must be > 0 (400)."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)

    resp = client.post(
        f"/api/v1/lists/{list_id}/items",
        json={"name": "Milk", "quantity": 0},
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 400


def test_add_item_rejects_negative_quantity(app, client):
    """Negative quantity must be rejected (400)."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)

    resp = client.post(
        f"/api/v1/lists/{list_id}/items",
        json={"name": "Milk", "quantity": -1},
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 400


def test_add_item_rejects_invalid_unit(app, client):
    """Unit must be one of ALLOWED_UNITS (400)."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)

    resp = client.post(
        f"/api/v1/lists/{list_id}/items",
        json={"name": "Milk", "unit": "gallon"},
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 400


def test_add_item_success(app, client):
    """US-16: Successful item creation returns 201."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)

    resp = client.post(
        f"/api/v1/lists/{list_id}/items",
        json={
            "name": "Milk",
            "quantity": 2.0,
            "unit": "L",
            "notes": "Full fat",
            "is_urgent": False,
        },
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 201
    data = resp.get_json()
    assert data["name"] == "Milk"
    assert data["quantity"] == 2.0
    assert data["unit"] == "L"
    assert data["notes"] == "Full fat"
    assert data["is_urgent"] is False
    assert data["is_bought"] is False
    assert data["added_by"] == user_id
    assert data["list_id"] == list_id
    assert data["is_duplicate_warning"] is False


def test_add_item_with_urgent_flag(app, client):
    """US-22: Urgent flag is preserved."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)

    resp = client.post(
        f"/api/v1/lists/{list_id}/items",
        json={"name": "Bread", "is_urgent": True},
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 201
    assert resp.get_json()["is_urgent"] is True


def test_add_item_with_image_url(app, client):
    """US-21: Image URL is preserved."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)

    resp = client.post(
        f"/api/v1/lists/{list_id}/items",
        json={
            "name": "Milk",
            "image_url": "https://example.com/milk.png",
        },
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 201
    assert resp.get_json()["image_url"] == "https://example.com/milk.png"


def test_add_item_duplicate_warning(app, client):
    """US-25: Adding duplicate name returns 209 with warning flag."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)

    # First addition — success
    resp1 = client.post(
        f"/api/v1/lists/{list_id}/items",
        json={"name": "Milk"},
        headers=_auth(app, user_id),
    )
    assert resp1.status_code == 201
    assert resp1.get_json()["is_duplicate_warning"] is False

    # Second addition with same name — duplicate warning
    resp2 = client.post(
        f"/api/v1/lists/{list_id}/items",
        json={"name": "milk"},  # case-insensitive
        headers=_auth(app, user_id),
    )
    assert resp2.status_code == 209
    assert resp2.get_json()["is_duplicate_warning"] is True


def test_add_item_no_duplicate_warning_for_bought(app, client):
    """US-25: Bought items don't trigger duplicate warning."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)

    # Add and mark as bought
    item_id = _make_list_item(app, list_id, user_id, name="Milk", is_bought=True)

    # Add same name — should NOT trigger warning (bought items are ignored)
    resp = client.post(
        f"/api/v1/lists/{list_id}/items",
        json={"name": "Milk"},
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 201
    assert resp.get_json()["is_duplicate_warning"] is False


def test_add_item_uses_default_unit_and_quantity(app, client):
    """If quantity/unit are omitted, defaults (1.0, 'pcs') are used."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)

    resp = client.post(
        f"/api/v1/lists/{list_id}/items",
        json={"name": "Bread"},
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 201
    data = resp.get_json()
    assert data["quantity"] == 1.0
    assert data["unit"] == "pcs"


# ══════════════════════════════════════════════════════════════
# GET /lists/<list_id>/items — List items
# ══════════════════════════════════════════════════════════════


def test_get_items_requires_auth(client):
    """Unauthenticated request must return 401."""
    resp = client.get("/api/v1/lists/some-list-id/items")
    assert resp.status_code == 401


def test_get_items_requires_membership(app, client):
    """Non-members cannot view items."""
    owner_id = _make_user(app)
    outsider_id = _make_user(app)
    group_id = _make_group(app, owner_id)
    _add_member(app, group_id, owner_id, role="admin")
    list_id = _make_list(app, group_id, owner_id)

    resp = client.get(
        f"/api/v1/lists/{list_id}/items",
        headers=_auth(app, outsider_id),
    )
    assert resp.status_code == 403


def test_get_items_returns_all(app, client):
    """GET returns all items in the list."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)
    _make_list_item(app, list_id, user_id, name="Milk")
    _make_list_item(app, list_id, user_id, name="Bread")

    resp = client.get(
        f"/api/v1/lists/{list_id}/items",
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 200
    data = resp.get_json()
    assert len(data) == 2
    names = {item["name"] for item in data}
    assert names == {"Milk", "Bread"}


def test_get_items_filters_by_is_bought_true(app, client):
    """Filter by is_bought=true returns only bought items."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)
    _make_list_item(app, list_id, user_id, name="Milk", is_bought=False)
    _make_list_item(app, list_id, user_id, name="Bread", is_bought=True)

    resp = client.get(
        f"/api/v1/lists/{list_id}/items?is_bought=true",
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 200
    data = resp.get_json()
    assert len(data) == 1
    assert data[0]["name"] == "Bread"


def test_get_items_filters_by_is_bought_false(app, client):
    """Filter by is_bought=false returns only unbought items."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)
    _make_list_item(app, list_id, user_id, name="Milk", is_bought=False)
    _make_list_item(app, list_id, user_id, name="Bread", is_bought=True)

    resp = client.get(
        f"/api/v1/lists/{list_id}/items?is_bought=false",
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 200
    data = resp.get_json()
    assert len(data) == 1
    assert data[0]["name"] == "Milk"


def test_get_items_sorts_urgent_first(app, client):
    """Items are sorted: urgent first, then by creation time."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)
    _make_list_item(app, list_id, user_id, name="Normal")
    _make_list_item(app, list_id, user_id, name="Urgent", is_urgent=True)

    resp = client.get(
        f"/api/v1/lists/{list_id}/items",
        headers=_auth(app, user_id),
    )
    data = resp.get_json()
    assert data[0]["name"] == "Urgent"
    assert data[0]["is_urgent"] is True


# ══════════════════════════════════════════════════════════════
# PATCH /lists/<list_id>/items/<item_id> — Update item
# ══════════════════════════════════════════════════════════════


def test_update_item_requires_membership(app, client):
    """Non-members cannot update items."""
    owner_id = _make_user(app)
    outsider_id = _make_user(app)
    group_id = _make_group(app, owner_id)
    _add_member(app, group_id, owner_id, role="admin")
    list_id = _make_list(app, group_id, owner_id)
    item_id = _make_list_item(app, list_id, owner_id)

    resp = client.patch(
        f"/api/v1/lists/{list_id}/items/{item_id}",
        json={"name": "Hijacked"},
        headers=_auth(app, outsider_id),
    )
    assert resp.status_code == 403


def test_update_item_success(app, client):
    """Successful update returns 200 with new data."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)
    item_id = _make_list_item(app, list_id, user_id, name="Milk", quantity=1.0)

    resp = client.patch(
        f"/api/v1/lists/{list_id}/items/{item_id}",
        json={"name": "Almarai Milk", "quantity": 2.5, "unit": "L"},
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 200
    data = resp.get_json()
    assert data["name"] == "Almarai Milk"
    assert data["quantity"] == 2.5
    assert data["unit"] == "L"


def test_update_item_rejects_zero_quantity(app, client):
    """Updating quantity to 0 must fail (400)."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)
    item_id = _make_list_item(app, list_id, user_id)

    resp = client.patch(
        f"/api/v1/lists/{list_id}/items/{item_id}",
        json={"quantity": 0},
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 400


def test_update_item_rejects_invalid_unit(app, client):
    """Invalid unit must fail (400)."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)
    item_id = _make_list_item(app, list_id, user_id)

    resp = client.patch(
        f"/api/v1/lists/{list_id}/items/{item_id}",
        json={"unit": "gallon"},
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 400


def test_update_item_rejects_empty_name(app, client):
    """Whitespace-only name must fail (400)."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)
    item_id = _make_list_item(app, list_id, user_id)

    resp = client.patch(
        f"/api/v1/lists/{list_id}/items/{item_id}",
        json={"name": "   "},
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 400


def test_update_item_404_for_invalid_uuid(app, client):
    """Invalid UUID returns 404."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)

    resp = client.patch(
        f"/api/v1/lists/{list_id}/items/not-a-uuid",
        json={"name": "X"},
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 404


# ══════════════════════════════════════════════════════════════
# DELETE /lists/<list_id>/items/<item_id> — Delete single item
# ══════════════════════════════════════════════════════════════


def test_delete_item_requires_membership(app, client):
    """Non-members cannot delete items."""
    owner_id = _make_user(app)
    outsider_id = _make_user(app)
    group_id = _make_group(app, owner_id)
    _add_member(app, group_id, owner_id, role="admin")
    list_id = _make_list(app, group_id, owner_id)
    item_id = _make_list_item(app, list_id, owner_id)

    resp = client.delete(
        f"/api/v1/lists/{list_id}/items/{item_id}",
        headers=_auth(app, outsider_id),
    )
    assert resp.status_code == 403


def test_delete_item_success(app, client):
    """Successful deletion returns 200."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)
    item_id = _make_list_item(app, list_id, user_id)

    resp = client.delete(
        f"/api/v1/lists/{list_id}/items/{item_id}",
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 200

    # Verify it's actually gone
    resp2 = client.get(
        f"/api/v1/lists/{list_id}/items",
        headers=_auth(app, user_id),
    )
    assert len(resp2.get_json()) == 0


# ══════════════════════════════════════════════════════════════
# DELETE /lists/<list_id>/items — Bulk delete (US-23)
# ══════════════════════════════════════════════════════════════


def test_bulk_delete_requires_membership(app, client):
    """Non-members cannot bulk delete."""
    owner_id = _make_user(app)
    outsider_id = _make_user(app)
    group_id = _make_group(app, owner_id)
    _add_member(app, group_id, owner_id, role="admin")
    list_id = _make_list(app, group_id, owner_id)

    resp = client.delete(
        f"/api/v1/lists/{list_id}/items",
        headers=_auth(app, outsider_id),
    )
    assert resp.status_code == 403


def test_bulk_delete_success(app, client):
    """US-23: Bulk delete removes all items and returns count."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)
    _make_list_item(app, list_id, user_id, name="Milk")
    _make_list_item(app, list_id, user_id, name="Bread")
    _make_list_item(app, list_id, user_id, name="Eggs")

    resp = client.delete(
        f"/api/v1/lists/{list_id}/items",
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 200
    data = resp.get_json()
    assert "Deleted 3 items" in data["message"]

    # Verify list is empty
    resp2 = client.get(
        f"/api/v1/lists/{list_id}/items",
        headers=_auth(app, user_id),
    )
    assert len(resp2.get_json()) == 0


# ══════════════════════════════════════════════════════════════
# PATCH /lists/<list_id>/items/<item_id>/purchase — Mark bought (US-26)
# ══════════════════════════════════════════════════════════════


def test_mark_purchased_requires_membership(app, client):
    """Non-members cannot mark items as purchased."""
    owner_id = _make_user(app)
    outsider_id = _make_user(app)
    group_id = _make_group(app, owner_id)
    _add_member(app, group_id, owner_id, role="admin")
    list_id = _make_list(app, group_id, owner_id)
    item_id = _make_list_item(app, list_id, owner_id)

    resp = client.patch(
        f"/api/v1/lists/{list_id}/items/{item_id}/purchase",
        headers=_auth(app, outsider_id),
    )
    assert resp.status_code == 403


def test_mark_purchased_success(app, client):
    """US-26: Marking item as bought records the buyer."""
    admin_id = _make_user(app)
    buyer_id = _make_user(app)
    group_id = _make_group(app, admin_id)
    _add_member(app, group_id, admin_id, role="admin")
    _add_member(app, group_id, buyer_id, role="member")
    list_id = _make_list(app, group_id, admin_id)
    item_id = _make_list_item(app, list_id, admin_id, name="Milk")

    # Buyer marks item as purchased
    resp = client.patch(
        f"/api/v1/lists/{list_id}/items/{item_id}/purchase",
        headers=_auth(app, buyer_id),
    )
    assert resp.status_code == 200
    data = resp.get_json()
    assert data["is_bought"] is True
    assert data["bought_by"] == buyer_id


def test_mark_purchased_404_for_invalid_uuid(app, client):
    """Invalid UUID returns 404."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)

    resp = client.patch(
        f"/api/v1/lists/{list_id}/items/not-a-uuid/purchase",
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 404


# ══════════════════════════════════════════════════════════════
# POST /lists/<list_id>/items/<item_id>/image — Upload item photo
# ══════════════════════════════════════════════════════════════


def _stub_storage_upload(monkeypatch, *, url="https://cdn.test/item-images/fake.jpg"):
    """Replaces the real Supabase Storage call with a stub that returns a
    fixed URL — these tests must never hit real Storage. Patched on the
    class so it applies to the process-wide facade singleton too."""
    calls = []

    def fake_upload(self, *, item_id, file_bytes, content_type, ext):
        calls.append(
            {"item_id": item_id, "size": len(file_bytes), "content_type": content_type, "ext": ext}
        )
        return url

    monkeypatch.setattr(SupabaseStorageProvider, "upload_item_image", fake_upload)
    return calls


def _image_file(content=b"\xff\xd8\xff fake jpeg bytes", filename="photo.jpg"):
    return (io.BytesIO(content), filename)


def test_upload_item_image_requires_membership(app, client, monkeypatch):
    """Non-members cannot upload an image, and Storage is never called."""
    calls = _stub_storage_upload(monkeypatch)
    owner_id = _make_user(app)
    outsider_id = _make_user(app)
    group_id = _make_group(app, owner_id)
    _add_member(app, group_id, owner_id, role="admin")
    list_id = _make_list(app, group_id, owner_id)
    item_id = _make_list_item(app, list_id, owner_id)

    resp = client.post(
        f"/api/v1/lists/{list_id}/items/{item_id}/image",
        data={"image": _image_file()},
        content_type="multipart/form-data",
        headers=_auth(app, outsider_id),
    )
    assert resp.status_code == 403
    assert calls == []


def test_upload_item_image_success_replaces_url_and_returns_it(app, client, monkeypatch):
    """Happy path: 201, response body carries the new image_url, and the
    item row is actually updated (so a follow-up GET sees it too)."""
    url = "https://cdn.test/item-images/abc123.jpg"
    calls = _stub_storage_upload(monkeypatch, url=url)
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)
    item_id = _make_list_item(app, list_id, user_id, name="Milk")

    resp = client.post(
        f"/api/v1/lists/{list_id}/items/{item_id}/image",
        data={"image": _image_file()},
        content_type="multipart/form-data",
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 201
    data = resp.get_json()
    assert data["image_url"] == url
    assert len(calls) == 1
    assert calls[0]["item_id"] == item_id
    assert calls[0]["content_type"] == "image/jpeg"
    assert calls[0]["ext"] == "jpg"

    with app.app_context():
        assert db.session.get(ListItem, item_id).image_url == url


def test_upload_item_image_rejects_missing_file(app, client, monkeypatch):
    """No 'image' field in the multipart body -> 400, Storage never called."""
    calls = _stub_storage_upload(monkeypatch)
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)
    item_id = _make_list_item(app, list_id, user_id)

    resp = client.post(
        f"/api/v1/lists/{list_id}/items/{item_id}/image",
        data={},
        content_type="multipart/form-data",
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 400
    assert calls == []


def test_upload_item_image_rejects_unsupported_type(app, client, monkeypatch):
    """A content type outside jpg/png/webp is rejected before Storage is called."""
    calls = _stub_storage_upload(monkeypatch)
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)
    item_id = _make_list_item(app, list_id, user_id)

    resp = client.post(
        f"/api/v1/lists/{list_id}/items/{item_id}/image",
        data={"image": (io.BytesIO(b"GIF89a..."), "photo.gif")},
        content_type="multipart/form-data",
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 400
    assert calls == []


def test_upload_item_image_rejects_oversized_file(app, client, monkeypatch):
    """A file over the 5MB limit is rejected before Storage is called."""
    calls = _stub_storage_upload(monkeypatch)
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)
    item_id = _make_list_item(app, list_id, user_id)

    oversized = b"\x00" * (5 * 1024 * 1024 + 1)
    resp = client.post(
        f"/api/v1/lists/{list_id}/items/{item_id}/image",
        data={"image": (io.BytesIO(oversized), "big.jpg")},
        content_type="multipart/form-data",
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 400
    assert calls == []


def test_upload_item_image_404_for_missing_item(app, client, monkeypatch):
    """A well-formed request for an item that doesn't exist is a 404, not a 403/500."""
    calls = _stub_storage_upload(monkeypatch)
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    _add_member(app, group_id, user_id, role="admin")
    list_id = _make_list(app, group_id, user_id)

    resp = client.post(
        f"/api/v1/lists/{list_id}/items/{uuid.uuid4()}/image",
        data={"image": _image_file()},
        content_type="multipart/form-data",
        headers=_auth(app, user_id),
    )
    assert resp.status_code == 404
    assert calls == []