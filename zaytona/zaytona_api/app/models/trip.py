"""TRIP model — the ERD's TRIP entity.

Locks a shopping list to a single buyer for the duration of a shopping
session, so two members can't "check off" the same list at once. Not
driven by any user story yet — fleshed out now so the schema mirrors
the full ERD.

Status values (`active`/`completed`/`cancelled`) aren't specified by any
user story; chosen to mirror ShoppingList.status ("active"/"completed")
plus "cancelled" for an abandoned trip.
"""
from sqlalchemy.orm import validates

from app.extensions import db
from app.models.base_model import TimestampMixin, UUIDType, gen_uuid
from app.utils.validators import require_one_of

ALLOWED_STATUSES = ("active", "completed", "cancelled")


class Trip(db.Model, TimestampMixin):
    __tablename__ = "trips"

    trip_id = db.Column(UUIDType, primary_key=True, default=gen_uuid)
    list_id = db.Column(UUIDType, db.ForeignKey("shopping_lists.list_id"), nullable=False, index=True)
    buyer_id = db.Column(UUIDType, db.ForeignKey("users.user_id"), nullable=False)

    status = db.Column(
        db.Enum(*ALLOWED_STATUSES, name="trip_status"),
        nullable=False,
        default="active",
    )
    completed_at = db.Column(db.DateTime(timezone=True), nullable=True)

    @validates("status")
    def _validate_status(self, _key, value):
        return require_one_of(value, "status", ALLOWED_STATUSES)

    def to_dict(self) -> dict:
        return {
            "trip_id": self.trip_id,
            "list_id": self.list_id,
            "buyer_id": self.buyer_id,
            "status": self.status,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
            "completed_at": self.completed_at.isoformat() if self.completed_at else None,
        }
