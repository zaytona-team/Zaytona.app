"""Trips API namespace — locks a list to a single buyer for a shopping run.
Mirrors the app's "Trip Alerts" screen, which has three independent actions.

Endpoints:
  POST  /api/v1/lists/<list_id>/trip        Assign a buyer ("تعيين مشترٍ") —
                                             any member can pick anyone
                                             (including themselves) as buyer
  GET   /api/v1/lists/<list_id>/trips/active Current active trip for a list
                                             (or null) — lets the client
                                             learn a trip_id to address the
                                             endpoints below
  GET   /api/v1/lists/<list_id>/trips       Completed trips for this list,
                                             newest first — History screen's
                                             "الرحلات" tab
  PATCH /api/v1/trips/<trip_id>/complete    Buyer closes the trip
  PATCH /api/v1/trips/<trip_id>/cancel      Buyer abandons the trip
  POST  /api/v1/trips/<trip_id>/heading-out Buyer announces "أنا متجه للمتجر"
                                             — broadcast to the whole group,
                                             no recipient picker
  POST  /api/v1/trips/<trip_id>/ask         Buyer's "ذكّر أحدهم" — privately
                                             asks chosen members "want
                                             anything added?" (plain push,
                                             v1 — not persisted/tracked)
"""
from flask import g
from flask_restx import Namespace, Resource, fields

from app.api.v1.security import jwt_required
from app.services.facade import get_facade, FacadeError

ns = Namespace("trips", description="Shopping trip (buyer lock) management")

assign_buyer_model = ns.model(
    "AssignTripBuyerRequest",
    {
        "buyer_id": fields.String(
            required=True, example="uuid-of-chosen-member",
            description="Any group member's user_id — may be the caller themselves",
        ),
    },
)

ask_trip_group_model = ns.model(
    "AskTripGroupRequest",
    {
        "recipient_ids": fields.List(
            fields.String, required=True, example=["uuid-1", "uuid-2"],
            description="Group member user_ids to ask — the buyer picks who, per member privacy",
        ),
    },
)

# ── Swagger response models ─────────────────────────────────
trip_model = ns.model(
    "Trip",
    {
        "trip_id": fields.String,
        "list_id": fields.String,
        "buyer_id": fields.String,
        "status": fields.String(enum=["active", "completed", "cancelled"]),
        "created_at": fields.String,
        "updated_at": fields.String,
        "completed_at": fields.String(description="null until the trip is completed"),
    },
)

list_model = ns.model(
    "TripList",
    {
        "list_id": fields.String,
        "group_id": fields.String,
        "created_by": fields.String,
        "created_by_name": fields.String,
        "completed_by": fields.String,
        "name": fields.String,
        "status": fields.String,
        "created_at": fields.String,
        "updated_at": fields.String,
        "completed_at": fields.String,
        "last_reminded_at": fields.String,
    },
)

trip_complete_model = ns.model(
    "TripCompleteResponse",
    {
        "trip": fields.Nested(trip_model),
        "list": fields.Nested(list_model),
    },
)

notified_devices_model = ns.model(
    "NotifiedDevicesResponse",
    {"notified_devices": fields.Integer(description="Count of device tokens the push was sent to")},
)

ask_trip_group_response_model = ns.model(
    "AskTripGroupResponse",
    {
        "asked": fields.List(fields.String, description="user_ids that actually received the push"),
        "notified_devices": fields.Integer,
    },
)

trip_history_item_model = ns.model(
    "TripHistoryItem",
    {
        "item_id": fields.String,
        "name": fields.String,
        "quantity": fields.Float,
        "unit": fields.String,
        "category_id": fields.String,
    },
)

trip_history_entry_model = ns.model(
    "TripHistoryEntry",
    {
        "trip_id": fields.String,
        "list_id": fields.String,
        "buyer_id": fields.String,
        "buyer_name": fields.String,
        "completed_at": fields.String,
        "item_count": fields.Integer,
        "items": fields.List(fields.Nested(trip_history_item_model)),
    },
)


def _handle(fn):
    try:
        return fn()
    except FacadeError as e:
        ns.abort(e.status, e.message)


