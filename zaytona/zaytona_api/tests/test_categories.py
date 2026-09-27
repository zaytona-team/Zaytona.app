"""Integration tests for the categories namespace.

Categories are read-only reference data seeded via `flask seed-categories`.
These tests verify:
  * The seed script populates all 16 default categories
  * GET /categories/ returns them sorted by sort_order (aisle sequence)
  * GET /categories/<id> returns a single category or 404
  * No authentication is required (public reference data)
  * Response shape matches the documented Category schema

Runs against the real Supabase Postgres DB (see conftest.py). No teardown
is needed because categories are read-only — we never INSERT/UPDATE/DELETE
from tests, only READ from what the seed script created.
"""
import pytest

from app import create_app
from app.config import Config
from app.extensions import db
from app.models.category import Category


class TestConfig(Config):
    TESTING = True
    SQLALCHEMY_DATABASE_URI = "sqlite:///:memory:"
    # Config.SQLALCHEMY_ENGINE_OPTIONS sets connect_args={"connect_timeout": 10}
    # for Postgres; sqlite3.connect() rejects that kwarg, so drop it here.
    SQLALCHEMY_ENGINE_OPTIONS = {}


@pytest.fixture
def app():
    return create_app(TestConfig)


@pytest.fixture
def client(app):
    return app.test_client()


@pytest.fixture(autouse=True)
def ensure_categories_seeded(app):
    """Make sure the 16 default categories exist before each test.

    Idempotent — if they already exist, nothing happens. This fixture
    runs automatically (autouse=True) so each test starts with a
    fully-seeded categories table without having to repeat this logic.
    """
    with app.app_context():
        existing = db.session.query(Category).count()
        if existing >= 16:
            yield
            return

        # Minimal inline seed — mirrors scripts/seed.py
        DEFAULT_CATEGORIES = [
            ("Fresh Produce", 1),
            ("Meat & Seafood", 2),
            ("Dairy & Eggs", 3),
            ("Bakery", 4),
            ("Pantry", 5),
            ("Cooking Essentials", 6),
            ("Breakfast", 7),
            ("Snacks", 8),
            ("Beverages", 9),
            ("Frozen", 10),
            ("Ready-to-Eat", 11),
            ("Baby", 12),
            ("Personal Care", 13),
            ("Health", 14),
            ("Household", 15),
            ("Pets", 16),
        ]
        for name, order in DEFAULT_CATEGORIES:
            if not (
                db.session.query(Category)
                .filter(db.func.lower(Category.name) == name.lower())
                .first()
            ):
                db.session.add(Category(name=name, sort_order=order))
        db.session.commit()
        yield


# ── GET /api/v1/categories/ ──────────────────────────────────


def test_list_categories_returns_200(client):
    """The list endpoint must respond with 200 OK."""
    resp = client.get("/api/v1/categories/")
    assert resp.status_code == 200


def test_list_categories_returns_json_array(client):
    """The list endpoint must return a JSON array."""
    resp = client.get("/api/v1/categories/")
    data = resp.get_json()
    assert isinstance(data, list)


def test_list_categories_contains_all_16_defaults(client):
    """All 16 seeded default categories must be present."""
    resp = client.get("/api/v1/categories/")
    data = resp.get_json()
    assert len(data) == 16

    expected_names = {
        "Fresh Produce", "Meat & Seafood", "Dairy & Eggs", "Bakery",
        "Pantry", "Cooking Essentials", "Breakfast", "Snacks",
        "Beverages", "Frozen", "Ready-to-Eat", "Baby",
        "Personal Care", "Health", "Household", "Pets",
    }
    actual_names = {item["name"] for item in data}
    assert actual_names == expected_names


def test_list_categories_sorted_by_sort_order(client):
    """Categories must come back in store aisle sequence (sort_order)."""
    resp = client.get("/api/v1/categories/")
    data = resp.get_json()

    # Check sort_order values are strictly ascending
    sort_orders = [item["sort_order"] for item in data]
    assert sort_orders == sorted(sort_orders)

    # And that the first/last match what the seed script defines
    assert data[0]["name"] == "Fresh Produce"
    assert data[0]["sort_order"] == 1
    assert data[-1]["name"] == "Pets"
    assert data[-1]["sort_order"] == 16


