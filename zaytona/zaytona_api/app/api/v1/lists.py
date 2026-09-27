"""Lists API namespace — direct list operations (US-14, US-15).

Endpoints (all under /api/v1/lists):
  GET    /<list_id>               single list detail
  PATCH  /<list_id>               US-14  admin: edit list name
  PATCH  /<list_id>/complete      US-15  any member: close the list
"""
from flask import g
from flask_restx import Namespace, Resource, fields

from app.api.v1.security import jwt_required
from app.services.facade import get_facade, FacadeError

ns = Namespace("lists", description="Shopping list direct operations")

update_list_model = ns.model(
    "UpdateListRequest",
    {
        "name": fields.String(required=False, example="Weekly Groceries — Updated"),
        "color": fields.String(
            required=False,
            enum=["red", "indigo", "mint", "navy", "lilac"],
            example="indigo",
        ),
    },
)

def _handle(fn):
    try:
        return fn()
    except FacadeError as e:
        ns.abort(e.status, e.message)

@ns.route("/<string:list_id>")
@ns.param("list_id", "The list UUID")
class ListDetail(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(200, "List details")
    @ns.response(403, "Not a member of the list's group")
    @ns.response(404, "List not found")
    def get(self, list_id):
        facade = get_facade()
        return _handle(lambda: facade.get_list(user_id=g.user_id, list_id=list_id)), 200

    @ns.doc(security="Bearer")
    @jwt_required
    @ns.expect(update_list_model, validate=True)
    @ns.response(200, "List updated")
    @ns.response(400, "Validation error")
    @ns.response(403, "Admin role required")
    @ns.response(404, "List not found")
    def patch(self, list_id):
        """US-14: Edit list name and/or accent colour. Admin-only operation."""
        data = ns.payload
        facade = get_facade()
        result = _handle(
            lambda: facade.update_list(
                user_id=g.user_id,
                list_id=list_id,
                name=data.get("name"),
                color=data.get("color"),
            )
        )
        return result, 200

    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(204, "List deleted")
    @ns.response(403, "Admin role required")
    @ns.response(404, "List not found")
    def delete(self, list_id):
        """Admin-only: permanently deletes the list."""
        facade = get_facade()
        _handle(lambda: facade.delete_list(user_id=g.user_id, list_id=list_id))
        return "", 204

@ns.route("/<string:list_id>/complete")
@ns.param("list_id", "The list UUID")
class ListComplete(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(200, "Trip completed")
    @ns.response(403, "Not a member of the list's group")
    @ns.response(404, "List not found")
    def patch(self, list_id):
        """US-15: Close out the current shopping trip on this list."""
        facade = get_facade()
        result = _handle(
            lambda: facade.complete_list(user_id=g.user_id, list_id=list_id)
        )
        return result, 200