"""Repository for USER_DEVICE — registered FCM push tokens.

Encapsulates all SQLAlchemy access so the facade never builds queries
inline. Mirrors UserRepository.
"""
from app.extensions import db
from app.models.user_device import UserDevice


class UserDeviceRepository:
    def upsert(self, *, user_id, fcm_token, platform) -> UserDevice:
        """Register a device token, or refresh platform/updated_at if the
        same token is already registered (e.g. re-login on the same phone)."""
        device = db.session.query(UserDevice).filter_by(fcm_token=fcm_token).first()
        if device:
            device.user_id = user_id
            device.platform = platform
        else:
            device = UserDevice(user_id=user_id, fcm_token=fcm_token, platform=platform)
            db.session.add(device)
        db.session.commit()
        return device

    def list_tokens_for_users(self, user_ids: list[str]) -> list[str]:
        rows = (
            db.session.query(UserDevice.fcm_token)
            .filter(UserDevice.user_id.in_(user_ids))
            .all()
        )
        return [row[0] for row in rows]

    def delete_by_token(self, *, user_id: str, fcm_token: str) -> bool:
        """Scoped to (user_id, fcm_token) — a device can only be
        unregistered by the account it belongs to, not by anyone who
        happens to know the raw token."""
        device = db.session.query(UserDevice).filter_by(user_id=user_id, fcm_token=fcm_token).first()
        if not device:
            return False
        db.session.delete(device)
        db.session.commit()
        return True

    def delete_invalid_tokens(self, tokens: list[str]) -> None:
        if not tokens:
            return
        db.session.query(UserDevice).filter(UserDevice.fcm_token.in_(tokens)).delete(
            synchronize_session=False
        )
        db.session.commit()
