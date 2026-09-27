"""Repository for the SHOPPING_LIST table.

Encapsulates all SQLAlchemy access for shopping lists so the
facade/service layer never builds queries inline.

Used by:
  * Facade.create_list()        — US-13 (member creates a list)
  * Facade.list_group_lists()   — GET /lists/?group_id=...
  * Facade.get_list()           — GET /lists/<id>
  * Facade.update_list()        — US-14 (admin edits name)
  * Facade.complete_list()      — US-15 (buyer closes the list)
  * GroupRepository.delete_list — US-11 (admin removes from group)
"""
from datetime import datetime, timedelta, timezone

from app.extensions import db
from app.models.list_item import ListItem
from app.models.shopping_list import ShoppingList


class ListRepository:
    def create(self, *, name, group_id, created_by) -> ShoppingList:
        """Create a new active shopping list inside a group."""
        shopping_list = ShoppingList(
            name=name,
            group_id=group_id,
            created_by=created_by,
            status="active",
        )
        db.session.add(shopping_list)
        db.session.commit()
        return shopping_list

    def get_by_id(self, list_id: str) -> ShoppingList | None:
        """Return a single list by its UUID, or None."""
        return db.session.get(ShoppingList, list_id)

    def list_for_group(
        self,
        group_id: str,
        status: str | None = None,
    ) -> list[ShoppingList]:
        """Return all lists for a group, optionally filtered by status.

        Args:
            group_id: The group whose lists to fetch.
            status: If provided, filter by 'active' or 'completed'.
                    If None, return all.
        """
        query = db.session.query(ShoppingList).filter(
            ShoppingList.group_id == group_id
        )
        if status:
            query = query.filter(ShoppingList.status == status)
        return query.order_by(ShoppingList.created_at.desc()).all()

    def update(self, list_id: str, **fields) -> ShoppingList | None:
        """Update mutable fields of a list (name, image_url, etc).

        Returns None if the list does not exist.
        """
        shopping_list = self.get_by_id(list_id)
        if not shopping_list:
            return None
        for key, value in fields.items():
            if hasattr(shopping_list, key) and value is not None:
                setattr(shopping_list, key, value)
        db.session.commit()
        return shopping_list

    # ── 12h reminder sweep ────────────────────────────────────
    def list_due_for_reminder(self, interval: timedelta) -> list[ShoppingList]:
        """Lists with at least one unbought item, that either never got a
        reminder and were created at least `interval` ago, or whose last
        reminder was at least `interval` ago.

        Lists are never marked 'completed' (a list is one persistent
        container reused trip after trip — see ListFacadeMixin.complete_list)
        so "nothing left to remind about" can't be read off `status`
        anymore; it's determined directly by whether anything's still
        unbought.
        """
        threshold = datetime.now(timezone.utc) - interval
        has_unbought = (
            db.session.query(ListItem.list_item_id)
            .filter(ListItem.list_id == ShoppingList.list_id, ListItem.is_bought == False)
            .correlate(ShoppingList)
            .exists()
        )
        return (
            db.session.query(ShoppingList)
            .filter(has_unbought)
            .filter(
                db.or_(
                    db.and_(
                        ShoppingList.last_reminded_at.is_(None),
                        ShoppingList.created_at <= threshold,
                    ),
                    ShoppingList.last_reminded_at <= threshold,
                )
            )
            .all()
        )

    def mark_reminded(self, list_id: str) -> None:
        shopping_list = self.get_by_id(list_id)
        if not shopping_list:
            return
        shopping_list.last_reminded_at = datetime.now(timezone.utc)
        db.session.commit()
