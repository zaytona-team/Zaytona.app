"""Notifications API namespace (US-31, US-32).

Endpoints (all under /api/v1/lists/<list_id>/notifications):
  POST /assign-buyer    Assign + notify a buyer for this list
  POST /remind-member    Ping a specific member about this list
  POST /remind-me         Ping yourself about this list
"""
from flask import g
from flask_restx import Namespace, Resource, fields

from app.api.v1.security import jwt_required
from app.services.facade import get_facade, FacadeError

ns = Namespace("notifications", description="List notification triggers (US-31, US-32)")

target_member_model = ns.model(
    "NotificationTargetRequest",
    {
        "user_id": fields.String(required=True, example="uuid-of-member", description="Target member's user_id"),
    },
)


def _handle(fn):
    try:
        return fn()
    except FacadeError as e:
        ns.abort(e.status, e.message)


@ns.route("/<string:list_id>/notifications/assign-buyer")
@ns.param("list_id", "The shopping list UUID")
class AssignBuyerNotification(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.expect(target_member_model, validate=True)
    @ns.response(200, "Notification sent successfully")
    @ns.response(400, "Chosen buyer is not a member of this group")
    @ns.response(403, "Not a member of the list's group")
    @ns.response(404, "List not found")
    @ns.response(409, "This list already has an active trip")
    def post(self, list_id):
        data = ns.payload
        facade = get_facade()
        return _handle(
            lambda: facade.notify_assign_buyer(
                user_id=g.user_id, list_id=list_id, target_user_id=data["user_id"]
            )
        ), 200


@ns.route("/<string:list_id>/notifications/remind-member")
@ns.param("list_id", "The shopping list UUID")
class RemindMemberNotification(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.expect(target_member_model, validate=True)
    @ns.response(200, "Notification sent successfully")
    @ns.response(400, "That user is not a member of this group")
    @ns.response(403, "Not a member of the list's group")
    @ns.response(404, "List not found")
    def post(self, list_id):
        data = ns.payload
        facade = get_facade()
        return _handle(
            lambda: facade.notify_remind_member(
                user_id=g.user_id, list_id=list_id, target_user_id=data["user_id"]
            )
        ), 200


@ns.route("/<string:list_id>/notifications/remind-me")
@ns.param("list_id", "The shopping list UUID")
class RemindMeNotification(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(200, "Notification sent successfully")
    @ns.response(403, "Not a member of the list's group")
    @ns.response(404, "List not found")
    def post(self, list_id):
        facade = get_facade()
        return _handle(lambda: facade.notify_remind_me(user_id=g.user_id, list_id=list_id)), 200
