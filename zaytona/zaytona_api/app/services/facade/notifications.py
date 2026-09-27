"""Notification mixin — dedicated push-notification endpoints for a list
(US-31, US-32): assigning a buyer, reminding a specific member, and
reminding yourself.

Requires `self.lists` (ListRepository), `self.groups` (GroupRepository),
`self.users` (UserRepository), `self.user_devices` (UserDeviceRepository),
and `self.notifications` (FirebaseProvider) from the composed facade,
plus GuardsMixin's `_require_membership` and TripFacadeMixin's
`assign_trip_buyer`.
"""
import logging

from app.services.facade.errors import FacadeError
from app.services.providers.firebase_provider import FirebaseError
from app.utils.util import _is_uuid

logger = logging.getLogger("zaytona.facade")


class NotificationFacadeMixin:
    def _push_to_user(self, *, user_id, title, body, data):
        tokens = self.user_devices.list_tokens_for_users([user_id])
        if not tokens:
            return 0
        try:
            sent, invalid_tokens = self.notifications.send_to_tokens(
                tokens, title=title, body=body, data=data
            )
            self.user_devices.delete_invalid_tokens(invalid_tokens)
            return sent
        except FirebaseError as e:
            logger.warning("Push to user %s failed: %s", user_id, e)
            return 0

    def _get_list_for_notification(self, *, user_id, list_id):
        if not _is_uuid(list_id):
            raise FacadeError("List not found", status=404)
        shopping_list = self.lists.get_by_id(list_id)
        if not shopping_list:
            raise FacadeError("List not found", status=404)
        self._require_membership(user_id=user_id, group_id=shopping_list.group_id)
        return shopping_list

    # ── US-31 : assign a buyer, notifying them ────────────────
    def notify_assign_buyer(self, *, user_id, list_id, target_user_id):
        shopping_list = self._get_list_for_notification(user_id=user_id, list_id=list_id)
        # Creates the trip (409s if one's already active) and validates
        # target_user_id is actually a member — same rule as TripStart.
        self.assign_trip_buyer(user_id=user_id, list_id=list_id, buyer_id=target_user_id)

        caller = self.users.get_by_id(user_id)
        self._push_to_user(
            user_id=target_user_id,
            title="You're the buyer",
            body=f"{caller.first_name} picked you to shop for '{shopping_list.name}'.",
            data={"list_id": list_id, "group_id": shopping_list.group_id},
        )
        return {"message": "Notification sent successfully"}

    # ── US-32 : remind a specific member about the list ───────
    def notify_remind_member(self, *, user_id, list_id, target_user_id):
        shopping_list = self._get_list_for_notification(user_id=user_id, list_id=list_id)
        if not self.groups.get_member(group_id=shopping_list.group_id, user_id=target_user_id):
            raise FacadeError("That user is not a member of this group", status=400)

        caller = self.users.get_by_id(user_id)
        self._push_to_user(
            user_id=target_user_id,
            title="Reminder",
            body=f"{caller.first_name} wants you to check '{shopping_list.name}'.",
            data={"list_id": list_id, "group_id": shopping_list.group_id},
        )
        return {"message": "Notification sent successfully"}

    # ── US-32 : remind yourself about the list ─────────────────
    def notify_remind_me(self, *, user_id, list_id):
        shopping_list = self._get_list_for_notification(user_id=user_id, list_id=list_id)
        self._push_to_user(
            user_id=user_id,
            title="Reminder",
            body=f"Don't forget '{shopping_list.name}'.",
            data={"list_id": list_id, "group_id": shopping_list.group_id},
        )
        return {"message": "Notification sent successfully"}
