"""Categories API namespace — read-only reference data.

Endpoints (all under /api/v1/categories):
  GET  /              list all categories (sorted by aisle sequence)
  GET  /<category_id> single category details

Categories are seeded once at deployment — no POST/PATCH/DELETE
endpoints are exposed. They're used to:
  * Group items in the catalog (US-18)
  * Organize the buying view by store aisle (US-26)

Authentication:
  * No JWT required — categories are public reference data
  * Not sensitive information
  * Reduces friction for the Flutter app

Authorization:
  * N/A — no write operations exist
  * If future admin endpoints are added, they must require JWT + admin role
"""
from flask_restx import Namespace, Resource, fields

from app.services.facade import get_facade, FacadeError

ns = Namespace("categories", description="Grocery categories (reference data)")


# ── Swagger response models ────────────────────────────────
category_model = ns.model(
    "Category",
    {
        "category_id": fields.String(
            required=True,
            example="3fa85f64-5717-4562-b3fc-2c963f66afa6",
        ),
        "name": fields.String(required=True, example="Fresh Produce"),
        "image_url": fields.String(
            required=False,
            example="https://.../produce.png",
        ),
        "sort_order": fields.Integer(required=True, example=1),
    },
)


def _handle(fn):
    """Map FacadeError to a clean HTTP error."""
    try:
        return fn()
    except FacadeError as e:
        ns.abort(e.status, e.message)


# ── GET /categories/ ───────────────────────────────────────
@ns.route("/")
class CategoriesList(Resource):
    @ns.marshal_list_with(category_model)
    @ns.response(200, "List of all categories (sorted by aisle sequence)")
    def get(self):
        """Return all 16 default grocery categories.

        Sorted by sort_order (store aisle sequence) then by name.
        No authentication required — public reference data.
        """
        facade = get_facade()
        return facade.list_categories(), 200


# ── GET /categories/<id> ───────────────────────────────────
@ns.route("/<string:category_id>")
@ns.param("category_id", "The category UUID")
class CategoryDetail(Resource):
    @ns.marshal_with(category_model)
    @ns.response(200, "Category details")
    @ns.response(404, "Category not found")
    def get(self, category_id):
        """Return a single category by its UUID.

        Returns 404 if:
          * category_id is not a valid UUID format
          * category does not exist in the database
        """
        facade = get_facade()
        result = _handle(lambda: facade.get_category(category_id))
        return result, 200