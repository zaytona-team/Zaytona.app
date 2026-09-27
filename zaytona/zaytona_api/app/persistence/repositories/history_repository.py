"""Repository for LIST_ACTION — activity log per shopping list.

Encapsulates all SQLAlchemy access for history entries so the facade
never builds queries inline. Mirrors ItemRepository.
"""
from datetime import datetime

from app.extensions import db
from app.models.history import History


class HistoryRepository:
    def create(self, *, list_id, user_id, action, list_item_id=None, metadata=None) -> History:
        entry = History(
            list_id=list_id,
            list_item_id=list_item_id,
            user_id=user_id,
            action=action,
            action_metadata=metadata,
        )
        db.session.add(entry)
        db.session.commit()
        return entry

    def list_by_list(self, list_id, list_item_id=None) -> list[History]:
        query = db.session.query(History).filter(History.list_id == list_id)
        if list_item_id is not None:
            query = query.filter(History.list_item_id == list_item_id)
        return query.order_by(History.created_at.desc()).all()

    # ── 7-day retention sweep (app/tasks/retention.py) ────────
    def delete_older_than(self, cutoff: datetime) -> int:
        """Hard-delete activity-log entries older than the retention
        cutoff."""
        deleted = (
            db.session.query(History)
            .filter(History.created_at < cutoff)
            .delete(synchronize_session=False)
        )
        db.session.commit()
        return deleted
