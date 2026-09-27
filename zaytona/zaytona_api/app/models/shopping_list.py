"""SHOPPING_LIST model.

Fleshed out early (ahead of the List Management story) only so that
Group Management's US-11 ("admin removes a list from the group") has a
real table to delete from. Creating/editing lists belongs to List
Management (US-13+); this model intentionally stays minimal until then.
"""
from sqlalchemy.orm import validates

from app.extensions import db
from app.models.base_model import TimestampMixin, UUIDType, gen_uuid
from app.utils.validators import require_text


class ShoppingList(db.Model, TimestampMixin):
    __tablename__ = "shopping_lists"

    list_id = db.Column(UUIDType, primary_key=True, default=gen_uuid)
    group_id = db.Column(UUIDType, db.ForeignKey("groups.group_id"), nullable=False, index=True)
    created_by = db.Column(UUIDType, db.ForeignKey("users.user_id"), nullable=False)
    completed_by = db.Column(UUIDType, db.ForeignKey("users.user_id"), nullable=True)

    name = db.Column(db.String(120), nullable=False)
    status = db.Column(
        db.Enum("active", "completed", name="shopping_list_status"),
        nullable=False,
        default="active",
    )
    completed_at = db.Column(db.DateTime(timezone=True), nullable=True)

    # Stamped each time the 12h "still has items" reminder sweep notifies
    # this list's group; null until the first reminder fires. Drives
    # ListRepository.list_due_for_reminder's 12h window.
    last_reminded_at = db.Column(db.DateTime(timezone=True), nullable=True)

    # Display accent picked in the list-settings sheet. Matches
    # zaytona_design_system's ZaytonaListAccent enum on the client.
    ALLOWED_COLORS = ("red", "indigo", "mint", "navy", "lilac")
    color = db.Column(db.String(20), nullable=True)

    @validates("name")
    def _validate_name(self, _key, value):
        return require_text(value, "name", max_length=120)

    @validates("color")
    def _validate_color(self, _key, value):
        if value is not None and value not in self.ALLOWED_COLORS:
            raise ValueError(f"color must be one of: {', '.join(self.ALLOWED_COLORS)}")
        return value


    creator = db.relationship("User", foreign_keys=[created_by], lazy="joined")
    
    def to_dict(self) -> dict:
        return {
            "list_id": self.list_id,
            "group_id": self.group_id,
            "created_by": self.created_by,
            "created_by_name": f"{self.creator.first_name} {self.creator.last_name}" if self.creator else "Unknown",
            "completed_by": self.completed_by,
            "name": self.name,
            "status": self.status,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
            "completed_at": self.completed_at.isoformat() if self.completed_at else None,
            "last_reminded_at": self.last_reminded_at.isoformat() if self.last_reminded_at else None,
            "color": self.color,
        }
