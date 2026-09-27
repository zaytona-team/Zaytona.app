"""Devices API namespace — FCM push-token registration.

Endpoints (all under /api/v1/devices):
  POST   /              Register/refresh this device's FCM token
  DELETE /<fcm_token>   Unregister a device (e.g. on logout)
"""
from flask import g
from flask_restx import Namespace, Resource, fields

from app.api.v1.security import jwt_required
from app.services.facade import get_facade, FacadeError
from app.services.facade.devices import ALLOWED_PLATFORMS

ns = Namespace("devices", description="Push-notification device registration")

register_device_model = ns.model(
    "RegisterDeviceRequest",
    {
        "fcm_token": fields.String(required=True, example="cX3f...:APA91b..."),
        "platform": fields.String(required=True, enum=list(ALLOWED_PLATFORMS), example="android"),
    },
)


def _handle(fn):
    try:
        return fn()
    except FacadeError as e:
        ns.abort(e.status, e.message)


@ns.route("/")
class DeviceCollection(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.expect(register_device_model, validate=True)
    @ns.response(200, "Device registered")
    @ns.response(400, "Validation error")
    def post(self):
        """Register (or refresh) this device's FCM token for the caller."""
        data = ns.payload
        facade = get_facade()
        return _handle(
            lambda: facade.register_device(
                user_id=g.user_id,
                fcm_token=data.get("fcm_token"),
                platform=data.get("platform"),
            )
        )


@ns.route("/<string:fcm_token>")
@ns.param("fcm_token", "The FCM token to unregister")
class DeviceItem(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(200, "Device unregistered")
    @ns.response(404, "Device not found")
    def delete(self, fcm_token):
        """Unregister a device (e.g. on logout)."""
        facade = get_facade()
        return _handle(
            lambda: facade.unregister_device(user_id=g.user_id, fcm_token=fcm_token)
        )
