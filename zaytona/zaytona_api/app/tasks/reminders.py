"""12h list-reminder sweep — Celery Beat calls sweep_list_reminders on the
interval configured in app.config['CELERY']['beat_schedule'] (every 15
minutes; see config.py's comment for why that's not the same as the 12h
reminder period itself).

Runs inside the Flask app context (see extensions.py::celery_init_app's
FlaskTask), so it can use the same repositories/providers the facade
uses — it just doesn't go through ZaytonaFacade, since there's no
request/caller identity here, only a scheduled sweep.
"""
import logging
from datetime import timedelta

from celery import shared_task

from app.persistence.repositories.group_repository import GroupRepository
from app.persistence.repositories.list_repository import ListRepository
from app.persistence.repositories.user_device_repository import UserDeviceRepository
from app.persistence.repositories.user_repository import UserRepository
from app.services.providers.firebase_provider import FirebaseError, FirebaseProvider

logger = logging.getLogger("zaytona.tasks")

REMINDER_INTERVAL = timedelta(hours=12)


@shared_task(name="reminders.sweep_list_reminders")
def sweep_list_reminders():
    lists_repo = ListRepository()
    groups_repo = GroupRepository()
    users_repo = UserRepository()
    devices_repo = UserDeviceRepository()
    notifications = FirebaseProvider()

    due_lists = lists_repo.list_due_for_reminder(REMINDER_INTERVAL)
    for shopping_list in due_lists:
        member_ids = [m.user_id for m in groups_repo.list_members(shopping_list.group_id)]
        recipient_ids = [u.user_id for u in users_repo.get_by_ids(member_ids) if u.reminders_enabled]
        tokens = devices_repo.list_tokens_for_users(recipient_ids)

        if tokens:
            try:
                _sent, invalid_tokens = notifications.send_to_tokens(
                    tokens,
                    title="Don't forget your list!",
                    body=f"'{shopping_list.name}' still has items waiting.",
                    data={"list_id": shopping_list.list_id, "group_id": shopping_list.group_id},
                )
                devices_repo.delete_invalid_tokens(invalid_tokens)
            except FirebaseError as e:
                logger.warning("Reminder push for list %s failed: %s", shopping_list.list_id, e)

        # Stamp regardless of whether anyone had a token — otherwise a
        # list with no reachable devices stays "due" and gets re-queried
        # (harmlessly, but wastefully) on every 15-minute sweep forever.
        lists_repo.mark_reminded(shopping_list.list_id)
