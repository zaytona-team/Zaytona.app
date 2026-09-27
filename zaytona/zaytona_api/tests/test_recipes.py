"""Focused tests for Recipes (US-34, US-37)."""
import time, uuid, jwt, pytest
from app import create_app
from app.config import Config
from app.extensions import db
from app.models.group import Group
from app.models.group_member import GroupMember
from app.models.recipe import Recipe
from app.models.recipe_ingredient import RecipeIngredient
from app.models.shopping_list import ShoppingList
from app.models.user import User

class TestConfig(Config):
    TESTING = True
    SQLALCHEMY_DATABASE_URI = "sqlite:///:memory:"
    SQLALCHEMY_ENGINE_OPTIONS = {}

@pytest.fixture
def app(): return create_app(TestConfig)

@pytest.fixture
def client(app): return app.test_client()

def _make_user(app):
    with app.app_context():
        u = User(first_name="Test", last_name="User", email=f"{uuid.uuid4().hex[:8]}@t.com", phone=f"+9665{str(uuid.uuid4().int)[:8]}")
        db.session.add(u); db.session.commit()
        return u.user_id

def _make_group(app, creator_id):
    with app.app_context():
        g = Group(name="Test Group", created_by=creator_id, invite_code="ABC123", type="household")
        db.session.add(g); db.session.commit()
        return g.group_id

def _add_member(app, group_id, user_id, role="member"):
    with app.app_context():
        db.session.add(GroupMember(group_id=group_id, user_id=user_id, role=role))
        db.session.commit()

def _auth(app, user_id):
    with app.app_context():
        return {"Authorization": f"Bearer {jwt.encode({'sub': str(user_id), 'iat': int(time.time()), 'exp': int(time.time())+3600}, app.config['SECRET_KEY'], algorithm='HS256')}"}

def _make_recipe(app, group_id, creator_id, name="Test Recipe"):
    with app.app_context():
        r = Recipe(group_id=group_id, created_by=creator_id, name=name)
        db.session.add(r); db.session.commit()
        db.session.add(RecipeIngredient(recipe_id=r.recipe_id, name="Flour", quantity=1.0, unit="kg"))
        db.session.add(RecipeIngredient(recipe_id=r.recipe_id, name="Sugar", quantity=0.5, unit="kg"))
        db.session.commit()
        return r.recipe_id

def _make_list(app, group_id, creator_id):
    with app.app_context():
        l = ShoppingList(name="Test List", group_id=group_id, created_by=creator_id, status="active")
        db.session.add(l); db.session.commit()
        return l.list_id

# ── US-37: Authorization (Owner/Admin only) ──────────────────

def test_update_recipe_requires_owner_or_admin(app, client):
    owner_id = _make_user(app)
    member_id = _make_user(app)
    outsider_id = _make_user(app)
    group_id = _make_group(app, owner_id)
    _add_member(app, group_id, owner_id, "admin")
    _add_member(app, group_id, member_id, "member")
    recipe_id = _make_recipe(app, group_id, owner_id)

    # Outsider cannot update (403)
    resp = client.patch(f"/api/v1/recipes/{recipe_id}", json={"name": "Hacked"}, headers=_auth(app, outsider_id))
    assert resp.status_code == 403

    # Regular member cannot update (403)
    resp = client.patch(f"/api/v1/recipes/{recipe_id}", json={"name": "Hacked"}, headers=_auth(app, member_id))
    assert resp.status_code == 403

    # Owner CAN update (200)
    resp = client.patch(f"/api/v1/recipes/{recipe_id}", json={"name": "Updated Pancakes"}, headers=_auth(app, owner_id))
    assert resp.status_code == 200
    assert resp.get_json()["name"] == "Updated Pancakes"

def test_delete_recipe_requires_owner_or_admin(app, client):
    owner_id = _make_user(app)
    member_id = _make_user(app)
    group_id = _make_group(app, owner_id)
    _add_member(app, group_id, owner_id, "admin")
    _add_member(app, group_id, member_id, "member")
    recipe_id = _make_recipe(app, group_id, owner_id)

    # Member cannot delete (403)
    resp = client.delete(f"/api/v1/recipes/{recipe_id}", headers=_auth(app, member_id))
    assert resp.status_code == 403

    # Owner CAN delete (200)
    resp = client.delete(f"/api/v1/recipes/{recipe_id}", headers=_auth(app, owner_id))
    assert resp.status_code == 200

# ── US-34: Import to List ────────────────────────────────────

def test_import_recipe_to_list_success(app, client):
    owner_id = _make_user(app)
    group_id = _make_group(app, owner_id)
    _add_member(app, group_id, owner_id, "admin")
    
    recipe_id = _make_recipe(app, group_id, owner_id)
    list_id = _make_list(app, group_id, owner_id)

    resp = client.post(
        f"/api/v1/recipes/lists/{list_id}/items/from-recipe/{recipe_id}",
        headers=_auth(app, owner_id)
    )
    assert resp.status_code == 201
    assert "imported 2 items" in resp.get_json()["message"].lower()

    # Verify items were actually added to the list
    resp_list = client.get(f"/api/v1/lists/{list_id}/items", headers=_auth(app, owner_id))
    items = resp_list.get_json()
    assert len(items) == 2
    assert any(i["name"] == "Flour" and i["quantity"] == 1.0 for i in items)
