"""Shared pytest fixtures — tests run against the real Supabase Postgres
DB (DATABASE_URL from .env), not sqlite. Each test that writes data must
register what it created via `created_user_ids`/`created_group_ids` so
the teardown can cascade-delete it — the DB is shared, not disposable.
"""
import pytest

from app import create_app
from app.config import Config
from app.extensions import db


class TestConfig(Config):
    TESTING = True
    # Inherits SQLALCHEMY_DATABASE_URI from Config -> the real Supabase
    # DATABASE_URL in .env. Postgres, not sqlite, so enums/FKs/UUIDs
    # behave exactly as they will in production.


@pytest.fixture
def app():
    app = create_app(TestConfig)
    yield app


@pytest.fixture
def client(app):
    return app.test_client()


@pytest.fixture
def created_user_ids(app):
    """Tests append user_ids they create here; teardown cascades the delete."""
    ids: list[str] = []
    yield ids
    if not ids:
        return

    from app.models.group import Group
    from app.models.group_member import GroupMember
    from app.models.recipe import Recipe
    from app.models.shopping_list import ShoppingList
    from app.models.user import User

    with app.app_context():
        group_ids = [
            g.group_id
            for g in db.session.query(Group.group_id).filter(Group.created_by.in_(ids))
        ]
        if group_ids:
            db.session.query(ShoppingList).filter(ShoppingList.group_id.in_(group_ids)).delete(
                synchronize_session=False
            )
            db.session.query(Recipe).filter(Recipe.group_id.in_(group_ids)).delete(
                synchronize_session=False
            )
            db.session.query(GroupMember).filter(GroupMember.group_id.in_(group_ids)).delete(
                synchronize_session=False
            )
            db.session.query(Group).filter(Group.group_id.in_(group_ids)).delete(
                synchronize_session=False
            )
        db.session.query(GroupMember).filter(GroupMember.user_id.in_(ids)).delete(
            synchronize_session=False
        )
        db.session.query(User).filter(User.user_id.in_(ids)).delete(synchronize_session=False)
        db.session.commit()
