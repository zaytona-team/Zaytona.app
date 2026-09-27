"""Histories API namespace — activity log for a shopping list (LIST_ACTION).

Endpoints (all under /api/v1):
  GET  /lists/<list_id>/history   list activity for a list, newest first
"""
from flask import g, request
from flask_restx import Namespace, Resource

from app.api.v1.security import jwt_required
from app.services.facade import get_facade, FacadeError

ns = Namespace("histories", description="List activity/history log")


def _handle(fn):
    try:
        return fn()
    except FacadeError as e:
        ns.abort(e.status, e.message)


@ns.route("/<string:list_id>/history")
@ns.param("list_id", "The shopping list UUID")
class ListHistory(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.param("list_item_id", "Filter to a single item's history", _in="query")
    @ns.response(200, "Activity log for the list, newest first")
    @ns.response(403, "Not a member of the list's group")
    @ns.response(404, "List not found")
    def get(self, list_id):
        facade = get_facade()
        return _handle(
            lambda: facade.list_list_history(
                user_id=g.user_id,
                list_id=list_id,
                list_item_id=request.args.get("list_item_id"),
            )
        )
