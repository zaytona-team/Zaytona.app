"""LIST_ACTION model — the ERD's activity/history log per list.

Exposed via GET /api/v1/lists/<list_id>/history (see app/api/v1/histories.py).
Entries are written by ZaytonaFacade whenever an item is created, updated,
deleted, or marked purchased. `undo_available_until` / `is_undone` are ERD
columns for a future "undo" action — no story has adopted that behavior
yet, so nothing currently sets or reads them beyond their column defaults.

`list_item_id` is nullable: deleting a list item (see
ItemRepository.delete / bulk_delete_by_list) must not be blocked by, or
cascade into, its own history — the log outlives the item it describes.

Note: the Python attribute is `action_metadata`, not `metadata` — SQLAlchemy
reserves `metadata` on every declarative model (it's `Base.metadata`), so
mapping to the ERD's `metadata` column needs a different attribute name.
"""
from sqlalchemy.orm import validates

from app.extensions import db
from app.models.base_model import UUIDType, _utcnow, gen_uuid
from app.utils.validators import require_one_of

ALLOWED_ACTIONS = ["created", "updated", "deleted", "consumed", "restocked"]


class History(db.Model):
    __tablename__ = "list_actions"

    action_id = db.Column(UUIDType, primary_key=True, default=gen_uuid)
    list_id = db.Column(UUIDType, db.ForeignKey("shopping_lists.list_id"), nullable=False, index=True)
    list_item_id = db.Column(
        UUIDType,
        db.ForeignKey("list_items.list_item_id", ondelete="SET NULL"),
        nullable=True,
        index=True,
    )
    user_id = db.Column(UUIDType, db.ForeignKey("users.user_id"), nullable=False)

    action = db.Column(db.Enum(*ALLOWED_ACTIONS, name="list_action_type"), nullable=False)
    action_metadata = db.Column("metadata", db.JSON, nullable=True)

    undo_available_until = db.Column(db.DateTime(timezone=True), nullable=True)
    is_undone = db.Column(db.Boolean, default=False, nullable=False)

    created_at = db.Column(db.DateTime(timezone=True), default=_utcnow, nullable=False)

    @validates("action")
    def _validate_action(self, _key, value):
        return require_one_of(value, "action", ALLOWED_ACTIONS)

    def to_dict(self) -> dict:
        return {
            "action_id": self.action_id,
            "list_id": self.list_id,
            "list_item_id": self.list_item_id,
            "user_id": self.user_id,
            "action": self.action,
            "metadata": self.action_metadata,
            "undo_available_until": (
                self.undo_available_until.isoformat() if self.undo_available_until else None
            ),
            "is_undone": self.is_undone,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }
