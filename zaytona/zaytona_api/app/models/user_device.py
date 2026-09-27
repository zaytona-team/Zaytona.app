"""USER_DEVICE model — the ERD's USER_DEVICE entity.

Registers a push-notification token for one of a user's devices.
Not driven by any user story yet (push belongs to a later notifications
story) — fleshed out now so the schema mirrors the full ERD.
"""
from sqlalchemy.orm import validates

from app.extensions import db
from app.models.base_model import UUIDType, _utcnow, gen_uuid
from app.utils.validators import require_text


class UserDevice(db.Model):
    __tablename__ = "user_devices"

    device_id = db.Column(UUIDType, primary_key=True, default=gen_uuid)
    user_id = db.Column(UUIDType, db.ForeignKey("users.user_id"), nullable=False, index=True)

    fcm_token = db.Column(db.String(512), nullable=False)
    platform = db.Column(db.Enum("ios", "android", "web", name="device_platform"), nullable=False)

    updated_at = db.Column(db.DateTime(timezone=True), default=_utcnow, onupdate=_utcnow, nullable=False)

    @validates("fcm_token")
    def _validate_fcm_token(self, _key, value):
        return require_text(value, "fcm_token", max_length=512)

    def to_dict(self) -> dict:
        return {
            "device_id": self.device_id,
            "user_id": self.user_id,
            "fcm_token": self.fcm_token,
            "platform": self.platform,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }
