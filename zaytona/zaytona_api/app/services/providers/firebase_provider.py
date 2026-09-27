"""Firebase Cloud Messaging provider — push notifications.

Mirrors AuthenticaProvider's shape: reads its credential from
`current_app.config` (never hard-coded), and exposes one plain method
the facade calls. `firebase_admin.initialize_app` is process-global (not
per-instance) so it's guarded to run at most once per process.

Credential comes from FIREBASE_CREDENTIALS_JSON — the full service-account
JSON as a single env var value (see .env.example) — not a file path, so
deploy targets that can't ship an extra file (Render/Railway/Heroku-style
env-only config) still work. Never commit the real JSON; .env is
gitignored.
"""
import json
import logging

import firebase_admin
from firebase_admin import credentials, messaging
from flask import current_app

logger = logging.getLogger("zaytona.firebase")


class FirebaseError(Exception):
    def __init__(self, message, status=502):
        super().__init__(message)
        self.message = message
        self.status = status


class FirebaseProvider:
    """Credentials are validated lazily (on first send), not in __init__ —
    ZaytonaFacade constructs one instance of every provider eagerly, and a
    missing FIREBASE_CREDENTIALS_JSON must not break every unrelated API
    request for teammates who haven't set up push locally yet."""

    def __init__(self):
        self._initialized = False

    def _ensure_initialized(self):
        if self._initialized:
            return
        raw = current_app.config.get("FIREBASE_CREDENTIALS_JSON")
        if not raw:
            raise FirebaseError(
                "FIREBASE_CREDENTIALS_JSON is not set — see .env.example", status=500
            )
        if not firebase_admin._apps:
            cred = credentials.Certificate(json.loads(raw))
            firebase_admin.initialize_app(cred)
        self._initialized = True

    # ── send a push to one or more device tokens ─────────────
    def send_to_tokens(self, tokens: list[str], *, title: str, body: str, data: dict | None = None):
        """Send the same notification to every token in `tokens`.

        Returns (success_count, invalid_tokens) — invalid_tokens are
        tokens FCM reports as unregistered/invalid, so the caller can
        prune them from UserDevice.
        """
        tokens = [t for t in tokens if t]
        if not tokens:
            return 0, []
        self._ensure_initialized()

        message = messaging.MulticastMessage(
            notification=messaging.Notification(title=title, body=body),
            data={k: str(v) for k, v in (data or {}).items()},
            tokens=tokens,
        )
        try:
            response = messaging.send_each_for_multicast(message)
        except Exception as e:
            logger.warning("FCM send failed: %s", e)
            raise FirebaseError(str(e)) from e

        invalid_tokens = []
        for token, result in zip(tokens, response.responses):
            if not result.success:
                code = getattr(result.exception, "code", "")
                if code in ("NOT_FOUND", "UNREGISTERED", "INVALID_ARGUMENT"):
                    invalid_tokens.append(token)
                logger.warning("FCM send to %s failed: %s", token, result.exception)

        return response.success_count, invalid_tokens
