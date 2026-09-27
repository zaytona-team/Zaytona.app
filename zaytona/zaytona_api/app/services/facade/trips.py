"""Trip mixin — locks a shopping list to a single buyer for a shopping
session, and is the source of the three "Trip Alerts" actions: assigning
who the buyer is, that buyer announcing they're heading out (broadcast to
everyone), and that buyer privately asking chosen members if they need
anything added.

Requires `self.trips` (TripRepository), `self.lists` (ListRepository),
`self.groups` (GroupRepository), `self.users` (UserRepository),
`self.user_devices` (UserDeviceRepository), and `self.notifications`
(FirebaseProvider) from the composed facade, plus GuardsMixin's
`_require_membership`.
"""
import logging

from app.services.facade.errors import FacadeError
from app.utils.util import _is_uuid
from app.services.providers.firebase_provider import FirebaseError

logger = logging.getLogger("zaytona.facade")


class TripFacadeMixin:
    # ── "تعيين مشترٍ" (Assign a buyer) — any member can assign anyone,
    # including themselves, as the buyer. Not gated to the caller becoming
    # buyer — the picker in the app can choose any group member.
    def assign_trip_buyer(self, *, user_id, list_id, buyer_id):
        if not _is_uuid(list_id):
            raise FacadeError("List not found", status=404)

        shopping_list = self.lists.get_by_id(list_id)
        if not shopping_list:
            raise FacadeError("List not found", status=404)

        self._require_membership(user_id=user_id, group_id=shopping_list.group_id)

        if not self.groups.get_member(group_id=shopping_list.group_id, user_id=buyer_id):
            raise FacadeError("Chosen buyer is not a member of this group", status=400)

        if self.trips.get_active_by_list(list_id):
            raise FacadeError("This list already has an active trip", status=409)

        trip = self.trips.create(list_id=list_id, buyer_id=buyer_id)
        result = trip.to_dict()
        self._emit_group(
            "trip.assigned",
            {"group_id": shopping_list.group_id, "list_id": list_id,
             "actor_user_id": user_id, "trip": result},
            group_id=shopping_list.group_id,
        )
        return result

    # ── "أنا متجه للمتجر" (I'm heading to the store) — buyer-only, once
    # assigned. Unlike ask_trip_group, this has no recipient picker: it
    # broadcasts to every other group member, no privacy gating.
    def announce_heading_out(self, *, user_id, trip_id):
        if not _is_uuid(trip_id):
            raise FacadeError("Trip not found", status=404)

        trip = self.trips.get_by_id(trip_id)
        if not trip:
            raise FacadeError("Trip not found", status=404)
        if trip.buyer_id != user_id:
            raise FacadeError("Only the buyer can send this", status=403)

        shopping_list = self.lists.get_by_id(trip.list_id)
        buyer = self.users.get_by_id(user_id)
        member_ids = [
            m.user_id for m in self.groups.list_members(shopping_list.group_id) if m.user_id != user_id
        ]
        tokens = self.user_devices.list_tokens_for_users(member_ids)

        sent = 0
        if tokens:
            try:
                sent, invalid_tokens = self.notifications.send_to_tokens(
                    tokens,
                    title=f"{buyer.first_name} is heading to the store",
                    body=f"Add any last-minute items to '{shopping_list.name}' now.",
                    data={
                        "list_id": shopping_list.list_id,
                        "group_id": shopping_list.group_id,
                        "trip_id": trip.trip_id,
                    },
                )
                self.user_devices.delete_invalid_tokens(invalid_tokens)
            except FirebaseError as e:
                logger.warning("Heading-out push for trip %s failed: %s", trip_id, e)

        self._emit_group(
            "trip.heading_out",
            {"group_id": shopping_list.group_id, "list_id": shopping_list.list_id,
             "actor_user_id": user_id, "trip_id": trip.trip_id,
             "buyer_id": user_id, "buyer_name": buyer.first_name,
             "message": f"Add any last-minute items to '{shopping_list.name}' now."},
            group_id=shopping_list.group_id,
        )
        return {"notified_devices": sent}

    # ── "ذكّر أحدهم" (Remind someone) — buyer privately asks chosen group
    # members if they need anything added. Plain push, fire-and-forget: no
    # record of who was asked or how they answered is persisted — the
    # buyer picks the recipients precisely because they may want the trip
    # to stay private from some members.
    def ask_trip_group(self, *, user_id, trip_id, recipient_ids):
        if not _is_uuid(trip_id):
            raise FacadeError("Trip not found", status=404)

        trip = self.trips.get_by_id(trip_id)
        if not trip:
            raise FacadeError("Trip not found", status=404)
        if trip.buyer_id != user_id:
            raise FacadeError("Only the buyer can send this", status=403)
        if not recipient_ids:
            raise FacadeError("Select at least one recipient", status=400)

        shopping_list = self.lists.get_by_id(trip.list_id)
        valid_member_ids = {m.user_id for m in self.groups.list_members(shopping_list.group_id)}
        recipient_ids = [uid for uid in recipient_ids if uid in valid_member_ids and uid != user_id]
        if not recipient_ids:
            raise FacadeError("No valid recipients", status=400)

        buyer = self.users.get_by_id(user_id)
        tokens = self.user_devices.list_tokens_for_users(recipient_ids)

        sent = 0
        if tokens:
            try:
                sent, invalid_tokens = self.notifications.send_to_tokens(
                    tokens,
                    title=f"{buyer.first_name} is starting a shopping trip",
                    body=f"Want anything added to '{shopping_list.name}'?",
                    data={
                        "list_id": shopping_list.list_id,
                        "group_id": shopping_list.group_id,
                        "trip_id": trip.trip_id,
                    },
                )
                self.user_devices.delete_invalid_tokens(invalid_tokens)
            except FirebaseError as e:
                logger.warning("Trip-ask push for trip %s failed: %s", trip_id, e)

        # Private — only the chosen recipients, not the whole group room.
        for recipient_id in recipient_ids:
            self._emit_user(
                "trip.asked",
                {"group_id": shopping_list.group_id, "list_id": shopping_list.list_id,
                 "actor_user_id": user_id, "trip_id": trip.trip_id,
                 "buyer_name": buyer.first_name,
                 "message": f"Want anything added to '{shopping_list.name}'?"},
                user_id=recipient_id,
            )
        return {"asked": recipient_ids, "notified_devices": sent}

    def complete_trip(self, *, user_id, trip_id):
        """US-38: closing the trip closes out whatever's been bought on
        its list — the same effect as calling complete_list directly
        (US-15), reached through the buyer lock instead.

        Delegates the actual closing to complete_list (which finds this
        exact trip via get_active_by_list and marks it completed itself)
        rather than marking the trip completed here first — complete_list
        wouldn't recognize an already-completed trip as "the" trip to
        close, and a second one would get created for it instead.
        """
        if not _is_uuid(trip_id):
            raise FacadeError("Trip not found", status=404)

        trip = self.trips.get_by_id(trip_id)
        if not trip:
            raise FacadeError("Trip not found", status=404)
        if trip.buyer_id != user_id:
            raise FacadeError("Only the buyer can complete this trip", status=403)

        list_result = self.complete_list(user_id=user_id, list_id=trip.list_id)
        updated_trip = self.trips.get_by_id(trip_id)
        group_id = list_result["group_id"]
        self._emit_group(
            "trip.completed",
            {"group_id": group_id, "list_id": trip.list_id, "actor_user_id": user_id,
             "trip": updated_trip.to_dict(), "list": list_result},
            group_id=group_id,
        )
        return {"trip": updated_trip.to_dict(), "list": list_result}

    # ── GET active trip for a list — lets the client discover a trip_id
    # to address heading-out/ask without threading it through every screen
    def get_active_trip(self, *, user_id, list_id):
        if not _is_uuid(list_id):
            raise FacadeError("List not found", status=404)
        shopping_list = self.lists.get_by_id(list_id)
        if not shopping_list:
            raise FacadeError("List not found", status=404)
        self._require_membership(user_id=user_id, group_id=shopping_list.group_id)

        trip = self.trips.get_active_by_list(list_id)
        return trip.to_dict() if trip else None

    def cancel_trip(self, *, user_id, trip_id):
        if not _is_uuid(trip_id):
            raise FacadeError("Trip not found", status=404)

        trip = self.trips.get_by_id(trip_id)
        if not trip:
            raise FacadeError("Trip not found", status=404)
        if trip.buyer_id != user_id:
            raise FacadeError("Only the buyer can cancel this trip", status=403)

        updated = self.trips.set_status(trip_id, "cancelled")
        result = updated.to_dict()
        shopping_list = self.lists.get_by_id(trip.list_id)
        self._emit_group(
            "trip.cancelled",
            {"group_id": shopping_list.group_id, "list_id": trip.list_id,
             "actor_user_id": user_id, "trip": result},
            group_id=shopping_list.group_id,
        )
        return result

    # ── History screen's "الرحلات" (previous trips) tab ───────
    def _serialize_trip_history(self, trips):
        """Shared per-trip serialization for trip-history listings: buyer
        name plus the full per-item objects actually bought (not just
        names), so the app can e.g. re-add a past trip's items to the
        current list with sensible quantity/unit defaults.

        Each item is tagged with the trip that claimed it (ListItem.trip_id),
        so ItemRepository.list_by_trip_id scopes correctly to just this trip
        even though a list is a single persistent container reused trip
        after trip (see ListFacadeMixin.complete_list).
        """
        buyers = {
            u.user_id: u
            for u in self.users.get_by_ids([t.buyer_id for t in trips])
        }

        result = []
        for trip in trips:
            buyer = buyers.get(trip.buyer_id)
            bought_items = self.items.list_by_trip_id(trip.trip_id)
            result.append({
                "trip_id": trip.trip_id,
                "list_id": trip.list_id,
                "buyer_id": trip.buyer_id,
                "buyer_name": (
                    f"{buyer.first_name} {buyer.last_name}" if buyer else "Unknown"
                ),
                "completed_at": trip.completed_at.isoformat() if trip.completed_at else None,
                "item_count": len(bought_items),
                "items": [
                    {
                        "item_id": item.item_id,
                        "name": item.name,
                        "quantity": item.quantity,
                        "unit": item.unit,
                        "category_id": item.category_id,
                    }
                    for item in bought_items
                ],
            })
        return result

    def list_list_trips(self, *, user_id, list_id):
        """Every completed trip for a single list, newest first — the
        list-scoped replacement for the old group-scoped history tab. A
        trip belongs to the list it was generated from, so history is
        scoped to the list, not the whole group."""
        if not _is_uuid(list_id):
            raise FacadeError("List not found", status=404)
        shopping_list = self.lists.get_by_id(list_id)
        if not shopping_list:
            raise FacadeError("List not found", status=404)
        self._require_membership(user_id=user_id, group_id=shopping_list.group_id)

        trips = self.trips.list_completed_for_list(list_id)
        return self._serialize_trip_history(trips)
