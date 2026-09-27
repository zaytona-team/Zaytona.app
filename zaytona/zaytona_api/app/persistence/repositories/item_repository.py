"""Repository for LIST_ITEM operations.

Encapsulates all SQLAlchemy access for items on shopping lists.
"""
from app.utils.text_utils import normalize_arabic_text
from app.extensions import db
from app.models.list_item import ListItem
from app.models.item import Item


class ItemRepository:
        # ─ Catalog Operations (items table) ───────────────────

    def get_or_create_catalog_item(self, *, name, brand=None, image_url=None, 
                                    default_category_id=None, barcode=None) -> Item:
        """Search for an item in the catalog, or create it if not found.
        
        Matches by name (case-insensitive) and optionally by brand.
        If brand is provided, matches exactly; if None, matches items with no brand.
        """
        # Search by name (case-insensitive)
        query = db.session.query(Item).filter(
            db.func.lower(Item.name) == name.lower()
        )
        
        # Match by brand if provided, otherwise match items without brand
        if brand:
            query = query.filter(db.func.lower(Item.brand) == brand.lower())
        else:
            query = query.filter(Item.brand.is_(None))
        
        existing = query.first()
        
        if existing:
            return existing
        
        # Not found, create new catalog item
        new_item = Item(
            name=name,
            brand=brand,
            image_url=image_url,
            default_category_id=default_category_id,
            barcode=barcode,
        )
        db.session.add(new_item)
        db.session.commit()
        return new_item

    def search_catalog(self, query: str, limit: int = 20) -> list[Item]:
        """Search the catalog and return all available brands.
        
        Performs case-insensitive search on both name and brand fields.
        Results are ordered by name, then brand (nulls last).
        """
        clean_query = normalize_arabic_text(query)
        if not clean_query:
            return []
        search_term = f"%{clean_query}%"
        return (
            db.session.query(Item)
            .filter(
                db.or_(
                    Item.name.ilike(search_term),
                    Item.brand.ilike(search_term),
                )
            )
            .order_by(Item.name.asc(), Item.brand.asc().nullslast())
            .limit(limit)
            .all()
        )

    def get_catalog_by_id(self, item_id: str) -> Item | None:
        """Retrieve a catalog item by its UUID."""
        return db.session.get(Item, item_id)

    def list_catalog_by_name(self, name: str) -> list[Item]:
        """Retrieve all brands for a specific product name.
        
        Example: If name="Milk", returns all milk brands (Marai, Nadec, etc.)
        ordered by brand name with null brands at the end.
        """
        return (
            db.session.query(Item)
            .filter(db.func.lower(Item.name) == name.lower())
            .order_by(Item.brand.asc().nullslast())
            .all()
        )

    def create(self, **kwargs) -> ListItem:
        """Create a new list item."""
        list_item = ListItem(**kwargs)
        db.session.add(list_item)
        db.session.commit()
        return list_item

    def get_by_id(self, list_item_id: str) -> ListItem | None:
        return db.session.get(ListItem, list_item_id)

    def list_by_list_id(self, list_id: str, is_bought: bool | None = None) -> list[ListItem]:
        """Get all *current* items for a specific list, optionally filtered
        by bought status.

        Excludes items already claimed by a completed trip (trip_id set —
        see claim_for_trip) — those belong to trip/list history
        (list_by_trip_id, list_list_trips), not the active list view. A
        list is reused indefinitely across trips, so without this filter
        every item ever bought on it would keep showing here forever.
        """
        query = db.session.query(ListItem).filter(
            ListItem.list_id == list_id, ListItem.trip_id.is_(None)
        )
        if is_bought is not None:
            query = query.filter(ListItem.is_bought == is_bought)
        # Sort: urgent first, then by creation time
        return query.order_by(ListItem.is_urgent.desc(), ListItem.created_at.asc()).all()

    def update(self, list_item_id: str, **fields) -> ListItem | None:
        """Update mutable fields of a list item."""
        list_item = self.get_by_id(list_item_id)
        if not list_item:
            return None
        for key, value in fields.items():
            if hasattr(list_item, key) and value is not None:
                setattr(list_item, key, value)
        db.session.commit()
        return list_item

    def delete(self, list_item_id: str) -> bool:
        """Delete a single list item."""
        list_item = self.get_by_id(list_item_id)
        if not list_item:
            return False
        db.session.delete(list_item)
        db.session.commit()
        return True

    def bulk_delete_by_list(self, list_id: str) -> int:
        """Delete all items in a list. Returns the number of deleted rows."""
        deleted_count = db.session.query(ListItem).filter(ListItem.list_id == list_id).delete()
        db.session.commit()
        return deleted_count

    def mark_purchased(self, list_item_id: str, bought_by: str) -> ListItem | None:
        """Mark an item as bought and record who bought it."""
        list_item = self.get_by_id(list_item_id)
        if not list_item:
            return None
        list_item.is_bought = True
        list_item.bought_by = bought_by
        db.session.commit()
        return list_item

    def mark_unpurchased(self, list_item_id: str) -> ListItem | None:
        """Undo a bought mark — the buying view's checkbox is a toggle."""
        list_item = self.get_by_id(list_item_id)
        if not list_item:
            return None
        list_item.is_bought = False
        list_item.bought_by = None
        db.session.commit()
        return list_item

    def list_unclaimed_bought(self, list_id: str) -> list[ListItem]:
        """Bought items on this list not yet attributed to any trip —
        what ListFacadeMixin.complete_list bundles into the trip it's
        about to close."""
        return (
            db.session.query(ListItem)
            .filter(
                ListItem.list_id == list_id,
                ListItem.is_bought == True,
                ListItem.trip_id.is_(None),
            )
            .all()
        )

    def claim_for_trip(self, *, list_id: str, trip_id: str) -> int:
        """Attribute every currently-unclaimed bought item on this list
        to the trip that's closing — see list_unclaimed_bought. The list
        itself is never touched; only the items that were actually
        bought move into the trip's history."""
        claimed = (
            db.session.query(ListItem)
            .filter(
                ListItem.list_id == list_id,
                ListItem.is_bought == True,
                ListItem.trip_id.is_(None),
            )
            .update({ListItem.trip_id: trip_id}, synchronize_session=False)
        )
        db.session.commit()
        return claimed

    def list_by_trip_id(self, trip_id: str) -> list[ListItem]:
        """Everything bought during this specific trip — see
        claim_for_trip. The list a trip ran on is reused for later trips
        too, so this (not list_id + is_bought) is what scopes "what did
        this trip buy" to just this trip."""
        return (
            db.session.query(ListItem)
            .filter(ListItem.trip_id == trip_id)
            .order_by(ListItem.updated_at.asc())
            .all()
        )

    def delete_by_trip_id(self, trip_id: str) -> int:
        """Hard-delete every item claimed by this trip — called by the
        retention sweep (app/tasks/retention.py) right before the trip
        itself is deleted, so nothing is left dangling."""
        deleted = (
            db.session.query(ListItem)
            .filter(ListItem.trip_id == trip_id)
            .delete(synchronize_session=False)
        )
        db.session.commit()
        return deleted

    def counts_for_lists(self, list_ids: list[str]) -> dict[str, dict]:
        """One grouped query for the item/bought/urgent counts of each of
        `list_ids` — used by list_group_lists so the group view's list
        cards can show real progress without an N+1 query per list."""
        if not list_ids:
            return {}
        rows = (
            db.session.query(
                ListItem.list_id,
                db.func.count(ListItem.list_item_id),
                db.func.sum(db.case((ListItem.is_bought == True, 1), else_=0)),
                db.func.sum(
                    db.case(
                        (db.and_(ListItem.is_urgent == True, ListItem.is_bought == False), 1),
                        else_=0,
                    )
                ),
            )
            .filter(ListItem.list_id.in_(list_ids))
            .group_by(ListItem.list_id)
            .all()
        )
        return {
            list_id: {
                "item_count": total,
                "bought_count": int(bought or 0),
                "urgent_count": int(urgent or 0),
            }
            for list_id, total, bought, urgent in rows
        }

    def list_distinct_by_user(self, user_id: str) -> list[dict]:
        """GET /users/me/items — every distinct item this user has
        personally added across all their groups, most recently used
        first. "Distinct" = same rule check_duplicate_active already
        uses: same name, case-insensitive (so re-adding "Milk" and
        "milk" collapse into one entry, keeping whichever add was most
        recent).

        Ranks each added_by's rows per lower(name) by recency with
        ROW_NUMBER() OVER (...) and keeps rank 1 — deliberately not
        Postgres's DISTINCT ON, which would be a slightly more direct
        way to express this but isn't portable to sqlite, and every
        test in this suite runs against sqlite (see conftest.py's
        per-file TestConfig overrides). ROW_NUMBER() OVER is standard
        SQL, identical on both. Needs
        ix_list_items_added_by_name_created (added_by, lower(name),
        created_at desc) to stay an index scan on Postgres at real
        volume — added_by alone isn't indexed today.
        """
        rank = (
            db.func.row_number()
            .over(
                partition_by=db.func.lower(ListItem.name),
                order_by=ListItem.created_at.desc(),
            )
            .label("rn")
        )
        ranked = (
            db.session.query(
                ListItem.name,
                ListItem.category_id,
                ListItem.brand,
                ListItem.image_url,
                ListItem.created_at,
                rank,
            )
            .filter(ListItem.added_by == user_id)
            .subquery()
        )
        rows = (
            db.session.query(ranked)
            .filter(ranked.c.rn == 1)
            .order_by(ranked.c.created_at.desc())
            .all()
        )
        return [
            {
                "name": row.name,
                "category_id": str(row.category_id) if row.category_id else None,
                "brand": row.brand,
                "image_url": row.image_url,
                "last_used_at": row.created_at.isoformat() if row.created_at else None,
            }
            for row in rows
        ]

    def check_duplicate_active(self, list_id: str, name: str) -> ListItem | None:
        """US-25: Check if an active (not bought) item with the same name exists."""
        return (
            db.session.query(ListItem)
            .filter(
                ListItem.list_id == list_id,
                db.func.lower(ListItem.name) == name.lower(),
                ListItem.is_bought == False,
            )
            .first()
        )