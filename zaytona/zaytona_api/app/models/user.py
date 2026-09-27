"""USER model — the ERD's USER entity.

There is no password column: identity is established by Authentica OTP
(US-36), not Supabase Auth. `user_id` is generated locally, and this
table is the single source of truth for a user — Supabase is used only
as the Postgres host, not as an auth provider.

Scope note: only USER is fleshed out for US-01/02/03/36. The remaining
ERD tables are defined as thin stubs in their own modules so migrations
and relationships can be layered in later without restructuring.
"""
from sqlalchemy.orm import validates

from app.extensions import db
from app.models.base_model import TimestampMixin, UUIDType, gen_uuid
from app.utils.validators import require_text, validate_email, validate_phone


class User(db.Model, TimestampMixin):
    __tablename__ = "users"

    user_id = db.Column(UUIDType, primary_key=True, default=gen_uuid)

    first_name = db.Column(db.String(80), nullable=False)
    last_name = db.Column(db.String(80), nullable=False)
    # Optional fallback contact — not the login identity. Nullable so
    # signup can omit it (per validation.md: "Email is optional").
    email = db.Column(db.String(255), unique=True, nullable=True, index=True)
    phone = db.Column(db.String(32), unique=True, nullable=False, index=True)
    avatar_url = db.Column(db.String(512), nullable=True)

    # US-36: set true once Authentica verifies the phone OTP.
    phone_verified = db.Column(db.Boolean, default=False, nullable=False)

    # Per-user toggle for the 12h "list still has items" push reminders.
    reminders_enabled = db.Column(db.Boolean, default=True, nullable=False)

    @validates("first_name")
    def _validate_first_name(self, _key, value):
        return require_text(value, "first_name", max_length=80)

    @validates("last_name")
    def _validate_last_name(self, _key, value):
        return require_text(value, "last_name", max_length=80)

    @validates("email")
    def _validate_email(self, _key, value):
        return validate_email(value)

    @validates("phone")
    def _validate_phone(self, _key, value):
        return validate_phone(value)

    def to_dict(self) -> dict:
        return {
            "user_id": self.user_id,
            "first_name": self.first_name,
            "last_name": self.last_name,
            "email": self.email,
            "phone": self.phone,
            "avatar_url": self.avatar_url,
            "phone_verified": self.phone_verified,
            "reminders_enabled": self.reminders_enabled,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }
