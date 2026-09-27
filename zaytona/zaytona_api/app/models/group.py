"""GROUP model — the ERD's GROUP entity (US-04..US-12).

A group is a shared space (household or individual) that owns lists and
recipes. `invite_code` is a short unique code members share to let others
join (US-05/US-07) without any admin action.
"""
from sqlalchemy.orm import validates

from app.extensions import db
from app.models.base_model import TimestampMixin, UUIDType, gen_uuid
from app.utils.validators import require_text

# Mirrors the picker in the Flutter app's GroupIcon enum.
ICON_CHOICES = ("home", "cart", "coffee", "moon", "living", "restaurant", "pets", "store")

class Group(db.Model, TimestampMixin):
    __tablename__ = "groups"

    group_id = db.Column(UUIDType, primary_key=True, default=gen_uuid)
    created_by = db.Column(UUIDType, db.ForeignKey("users.user_id"), nullable=False)

    name = db.Column(db.String(120), nullable=False)
    image_url = db.Column(db.String(512), nullable=True)
    # One of app.models.group.ICON_CHOICES — a sticker id, not a URL.
    # Kept as a free string (not a DB enum) so new stickers don't need a migration.
    icon = db.Column(db.String(32), nullable=True)
    type = db.Column(
        db.Enum("individual", "household", name="group_type"),
        nullable=False,
        default="household",
    )
    # Null for individual (private) groups — they're never joinable, so
    # there's nothing to share.
    invite_code = db.Column(db.String(16), unique=True, nullable=True, index=True)

    @validates("name")
    def _validate_name(self, _key, value):
        return require_text(value, "name", max_length=120)


    creator = db.relationship("User", foreign_keys=[created_by], lazy="joined")

    def to_dict(self) -> dict:
        return {
            "group_id": self.group_id,
            "created_by": self.created_by,
            "created_by_name": f"{self.creator.first_name} {self.creator.last_name}" if self.creator else "Unknown",
            "name": self.name,
            "image_url": self.image_url,
            "icon": self.icon,
            "type": self.type,
            "invite_code": self.invite_code,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }
