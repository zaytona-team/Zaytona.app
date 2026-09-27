"""Abstract base model.

Provides UUID primary key + created/updated timestamps that most
tables in the ERD share. Concrete models override the PK column name
(e.g. user_id, group_id) but reuse the timestamp mixin behaviour.
"""
import uuid
from datetime import datetime, timezone

from sqlalchemy.dialects.postgresql import UUID

from app.extensions import db


def _utcnow():
    return datetime.now(timezone.utc)


class TimestampMixin:
    created_at = db.Column(db.DateTime(timezone=True), default=_utcnow, nullable=False)
    updated_at = db.Column(
        db.DateTime(timezone=True), default=_utcnow, onupdate=_utcnow, nullable=False
    )


def gen_uuid() -> str:
    return str(uuid.uuid4())


# Reusable UUID column type alias for Postgres.
UUIDType = UUID(as_uuid=False)
