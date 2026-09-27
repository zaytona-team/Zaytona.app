"""Repository for TRIP — locks a shopping list to a single buyer for the
duration of a shopping session.

Encapsulates all SQLAlchemy access so the facade never builds queries
inline. Mirrors ListRepository.
"""
from datetime import datetime, timezone

from app.extensions import db
from app.models.trip import Trip


class TripRepository:
    def create(self, *, list_id, buyer_id) -> Trip:
        trip = Trip(list_id=list_id, buyer_id=buyer_id, status="active")
        db.session.add(trip)
        db.session.commit()
        return trip

    def get_by_id(self, trip_id: str) -> Trip | None:
        return db.session.get(Trip, trip_id)

    def get_active_by_list(self, list_id: str) -> Trip | None:
        return (
            db.session.query(Trip)
            .filter_by(list_id=list_id, status="active")
            .first()
        )

    def set_status(self, trip_id: str, status: str) -> Trip | None:
        trip = self.get_by_id(trip_id)
        if not trip:
            return None
        trip.status = status
        if status in ("completed", "cancelled"):
            trip.completed_at = datetime.now(timezone.utc)
        db.session.commit()
        return trip

    def list_completed_for_list(self, list_id: str) -> list[Trip]:
        """Every completed trip for this one list, newest first — powers
        the History screen's "الرحلات" tab, scoped to a single list
        (a list is reused trip after trip, so history is per-list)."""
        return (
            db.session.query(Trip)
            .filter(Trip.list_id == list_id, Trip.status == "completed")
            .order_by(Trip.completed_at.desc())
            .all()
        )

    # ── 7-day retention sweep (app/tasks/retention.py) ────────
    def list_completed_older_than(self, cutoff: datetime) -> list[str]:
        """trip_ids of completed trips whose completed_at has aged past
        the retention cutoff."""
        rows = (
            db.session.query(Trip.trip_id)
            .filter(Trip.status == "completed", Trip.completed_at < cutoff)
            .all()
        )
        return [row[0] for row in rows]

    def delete_by_ids(self, trip_ids: list[str]) -> int:
        """Hard-delete trips by id. Callers must delete their claimed
        list_items first (see ItemRepository.delete_by_trip_id) — trip_id
        is SET NULL on delete, not CASCADE, so nothing here removes items
        automatically."""
        if not trip_ids:
            return 0
        deleted = (
            db.session.query(Trip)
            .filter(Trip.trip_id.in_(trip_ids))
            .delete(synchronize_session=False)
        )
        db.session.commit()
        return deleted
