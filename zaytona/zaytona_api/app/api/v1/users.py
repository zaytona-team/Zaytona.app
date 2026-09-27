"""Users API namespace — cross-group, user-level views.

Endpoints (all under /api/v1/users):
  GET /me/items   Distinct items this user has personally added, across
                  every group they belong to, most recently used first.
                  See ItemFacadeMixin.list_my_items — fully derived from
                  list_items, no dedicated table.
"""
from flask import g
from flask_restx import Namespace, Resource

from app.api.v1.security import jwt_required
from app.services.facade import get_facade, FacadeError

ns = Namespace("users", description="Cross-group user-level views")


def _handle(fn):
    try:
        return fn()
    except FacadeError as e:
        ns.abort(e.status, e.message)


@ns.route("/me/items")
class MyItems(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(200, "Distinct items this user has added, most recently used first")
    @ns.response(401, "Unauthorized")
    def get(self):
        facade = get_facade()
        result = _handle(lambda: facade.list_my_items(user_id=g.user_id))
        return result, 200