def test_list_categories_response_schema(client):
    """Each category object must have the documented shape."""
    resp = client.get("/api/v1/categories/")
    data = resp.get_json()

    for item in data:
        # Required fields
        assert "category_id" in item
        assert "name" in item
        assert "sort_order" in item
        # Optional field (may be null but must exist as a key)
        assert "image_url" in item

        # Type checks
        assert isinstance(item["category_id"], str)
        assert isinstance(item["name"], str) and len(item["name"]) > 0
        assert isinstance(item["sort_order"], int)


def test_list_categories_no_auth_required(client):
    """The list endpoint must NOT require JWT — it's public reference data."""
    # Request with no Authorization header at all must still succeed
    resp = client.get("/api/v1/categories/")
    assert resp.status_code == 200


# ── GET /api/v1/categories/<id> ──────────────────────────────


def test_get_category_by_id_returns_200(client):
    """Looking up an existing category by UUID must return 200."""
    # Step 1: grab a real category id from the list endpoint
    list_resp = client.get("/api/v1/categories/")
    category_id = list_resp.get_json()[0]["category_id"]

    # Step 2: fetch it directly
    resp = client.get(f"/api/v1/categories/{category_id}")
    assert resp.status_code == 200


def test_get_category_by_id_returns_correct_data(client):
    """The single-category endpoint must return the same data as the list."""
    list_resp = client.get("/api/v1/categories/")
    first_in_list = list_resp.get_json()[0]

    resp = client.get(f"/api/v1/categories/{first_in_list['category_id']}")
    detail = resp.get_json()

    assert detail == first_in_list


def test_get_category_returns_404_for_missing_id(client):
    """A valid UUID that isn't in the DB must return 404, not 500."""
    # This UUID is syntactically valid but won't exist in the seed
    missing_uuid = "00000000-0000-0000-0000-000000000000"
    resp = client.get(f"/api/v1/categories/{missing_uuid}")
    assert resp.status_code == 404

    data = resp.get_json()
    assert "message" in data


def test_get_category_returns_404_for_invalid_uuid(client):
    """A malformed UUID must return a clean 404, not a raw 500."""
    # The facade._is_uuid() guard should catch this
    resp = client.get("/api/v1/categories/not-a-uuid")
    assert resp.status_code == 404


def test_get_category_response_schema(client):
    """Single-category response must match the Category schema."""
    list_resp = client.get("/api/v1/categories/")
    category_id = list_resp.get_json()[0]["category_id"]

    resp = client.get(f"/api/v1/categories/{category_id}")
    data = resp.get_json()

    assert isinstance(data, dict)
    assert set(data.keys()) == {"category_id", "name", "image_url", "sort_order"}
    assert isinstance(data["category_id"], str)
    assert isinstance(data["name"], str)
    assert isinstance(data["sort_order"], int)


def test_get_category_no_auth_required(client):
    """The detail endpoint must NOT require JWT either."""
    list_resp = client.get("/api/v1/categories/")
    category_id = list_resp.get_json()[0]["category_id"]

    resp = client.get(f"/api/v1/categories/{category_id}")
    assert resp.status_code == 200


# ── Negative cases / edge cases ──────────────────────────────


def test_categories_has_no_post_endpoint(client):
    """POST /categories/ must not exist — categories are a fixed enum."""
    resp = client.post(
        "/api/v1/categories/",
        json={"name": "Forbidden Category", "sort_order": 99},
    )
    # flask-restx returns 405 Method Not Allowed for disallowed methods
    assert resp.status_code in (404, 405)


def test_categories_has_no_patch_endpoint(client):
    """PATCH /categories/<id> must not exist — categories are read-only."""
    list_resp = client.get("/api/v1/categories/")
    category_id = list_resp.get_json()[0]["category_id"]

    resp = client.patch(
        f"/api/v1/categories/{category_id}",
        json={"name": "Hijacked"},
    )
    assert resp.status_code in (404, 405)


def test_categories_has_no_delete_endpoint(client):
    """DELETE /categories/<id> must not exist — categories are read-only."""
    list_resp = client.get("/api/v1/categories/")
    category_id = list_resp.get_json()[0]["category_id"]

    resp = client.delete(f"/api/v1/categories/{category_id}")
    assert resp.status_code in (404, 405)