@ns.route("/lists/<string:list_id>/trip")
@ns.param("list_id", "The shopping list UUID")
class TripStart(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.expect(assign_buyer_model, validate=True)
    @ns.response(201, "Buyer assigned, trip started", trip_model)
    @ns.response(400, "Chosen buyer is not a member of this group")
    @ns.response(403, "Not a member of the list's group")
    @ns.response(404, "List not found")
    @ns.response(409, "This list already has an active trip")
    def post(self, list_id):
        """Assign who does the shopping — the picker can choose any group
        member, not just the caller."""
        data = ns.payload
        facade = get_facade()
        return _handle(
            lambda: facade.assign_trip_buyer(
                user_id=g.user_id, list_id=list_id, buyer_id=data.get("buyer_id")
            )
        ), 201


@ns.route("/lists/<string:list_id>/trips/active")
@ns.param("list_id", "The shopping list UUID")
class ActiveTrip(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(200, "The list's active trip, or null if none", trip_model)
    @ns.response(403, "Not a member of the list's group")
    @ns.response(404, "List not found")
    def get(self, list_id):
        """Look up the list's current active trip, if any — the client
        needs this trip_id to call heading-out/ask/complete/cancel."""
        facade = get_facade()
        return _handle(lambda: facade.get_active_trip(user_id=g.user_id, list_id=list_id)), 200


@ns.route("/lists/<string:list_id>/trips")
@ns.param("list_id", "The shopping list UUID")
class TripHistory(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(200, "Completed trips for this list, newest first", [trip_history_entry_model])
    @ns.response(403, "Not a member of the list's group")
    @ns.response(404, "List not found")
    def get(self, list_id):
        """History screen's "الرحلات" tab, scoped to this list: every
        completed trip generated from it, with the buyer's name and the
        items actually bought."""
        facade = get_facade()
        return _handle(lambda: facade.list_list_trips(user_id=g.user_id, list_id=list_id)), 200


@ns.route("/trips/<string:trip_id>/complete")
@ns.param("trip_id", "The trip UUID")
class TripComplete(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(200, "Trip completed", trip_complete_model)
    @ns.response(403, "Only the buyer can complete this trip")
    @ns.response(404, "Trip not found")
    def patch(self, trip_id):
        facade = get_facade()
        return _handle(lambda: facade.complete_trip(user_id=g.user_id, trip_id=trip_id))


@ns.route("/trips/<string:trip_id>/cancel")
@ns.param("trip_id", "The trip UUID")
class TripCancel(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(200, "Trip cancelled", trip_model)
    @ns.response(403, "Only the buyer can cancel this trip")
    @ns.response(404, "Trip not found")
    def patch(self, trip_id):
        facade = get_facade()
        return _handle(lambda: facade.cancel_trip(user_id=g.user_id, trip_id=trip_id))


@ns.route("/trips/<string:trip_id>/heading-out")
@ns.param("trip_id", "The trip UUID")
class TripHeadingOut(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(200, "Push broadcast to the whole group", notified_devices_model)
    @ns.response(403, "Only the buyer can send this")
    @ns.response(404, "Trip not found")
    def post(self, trip_id):
        """Buyer announces they're heading to the store — broadcasts to
        every other group member, no recipient picker."""
        facade = get_facade()
        return _handle(lambda: facade.announce_heading_out(user_id=g.user_id, trip_id=trip_id))


@ns.route("/trips/<string:trip_id>/ask")
@ns.param("trip_id", "The trip UUID")
class TripAsk(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.expect(ask_trip_group_model, validate=True)
    @ns.response(200, "Push sent to the chosen recipients", ask_trip_group_response_model)
    @ns.response(400, "Select at least one valid recipient")
    @ns.response(403, "Only the buyer can send this")
    @ns.response(404, "Trip not found")
    def post(self, trip_id):
        """Buyer asks specific group members if they want anything added
        to the list — recipients are chosen by the buyer, per-member, so
        the trip can stay private from anyone they don't pick."""
        data = ns.payload
        facade = get_facade()
        return _handle(
            lambda: facade.ask_trip_group(
                user_id=g.user_id, trip_id=trip_id, recipient_ids=data.get("recipient_ids")
            )
        )
