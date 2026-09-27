"""Device mixin — push-notification token registration.

Requires `self.user_devices` (UserDeviceRepository) from the composed
facade. No user story yet (push belongs to the notifications feature),
mirrors the shape of AuthFacadeMixin.
"""
from app.services.facade.errors import FacadeError

ALLOWED_PLATFORMS = ("ios", "android", "web")


class DeviceFacadeMixin:
    def register_device(self, *, user_id, fcm_token, platform):
        if platform not in ALLOWED_PLATFORMS:
            raise FacadeError(
                f"platform must be one of: {', '.join(ALLOWED_PLATFORMS)}", status=400
            )
        if not fcm_token or not fcm_token.strip():
            raise FacadeError("fcm_token is required", status=400)

        device = self.user_devices.upsert(
            user_id=user_id, fcm_token=fcm_token.strip(), platform=platform
        )
        return device.to_dict()

    def unregister_device(self, *, user_id, fcm_token):
        deleted = self.user_devices.delete_by_token(user_id=user_id, fcm_token=fcm_token)
        if not deleted:
            raise FacadeError("Device not found", status=404)
        return {"message": "Device unregistered"}
