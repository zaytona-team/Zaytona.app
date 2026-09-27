"""Items API namespace — managing items within shopping lists.

Endpoints (all under /api/v1/lists/<list_id>/items):
  POST   /                                Add item (US-16, US-21, US-22)
  GET    /                                List items in a list
  PATCH  /<item_id>                       Update item
  DELETE /<item_id>                       Delete single item
  DELETE /                                Bulk delete all items (US-23)
  PATCH  /<item_id>/purchase              Mark as bought (US-26)
  POST   /<item_id>/image                 Upload a custom photo (US-21)
"""
from flask import g, request
from flask_restx import Namespace, Resource, fields

from app.api.v1.security import jwt_required
from app.services.facade import get_facade, FacadeError
from app.models.list_item import ALLOWED_UNITS

ns = Namespace("items", description="Shopping list items management")

# Swagger Models
add_item_model = ns.model(
    "AddItemRequest",
    {
        "name": fields.String(required=True, example="Milk"),
        "quantity": fields.Float(required=False, example=2.0),
        "unit": fields.String(required=False, enum=ALLOWED_UNITS, example="L"),
        "category_id": fields.String(required=False, example="uuid-here"),
        "notes": fields.String(required=False, example="Full fat"),
        "is_urgent": fields.Boolean(required=False, example=False),
        "item_id": fields.String(required=False, example="uuid-here", description="If from catalog"),
        "image_url": fields.String(required=False, example="https://example.com/milk.png"),
        "brand": fields.String(required=False, example="Almarai"),
    },
)

update_item_model = ns.model(
    "UpdateItemRequest",
    {
        "name": fields.String(required=False, example="Milk"),
        "quantity": fields.Float(required=False, example=2.0),
        "unit": fields.String(required=False, enum=ALLOWED_UNITS, example="L"),
        "category_id": fields.String(required=False, example="uuid-here"),
        "notes": fields.String(required=False, example="Full fat"),
        "is_urgent": fields.Boolean(required=False, example=False),
    },
)

def _handle(fn):
    try:
        return fn()
    except FacadeError as e:
        ns.abort(e.status, e.message)

@ns.route("/<string:list_id>/items")
@ns.param("list_id", "The shopping list UUID")
class ListItemCollection(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.expect(add_item_model, validate=True)
    @ns.response(201, "Item added")
    @ns.response(400, "Validation error")
    @ns.response(403, "Not a member of the list's group")
    @ns.response(404, "List not found")
    def post(self, list_id):
        """US-16, US-21, US-22: Add an item to the list."""
        data = ns.payload
        facade = get_facade()
        result = _handle(
            lambda: facade.add_list_item(
                user_id=g.user_id,
                list_id=list_id,
                name=data["name"],
                quantity=data.get("quantity", 1.0),
                unit=data.get("unit", "pcs"),
                category_id=data.get("category_id"),
                notes=data.get("notes"),
                is_urgent=data.get("is_urgent", False),
                item_id=data.get("item_id"),
                image_url=data.get("image_url"),
                brand=data.get("brand"),
            )
        )
        # Return 209 Conflict if it's a duplicate warning, else 201
        status_code = 209 if result.get("is_duplicate_warning") else 201
        return result, status_code

    @ns.doc(security="Bearer")
    @jwt_required
    @ns.param("is_bought", "Filter by bought status: 'true' or 'false'", _in="query")
    @ns.response(200, "List of items")
    @ns.response(403, "Not a member of the list's group")
    def get(self, list_id):
        """Get all items in a list."""
        is_bought_param = request.args.get("is_bought")
        is_bought = None
        if is_bought_param == "true":
            is_bought = True
        elif is_bought_param == "false":
            is_bought = False

        facade = get_facade()

        from app.services.facade import _is_uuid
        if not _is_uuid(list_id):
            ns.abort(404, "List not found")
        
        # We'll add a facade method for this in the next step if needed, 
        # but for now, let's assume we add `get_list_items` to facade.
        return _handle(lambda: facade.get_list_items(user_id=g.user_id, list_id=list_id, is_bought=is_bought))

    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(200, "Items bulk deleted")
    @ns.response(403, "Not a member of the list's group")
    def delete(self, list_id):
        """US-23: Bulk delete all items in the list."""
        facade = get_facade()
        return _handle(lambda: facade.bulk_delete_list_items(user_id=g.user_id, list_id=list_id))


@ns.route("/<string:list_id>/items/<string:item_id>")
@ns.param("list_id", "The shopping list UUID")
@ns.param("item_id", "The list item UUID")
class ListItemDetail(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.expect(update_item_model, validate=True)
    @ns.response(200, "Item updated")
    @ns.response(400, "Validation error")
    @ns.response(403, "Not a member of the list's group")
    def patch(self, list_id, item_id):
        """Update an item's details."""
        data = ns.payload
        facade = get_facade()
        return _handle(
            lambda: facade.update_list_item(
                user_id=g.user_id,
                list_item_id=item_id,
                name=data.get("name"),
                quantity=data.get("quantity"),
                unit=data.get("unit"),
                category_id=data.get("category_id"),
                notes=data.get("notes"),
                is_urgent=data.get("is_urgent"),
            )
        )

    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(200, "Item deleted")
    @ns.response(403, "Not a member of the list's group")
    def delete(self, list_id, item_id):
        """Delete a single item."""
        facade = get_facade()
        return _handle(lambda: facade.delete_list_item(user_id=g.user_id, list_item_id=item_id))


@ns.route("/<string:list_id>/items/<string:item_id>/purchase")
@ns.param("list_id", "The shopping list UUID")
@ns.param("item_id", "The list item UUID")
class ItemPurchase(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(200, "Item purchase status updated")
    @ns.response(403, "Not a member of the list's group")
    def patch(self, list_id, item_id):
        """US-26: Mark an item as bought, or unmark it with {"is_bought": false}."""
        data = request.get_json(silent=True) or {}
        facade = get_facade()
        if data.get("is_bought", True):
            return _handle(lambda: facade.mark_item_purchased(user_id=g.user_id, list_item_id=item_id))
        return _handle(lambda: facade.unmark_item_purchased(user_id=g.user_id, list_item_id=item_id))


@ns.route("/<string:list_id>/items/<string:item_id>/image")
@ns.param("list_id", "The shopping list UUID")
@ns.param("item_id", "The list item UUID")
class ItemImage(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(201, "Image uploaded; response body includes the new image_url")
    @ns.response(400, "Missing file, unsupported format, or over the 5MB limit")
    @ns.response(403, "Not a member of the list's group")
    @ns.response(404, "Item not found")
    def post(self, list_id, item_id):
        """US-21: Upload a custom photo for this item — multipart/form-data
        with the file under the 'image' field. Replaces any image already
        on this item. Returns the updated item, including the new
        image_url, so the client can render it without a follow-up fetch.
        """
        file = request.files.get("image")
        if not file or not file.filename:
            ns.abort(400, "image file is required (multipart/form-data, field 'image')")
        facade = get_facade()
        result = _handle(
            lambda: facade.upload_item_image(
                user_id=g.user_id,
                list_item_id=item_id,
                file_bytes=file.read(),
                content_type=file.mimetype,
            )
        )
        return result, 201
