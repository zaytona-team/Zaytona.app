"""Integration tests for the 7-day retention sweep (app/tasks/retention.py).

sweep_expired_history is a plain function under its @shared_task
decorator — calling it directly (no .delay()/.apply_async()) exercises
the real deletion logic without needing a Celery broker.
"""
import uuid
from datetime import datetime, timedelta, timezone

import pytest

from app import create_app
from app.config import Config
from app.extensions import db
from app.models.group import Group
from app.models.history import History
from app.models.list_item import ListItem
from app.models.shopping_list import ShoppingList
from app.models.trip import Trip
from app.models.user import User
from app.tasks.retention import sweep_expired_history


class TestConfig(Config):
    TESTING = True
    SQLALCHEMY_DATABASE_URI = "sqlite:///:memory:"
    SQLALCHEMY_ENGINE_OPTIONS = {}


@pytest.fixture
def app():
    return create_app(TestConfig)


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


def _make_group(app, created_by) -> str:
    with app.app_context():
        group = Group(
            name="Test Group", created_by=created_by,
            invite_code=uuid.uuid4().hex[:6].upper(), type="household",
        )
        db.session.add(group)
        db.session.commit()
        return group.group_id


def _make_list(app, group_id, created_by) -> str:
    with app.app_context():
        lst = ShoppingList(name="Test List", group_id=group_id, created_by=created_by, status="active")
        db.session.add(lst)
        db.session.commit()
        return lst.list_id


def _make_trip(app, list_id, buyer_id, *, status="completed", completed_at=None) -> str:
    with app.app_context():
        trip = Trip(list_id=list_id, buyer_id=buyer_id, status=status, completed_at=completed_at)
        db.session.add(trip)
        db.session.commit()
        return trip.trip_id


def _make_item(app, list_id, added_by, *, trip_id=None) -> str:
    with app.app_context():
        item = ListItem(
            list_id=list_id, name="Milk", added_by=added_by,
            is_bought=trip_id is not None, trip_id=trip_id,
        )
        db.session.add(item)
        db.session.commit()
        return item.list_item_id


def _make_history_entry(app, list_id, user_id, created_at) -> str:
    with app.app_context():
        entry = History(list_id=list_id, user_id=user_id, action="created", action_metadata={"name": "Milk"})
        db.session.add(entry)
        db.session.commit()
        # created_at defaults to "now" on insert — backdate it directly to
        # simulate an entry actually written a week+ ago.
        db.session.query(History).filter_by(action_id=entry.action_id).update({"created_at": created_at})
        db.session.commit()
        return entry.action_id


def test_sweep_deletes_expired_trips_and_their_claimed_items(app):
    """A completed trip older than 7 days, and the items it claimed, are
    hard-deleted. A completed trip inside the window is left untouched."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    list_id = _make_list(app, group_id, user_id)
    now = datetime.now(timezone.utc)

    old_trip_id = _make_trip(app, list_id, user_id, completed_at=now - timedelta(days=8))
    recent_trip_id = _make_trip(app, list_id, user_id, completed_at=now - timedelta(days=1))
    _make_item(app, list_id, user_id, trip_id=old_trip_id)
    _make_item(app, list_id, user_id, trip_id=recent_trip_id)

    with app.app_context():
        sweep_expired_history()

        assert db.session.get(Trip, old_trip_id) is None
        assert db.session.get(Trip, recent_trip_id) is not None

        remaining_trip_ids = {
            item.trip_id for item in db.session.query(ListItem).filter_by(list_id=list_id).all()
        }
        assert remaining_trip_ids == {recent_trip_id}


def test_sweep_never_deletes_an_active_trip_regardless_of_age(app):
    """An active (in-progress) trip is never swept, no matter how old —
    only completed ones age out."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    list_id = _make_list(app, group_id, user_id)
    old_active_trip_id = _make_trip(app, list_id, user_id, status="active", completed_at=None)

    with app.app_context():
        sweep_expired_history()
        assert db.session.get(Trip, old_active_trip_id) is not None


def test_sweep_deletes_expired_history_entries(app):
    """Activity-log entries older than 7 days are hard-deleted; recent
    ones survive."""
    user_id = _make_user(app)
    group_id = _make_group(app, user_id)
    list_id = _make_list(app, group_id, user_id)
    now = datetime.now(timezone.utc)

    old_entry_id = _make_history_entry(app, list_id, user_id, now - timedelta(days=8))
    recent_entry_id = _make_history_entry(app, list_id, user_id, now - timedelta(days=1))

    with app.app_context():
        sweep_expired_history()
        assert db.session.get(History, old_entry_id) is None
        assert db.session.get(History, recent_entry_id) is not None
