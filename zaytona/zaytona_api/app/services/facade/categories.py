"""Categories mixin — reference data (read only).

Requires `self.categories` (CategoryRepository) from the composed facade.
"""
from app.services.facade.errors import FacadeError
from app.utils.util import _is_uuid


class CategoryFacadeMixin:
    def list_categories(self):
        """Return all categories sorted by store aisle sequence (US-26).

        Used by:
          * GET /api/v1/categories/ — list all categories
          * Flutter app — populate category picker when adding items
        """
        return [c.to_dict() for c in self.categories.get_all(ordered=True)]

    def get_category(self, category_id: str):
        """Return a single category by id, or raise 404.

        Validation:
          * category_id must be a valid UUID format
          * category must exist in the database

        Raises:
            FacadeError: 404 if not found or invalid UUID
        """
        if not _is_uuid(category_id):
            raise FacadeError("Category not found", status=404)
        category = self.categories.get_by_id(category_id)
        if not category:
            raise FacadeError("Category not found", status=404)
        return category.to_dict()
