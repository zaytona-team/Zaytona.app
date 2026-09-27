"""Item Management mixin — US-16, US-17, US-21, US-22, US-23, US-25, US-26.

Requires `self.lists` (ListRepository), `self.items` (ItemRepository),
`self.history` (HistoryRepository), `self.trips` (TripRepository),
`self.user_devices` (UserDeviceRepository), `self.notifications`
(FirebaseProvider), and `self.storage` (SupabaseStorageProvider) from
the composed facade, plus GuardsMixin's `_require_membership`.
"""
import logging

from app.extensions import db
from app.models.item import Item
from app.models.list_item import ALLOWED_UNITS
from app.services.facade.errors import FacadeError
from app.utils.util import _is_uuid
from app.services.providers.firebase_provider import FirebaseError
from app.services.providers.supabase_storage_provider import StorageError

logger = logging.getLogger("zaytona.facade")

# US-21: custom item photo upload — Flutter enforces the same limits
# client-side before it ever sends the request.
ALLOWED_IMAGE_TYPES = {
    "image/jpeg": "jpg",
    "image/png": "png",
    "image/webp": "webp",
}
MAX_IMAGE_BYTES = 5 * 1024 * 1024  # 5 MB


class ItemFacadeMixin:
    # ── shared: reject a client-supplied catalog/category ID that isn't
    # a real row before it ever reaches the DB as an FK, so a bad ID is a
    # clean 400/404 instead of an unhandled IntegrityError at commit time
    def _validate_item_id(self, item_id):
        if item_id is None:
            return
        if not _is_uuid(item_id) or db.session.get(Item, item_id) is None:
            raise FacadeError("item_id does not match a known catalog item", status=400)

    def _validate_category_id(self, category_id):
        if category_id is None:
            return
        if not _is_uuid(category_id) or self.categories.get_by_id(category_id) is None:
            raise FacadeError("category_id does not match a known category", status=400)

    # ── search item for a catalog ─────────────────────────────────
    def search_catalog(self, *, query: str, limit: int = 20) -> list[dict]:
        """Search the product catalog for matching items.
        
        Args:
            query: Search term (product name or brand)
            limit: Maximum number of results to return
            
        Returns:
            List of catalog items as dictionaries
            
        Raises:
            FacadeError: If query is too short
        """
        if not query or len(query.strip()) < 2:
            return []
        
        results = self.items.search_catalog(query=query.strip(), limit=limit)
        return [item.to_dict() for item in results]

    def get_catalog_by_id(self, *, item_id: str) -> dict | None:
        """Retrieve a catalog item by its UUID.
        
        Args:
            item_id: The catalog item UUID
            
        Returns:
            Catalog item as dictionary, or None if not found
        """
        item = self.items.get_catalog_by_id(item_id)
        if not item:
            return None
        return item.to_dict()

    # ── GET items for a list ─────────────────────────────────
    def get_list_items(self, *, user_id, list_id, is_bought=None):
        """Return all items for a shopping list.

        Authorization: caller must be a member of the list's group.

        Args:
            is_bought: If True, return only bought items.
                       If False, return only unbought items.
                       If None, return all items.
        """
        if not _is_uuid(list_id):
            raise FacadeError("List not found", status=404)

        shopping_list = self.lists.get_by_id(list_id)
        if not shopping_list:
            raise FacadeError("List not found", status=404)

        self._require_membership(user_id=user_id, group_id=shopping_list.group_id)

        items = self.items.list_by_list_id(list_id, is_bought=is_bought)
        return [item.to_dict() for item in items]

    # ── US-16, US-21, US-22: Add an item to a list ──────────
    def add_list_item(self, *, user_id, list_id, name, quantity=1.0, unit="pcs",
                      category_id=None, notes=None, is_urgent=False, item_id=None,
                      image_url=None, brand=None):
        """US-16, US-21, US-22: Add an item to a shopping list.

        Validation:
          * Caller must be a member of the list's group.
          * quantity > 0.
          * unit must be in ALLOWED_UNITS.
          * name must not be empty.

        US-25 (Duplicate Prevention):
          * Checks for an active item with the same name and unit.
          * If one exists, merges into it (quantity += requested quantity)
            instead of creating a second row — this was previously a
            warning-only, non-blocking check, which is exactly why the
            same name kept producing separate rows instead of one updated
            quantity. A name match with a *different* unit still creates a
            new row (summing across units, e.g. "2 kg" + "1 pcs", isn't
            meaningful) but still carries the warning flag.
        """
        # 1. Validate list_id format
        if not _is_uuid(list_id):
            raise FacadeError("List not found", status=404)

        # 2. Verify list exists
        shopping_list = self.lists.get_by_id(list_id)
        if not shopping_list:
            raise FacadeError("List not found", status=404)

        # 3. Authorization: Must be a member of the group
        self._require_membership(user_id=user_id, group_id=shopping_list.group_id)

        # 4. Validation
        if not name or not name.strip():
            raise FacadeError("Item name is required", status=400)
        if quantity <= 0:
            raise FacadeError("Quantity must be greater than 0", status=400)
        if unit not in ALLOWED_UNITS:
            raise FacadeError(f"Unit must be one of: {', '.join(ALLOWED_UNITS)}", status=400)

        # Validate category_id only (not item_id, since it may be created later)
        self._validate_category_id(category_id)

        # 5. Catalog integration: Get or create catalog item
        catalog_item = None
        if item_id:
            # If item_id provided, verify it exists
            catalog_item = self.items.get_catalog_by_id(item_id)
            if not catalog_item:
                raise FacadeError("Catalog item not found", status=404)
        else:
            # If no item_id, search or create in catalog
            catalog_item = self.items.get_or_create_catalog_item(
                name=name.strip(),
                brand=brand,
                image_url=image_url,
                default_category_id=category_id,
            )
            item_id = catalog_item.item_id

        # 6. US-25: Duplicate check (ONE TIME ONLY, after catalog integration)
        duplicate = self.items.check_duplicate_active(list_id, name.strip())
        is_duplicate = duplicate is not None

        # 6b. Same name + same unit: merge instead of creating a second
        # row. (Different unit still counts as a duplicate warning below,
        # but isn't safe to merge — the quantities aren't comparable.)
        if duplicate is not None and duplicate.unit == unit:
            merged = self.items.update(
                duplicate.list_item_id, quantity=duplicate.quantity + float(quantity)
            )
            self.history.create(
                list_id=list_id,
                list_item_id=merged.list_item_id,
                user_id=user_id,
                action="updated",
                metadata={"name": merged.name, "quantity": merged.quantity, "merged_add": float(quantity)},
            )
            self._notify_trip_buyer_of_new_item(
                list_id=list_id, group_id=shopping_list.group_id, added_by=user_id, item=merged
            )
            result = merged.to_dict()
            result["is_duplicate_warning"] = True
            self._emit_group(
                "item.updated",
                {"group_id": shopping_list.group_id, "list_id": list_id,
                 "actor_user_id": user_id, "item": result},
                group_id=shopping_list.group_id,
            )
            return result

        # 7. Create the list item with catalog linkage
        new_item = self.items.create(
            list_id=list_id,
            item_id=item_id,
            category_id=category_id,
            name=name.strip(),
            brand=brand or (catalog_item.brand if catalog_item else None),
            quantity=float(quantity),
            unit=unit,
            notes=notes,
            is_urgent=bool(is_urgent),
            image_url=image_url or (catalog_item.image_url if catalog_item else None),
            added_by=user_id,
        )

        # 8. Record in history
        self.history.create(
            list_id=list_id,
            list_item_id=new_item.list_item_id,
            user_id=user_id,
            action="created",
            metadata={"name": new_item.name},
        )

        # 9. Notify trip buyer (if applicable)
        self._notify_trip_buyer_of_new_item(
            list_id=list_id, group_id=shopping_list.group_id, added_by=user_id, item=new_item
        )

        # 10. Build response with duplicate warning flag
        result = new_item.to_dict()
        result["is_duplicate_warning"] = is_duplicate

        self._emit_group(
            "item.added",
            {"group_id": shopping_list.group_id, "list_id": list_id,
             "actor_user_id": user_id, "item": result},
            group_id=shopping_list.group_id,
        )
        return result

    # ── notify the active trip's buyer that someone else added an item ──
    def _notify_trip_buyer_of_new_item(self, *, list_id, group_id, added_by, item):
        trip = self.trips.get_active_by_list(list_id)
        if not trip or trip.buyer_id == added_by:
            return

        tokens = self.user_devices.list_tokens_for_users([trip.buyer_id])
        if not tokens:
            return

        try:
            _sent, invalid_tokens = self.notifications.send_to_tokens(
                tokens,
                title="Item added to your list",
                body=f"{item.name} was added while you're out shopping.",
                data={
                    "list_id": list_id,
                    "group_id": group_id,
                    "trip_id": trip.trip_id,
                    "list_item_id": item.list_item_id,
                },
            )
            self.user_devices.delete_invalid_tokens(invalid_tokens)
        except FirebaseError as e:
            logger.warning("Push to trip buyer %s failed: %s", trip.buyer_id, e)

    # ── Update an existing list item ─────────────────────────
    def update_list_item(self, *, user_id, list_item_id, name=None, quantity=None,
                         unit=None, category_id=None, notes=None, is_urgent=None):
        """Update an existing list item.

        Authorization: Caller must be a member of the list's group.
        """
        if not _is_uuid(list_item_id):
            raise FacadeError("Item not found", status=404)

        list_item = self.items.get_by_id(list_item_id)
        if not list_item:
            raise FacadeError("Item not found", status=404)

        # Fetch the parent list to check group membership
        shopping_list = self.lists.get_by_id(list_item.list_id)
        if not shopping_list:
            raise FacadeError("List not found", status=404)
        self._require_membership(user_id=user_id, group_id=shopping_list.group_id)

        # Validation for updated fields
        if quantity is not None and quantity <= 0:
            raise FacadeError("Quantity must be greater than 0", status=400)
        if unit is not None and unit not in ALLOWED_UNITS:
            raise FacadeError(f"Unit must be one of: {', '.join(ALLOWED_UNITS)}", status=400)
        if name is not None and not name.strip():
            raise FacadeError("Item name cannot be empty", status=400)
        self._validate_category_id(category_id)

        update_fields = {}
        if name is not None: update_fields["name"] = name.strip()
        if quantity is not None: update_fields["quantity"] = float(quantity)
        if unit is not None: update_fields["unit"] = unit
        if category_id is not None: update_fields["category_id"] = category_id
        if notes is not None: update_fields["notes"] = notes
        if is_urgent is not None: update_fields["is_urgent"] = bool(is_urgent)

        updated = self.items.update(list_item_id, **update_fields)

        self.history.create(
            list_id=updated.list_id,
            list_item_id=updated.list_item_id,
            user_id=user_id,
            action="updated",
            metadata={**update_fields, "name": updated.name},
        )

        result = updated.to_dict()
        self._emit_group(
            "item.updated",
            {"group_id": shopping_list.group_id, "list_id": updated.list_id,
             "actor_user_id": user_id, "item": result},
            group_id=shopping_list.group_id,
        )
        return result

    # ── Delete a single item from a list ─────────────────────
    def delete_list_item(self, *, user_id, list_item_id):
        """Delete a single item from a list."""
        if not _is_uuid(list_item_id):
            raise FacadeError("Item not found", status=404)

        list_item = self.items.get_by_id(list_item_id)
        if not list_item:
            raise FacadeError("Item not found", status=404)

        # Fetch the parent list to check group membership
        shopping_list = self.lists.get_by_id(list_item.list_id)
        if not shopping_list:
            raise FacadeError("List not found", status=404)
        self._require_membership(user_id=user_id, group_id=shopping_list.group_id)

        # Snapshot before delete: once gone, the FK can no longer describe
        # which item this was, so the name travels in metadata instead.
        snapshot = {"name": list_item.name, "quantity": list_item.quantity, "unit": list_item.unit}
        self.items.delete(list_item_id)
        self.history.create(
            list_id=shopping_list.list_id,
            user_id=user_id,
            action="deleted",
            metadata=snapshot,
        )
        self._emit_group(
            "item.deleted",
            {"group_id": shopping_list.group_id, "list_id": shopping_list.list_id,
             "actor_user_id": user_id, "list_item_id": list_item_id},
            group_id=shopping_list.group_id,
        )
        return {"message": "Item deleted"}

    # ── US-23: Bulk delete all items from a list ─────────────
    def bulk_delete_list_items(self, *, user_id, list_id):
        """US-23: Bulk delete all items from a list."""
        if not _is_uuid(list_id):
            raise FacadeError("List not found", status=404)

        shopping_list = self.lists.get_by_id(list_id)
        if not shopping_list:
            raise FacadeError("List not found", status=404)

        self._require_membership(user_id=user_id, group_id=shopping_list.group_id)

        snapshots = [
            {"name": item.name, "quantity": item.quantity, "unit": item.unit}
            for item in self.items.list_by_list_id(list_id)
        ]
        deleted_count = self.items.bulk_delete_by_list(list_id)
        self.history.create(
            list_id=list_id,
            user_id=user_id,
            action="deleted",
            metadata={"items": snapshots, "count": deleted_count},
        )
        self._emit_group(
            "item.bulk_deleted",
            {"group_id": shopping_list.group_id, "list_id": list_id,
             "actor_user_id": user_id, "deleted_count": deleted_count},
            group_id=shopping_list.group_id,
        )
        return {"message": f"Deleted {deleted_count} items"}

    def _guard_item_purchase_toggle(self, *, user_id, list_item_id):
        """Shared checks for both marking and unmarking an item bought:
        item/list must exist, caller must belong to the group, and while a
        trip is active only its buyer may toggle items — the "lock" the
        Trip model's docstring promises, so two members can't race to buy
        (or un-buy) the same item at once. Returns (list_item, shopping_list)
        — callers need the latter's group_id to emit a real-time event.
        """
        if not _is_uuid(list_item_id):
            raise FacadeError("Item not found", status=404)

        list_item = self.items.get_by_id(list_item_id)
        if not list_item:
            raise FacadeError("Item not found", status=404)

        shopping_list = self.lists.get_by_id(list_item.list_id)
        if not shopping_list:
            raise FacadeError("List not found", status=404)
        self._require_membership(user_id=user_id, group_id=shopping_list.group_id)

        active_trip = self.trips.get_active_by_list(shopping_list.list_id)
        if active_trip and active_trip.buyer_id != user_id:
            raise FacadeError(
                "Only the trip's buyer can check off items during an active trip", status=403
            )
        return list_item, shopping_list

    # ── US-26: Mark an item as bought ────────────────────────
    def mark_item_purchased(self, *, user_id, list_item_id):
        """US-26: Mark an item as bought.

        Idempotent: repeated taps on an already-bought item (a double
        tap before the UI catches up, or a retried request) are a
        no-op — no duplicate "consumed" entry, no bought_by overwrite.
        Only an actual false->true flip is history-worthy.
        """
        list_item, shopping_list = self._guard_item_purchase_toggle(
            user_id=user_id, list_item_id=list_item_id
        )
        if list_item.is_bought:
            return list_item.to_dict()

        updated = self.items.mark_purchased(list_item_id, bought_by=user_id)

        self.history.create(
            list_id=updated.list_id,
            list_item_id=updated.list_item_id,
            user_id=user_id,
            action="consumed",
            metadata={"name": updated.name},
        )

        result = updated.to_dict()
        self._emit_group(
            "item.purchased",
            {"group_id": shopping_list.group_id, "list_id": updated.list_id,
             "actor_user_id": user_id, "item": result},
            group_id=shopping_list.group_id,
        )
        return result

    # ── Undo a bought mark — the buying view's checkbox is a toggle,
    # not a one-way action, so unchecking it must be reversible too.
    # Idempotent the same way mark_item_purchased is: only a true->false
    # flip is history-worthy.
    def unmark_item_purchased(self, *, user_id, list_item_id):
        list_item, shopping_list = self._guard_item_purchase_toggle(
            user_id=user_id, list_item_id=list_item_id
        )
        if not list_item.is_bought:
            return list_item.to_dict()

        updated = self.items.mark_unpurchased(list_item_id)

        self.history.create(
            list_id=updated.list_id,
            list_item_id=updated.list_item_id,
            user_id=user_id,
            action="restocked",
            metadata={"name": updated.name},
        )

        result = updated.to_dict()
        self._emit_group(
            "item.unpurchased",
            {"group_id": shopping_list.group_id, "list_id": updated.list_id,
             "actor_user_id": user_id, "item": result},
            group_id=shopping_list.group_id,
        )
        return result

    # ── US-21: upload a custom photo for one list item ────────
    def upload_item_image(self, *, user_id, list_item_id, file_bytes, content_type):
        """Replaces the item's image_url with a freshly uploaded photo.

        Authorization: caller must be a member of the item's list's group
        (same rule as update_list_item — any member, not admin-only).

        Validation: content_type must be jpg/png/webp; file_bytes must be
        non-empty and <= 5MB. Both limits are enforced here, not just
        client-side, since the API layer only reads the multipart body —
        it doesn't itself decide what's acceptable.
        """
        if not _is_uuid(list_item_id):
            raise FacadeError("Item not found", status=404)
        list_item = self.items.get_by_id(list_item_id)
        if not list_item:
            raise FacadeError("Item not found", status=404)

        shopping_list = self.lists.get_by_id(list_item.list_id)
        if not shopping_list:
            raise FacadeError("List not found", status=404)
        self._require_membership(user_id=user_id, group_id=shopping_list.group_id)

        if not file_bytes:
            raise FacadeError("Image file is empty", status=400)
        if len(file_bytes) > MAX_IMAGE_BYTES:
            raise FacadeError("Image exceeds the 5MB limit", status=400)
        ext = ALLOWED_IMAGE_TYPES.get(content_type)
        if not ext:
            raise FacadeError(
                f"Unsupported image type: {content_type}. Allowed: "
                f"{', '.join(ALLOWED_IMAGE_TYPES)}",
                status=400,
            )

        try:
            public_url = self.storage.upload_item_image(
                item_id=list_item_id,
                file_bytes=file_bytes,
                content_type=content_type,
                ext=ext,
            )
        except StorageError as e:
            raise FacadeError(e.message, status=e.status) from e

        updated = self.items.update(list_item_id, image_url=public_url)

        self.history.create(
            list_id=updated.list_id,
            list_item_id=updated.list_item_id,
            user_id=user_id,
            action="updated",
            metadata={"image_url": public_url},
        )

        result = updated.to_dict()
        self._emit_group(
            "item.updated",
            {"group_id": shopping_list.group_id, "list_id": updated.list_id,
             "actor_user_id": user_id, "item": result},
            group_id=shopping_list.group_id,
        )
        return result

    # ── GET /users/me/items : this user's own "quick add" catalog ──
    def list_my_items(self, *, user_id):
        """Distinct items this user has personally added, across every
        group they belong to, most recently used first.

        Fully derived from list_items (added_by, name, brand,
        category_id, image_url, created_at) — no new table needed.
        "Distinct" follows the same same-item rule
        check_duplicate_active already uses elsewhere: same name,
        case-insensitive. Requires ix_list_items_added_by_name_created
        (added_by, lower(name), created_at desc) to stay fast at real
        volume — see item_repository.list_distinct_by_user.
        """
        return self.items.list_distinct_by_user(user_id)
