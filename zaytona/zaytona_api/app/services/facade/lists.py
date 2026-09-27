"""List Management mixin — US-13, US-14, US-15.

Requires `self.groups` (GroupRepository) and `self.lists` (ListRepository)
from the composed facade, plus GuardsMixin's `_require_membership` /
`_require_admin`.
"""
from app.models.shopping_list import ShoppingList
from app.services.facade.errors import FacadeError
from app.utils.util import _is_uuid


class ListFacadeMixin:
    # ── US-13 : create a shopping list inside a group ────────
    def create_list(self, *, user_id, group_id, name):
        """Create a new shopping list.

        Authorization:
          * Caller must be a member of the group (any role).
          * Admin check is NOT required — any member can propose a list.

        Validation:
          * group_id must exist and be a valid UUID.
          * name must be non-empty.
          * Default (individual) groups are capped at 5 lists (per documentation).

        Raises:
            FacadeError 409: if the default group already has 5 lists.

        """
        if not _is_uuid(group_id):
            raise FacadeError("Group not found", status=404)
        group = self.groups.get_by_id(group_id)
        if not group:
            raise FacadeError("Group not found", status=404)

        # Verify membership (any role) — raises 403 if not a member
        self._require_membership(user_id=user_id, group_id=group_id)

        if not name or not name.strip():
            raise FacadeError("List name is required", status=400)

        # ── Enforce the 5-list cap on default (individual) groups ──
        # Per documentation: "Default group is capped at 5 lists". Shared
        # (household) groups are the premium tier and have no cap.
        if group.type == "individual":
            existing = self.lists.list_for_group(group_id)
            if len(existing) >= 5:
                raise FacadeError(
                    "Default group is limited to 5 lists. "
                    "Upgrade to premium for more.",
                            status=409,
                        )

        shopping_list = self.lists.create(
            name=name.strip(),
            group_id=group_id,
            created_by=user_id,
        )
        result = shopping_list.to_dict()
        self._emit_group(
            "list.created",
            {"group_id": group_id, "actor_user_id": user_id, "list": result},
            group_id=group_id,
        )
        return result

    # ── GET /lists/ : list all lists for a group ─────────────
    def list_group_lists(self, *, user_id, group_id, status=None):
        """Return all lists for a group the caller belongs to.

        Authorization: caller must be a member of the group.
        """
        self._require_membership(user_id=user_id, group_id=group_id)
        lists = self.lists.list_for_group(group_id, status=status)
        counts = self.items.counts_for_lists([lst.list_id for lst in lists])
        empty = {"item_count": 0, "bought_count": 0, "urgent_count": 0}
        return [
            {**lst.to_dict(), **counts.get(lst.list_id, empty)}
            for lst in lists
        ]

    # ── GET /lists/<id> : single list detail ─────────────────
    def get_list(self, *, user_id, list_id):
        """Return a single list with its details.

        Authorization: caller must be a member of the list's group.
        """
        if not _is_uuid(list_id):
            raise FacadeError("List not found", status=404)
        shopping_list = self.lists.get_by_id(list_id)
        if not shopping_list:
            raise FacadeError("List not found", status=404)

        # Verify membership in the list's group
        self._require_membership(user_id=user_id, group_id=shopping_list.group_id)
        return shopping_list.to_dict()

    # ── US-14 : admin edits list name / accent colour ────────
    def update_list(self, *, user_id, list_id, name=None, color=None):
        """Update a list's name and/or accent colour. Admin-only operation.

        Authorization:
          * Caller must be admin of the list's group.
        """
        if not _is_uuid(list_id):
            raise FacadeError("List not found", status=404)
        shopping_list = self.lists.get_by_id(list_id)
        if not shopping_list:
            raise FacadeError("List not found", status=404)

        # Admin check — uses the list's group_id
        self._require_admin(user_id=user_id, group_id=shopping_list.group_id)

        if name is not None and not name.strip():
            raise FacadeError("List name cannot be empty", status=400)

        if color is not None and color not in ShoppingList.ALLOWED_COLORS:
            raise FacadeError(
                f"color must be one of: {', '.join(ShoppingList.ALLOWED_COLORS)}", status=400
            )

        updated = self.lists.update(
            list_id, name=name.strip() if name else None, color=color
        )
        result = updated.to_dict()
        self._emit_group(
            "list.updated",
            {"group_id": shopping_list.group_id, "actor_user_id": user_id, "list": result},
            group_id=shopping_list.group_id,
        )
        return result

    # ── delete the whole list (admin-only) ────────────────────
    def delete_list(self, *, user_id, list_id):
        """Delete a list outright. Reuses remove_group_list's admin check
        and cascade behavior rather than duplicating it — a list always
        belongs to exactly one group, so this just resolves group_id and
        delegates."""
        if not _is_uuid(list_id):
            raise FacadeError("List not found", status=404)
        shopping_list = self.lists.get_by_id(list_id)
        if not shopping_list:
            raise FacadeError("List not found", status=404)

        self.remove_group_list(user_id=user_id, group_id=shopping_list.group_id, list_id=list_id)

    # ── US-15 : buyer closes out the current shopping trip ───
    def complete_list(self, *, user_id, list_id):
        """Close out whatever's been bought on this list into a
        completed Trip.

        Authorization:
          * Caller must be a member of the list's group.
          * No admin role required — any member (the "buyer") can close it.

        The list itself is a single persistent container reused trip
        after trip — it's never marked "completed" and never replaced
        with a new one. Closing a trip means: every bought-but-unclaimed
        item on the list gets attributed to a completed Trip record (so
        it shows up in the History screen's "الرحلات" tab via
        ItemRepository.list_by_trip_id), where it stays until the 7-day
        retention sweep removes it (app/tasks/retention.py). Unbought
        items are simply left where they are — that's the list's
        "current" state, with nothing further to do to them here.

        Idempotent — calling this with nothing bought and no trip
        already in progress is a no-op.
        """
        if not _is_uuid(list_id):
            raise FacadeError("List not found", status=404)
        shopping_list = self.lists.get_by_id(list_id)
        if not shopping_list:
            raise FacadeError("List not found", status=404)

        # Any member can close — not admin-only
        self._require_membership(user_id=user_id, group_id=shopping_list.group_id)

        # An in-progress trip (US-38's buyer-assignment flow) always
        # takes priority over creating a new one, whether or not it's
        # already been flipped to "completed" by complete_trip calling
        # in here — see TripFacadeMixin.complete_trip, which closes the
        # list before marking the trip completed for exactly this reason.
        trip = self.trips.get_active_by_list(list_id)
        unclaimed = self.items.list_unclaimed_bought(list_id)
        if not trip and not unclaimed:
            # Nothing bought since the last trip closed — nothing to do.
            result = shopping_list.to_dict()
            result["new_list"] = None
            return result

        if not trip:
            trip = self.trips.create(list_id=list_id, buyer_id=user_id)
        if unclaimed:
            self.items.claim_for_trip(list_id=list_id, trip_id=trip.trip_id)
        if trip.status != "completed":
            self.trips.set_status(trip.trip_id, "completed")

        result = shopping_list.to_dict()
        result["new_list"] = None
        self._emit_group(
            "list.completed",
            {"group_id": shopping_list.group_id, "actor_user_id": user_id, "list": result},
            group_id=shopping_list.group_id,
        )
        return result
