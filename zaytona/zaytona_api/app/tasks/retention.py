"""7-day retention sweep — Celery Beat calls sweep_expired_history once a
day (see app.config['CELERY']['beat_schedule']). Hard-deletes anything
past the retention window: completed trips (and, first, any list_items
still claimed by them — see ItemRepository.delete_by_trip_id) and
activity-log entries. Once gone, it's gone — there is no undo.

Runs inside the Flask app context (see extensions.py::celery_init_app's
FlaskTask), same as the reminder sweep — no request/caller identity
here, only a scheduled sweep.
"""
import logging
from datetime import datetime, timedelta, timezone

from celery import shared_task

from app.persistence.repositories.history_repository import HistoryRepository
from app.persistence.repositories.item_repository import ItemRepository
from app.persistence.repositories.trip_repository import TripRepository

logger = logging.getLogger("zaytona.tasks")

RETENTION_WINDOW = timedelta(days=7)


@shared_task(name="retention.sweep_expired_history")
def sweep_expired_history():
    cutoff = datetime.now(timezone.utc) - RETENTION_WINDOW

    trips_repo = TripRepository()
    items_repo = ItemRepository()
    history_repo = HistoryRepository()

    expired_trip_ids = trips_repo.list_completed_older_than(cutoff)
    deleted_items = 0
    for trip_id in expired_trip_ids:
        deleted_items += items_repo.delete_by_trip_id(trip_id)
    deleted_trips = trips_repo.delete_by_ids(expired_trip_ids)

    deleted_history = history_repo.delete_older_than(cutoff)

    logger.info(
        "Retention sweep: deleted %d completed trip(s), %d claimed item(s), "
        "%d history entry(ies) older than %s",
        deleted_trips, deleted_items, deleted_history, cutoff.isoformat(),
    )
