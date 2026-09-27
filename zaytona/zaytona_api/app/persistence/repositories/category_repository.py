"""Repository for the CATEGORY reference table.

Categories are read-only — this repository only exposes query methods.
No create/update/delete since categories are seeded once at deployment
and managed as a fixed system enum (per documentation).

Used by:
  * Facade.list_categories() — GET /api/v1/categories/
  * Facade.get_category(id)  — GET /api/v1/categories/<id>
  * (Future) Item creation   — validate category_id exists
"""
from app.extensions import db
from app.models.category import Category


class CategoryRepository:
    def get_all(self, ordered: bool = True) -> list[Category]:
        """Return all categories.

        Args:
            ordered: If True, sort by sort_order (store aisle sequence),
                     then by name alphabetically as tiebreaker.

        Returns:
            List of Category objects.
        """
        query = db.session.query(Category)
        if ordered:
            query = query.order_by(Category.sort_order, Category.name)
        return query.all()

    def get_by_id(self, category_id: str) -> Category | None:
        """Return a single category by its UUID, or None if not found."""
        return db.session.get(Category, category_id)

    def get_by_name(self, name: str) -> Category | None:
        """Return a category by name (case-insensitive), or None.

        Useful for deduplication in seed scripts and future admin tools.
        """
        return (
            db.session.query(Category)
            .filter(db.func.lower(Category.name) == name.lower())
            .first()
        )
