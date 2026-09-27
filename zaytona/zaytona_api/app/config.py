"""Configuration objects for the Zaytona API.

All secrets are read from environment variables (see .env.example).
Never hard-code keys here.
"""
import os

from dotenv import load_dotenv

# Load here (not just in run.py) so any entry point that imports this
# module first — pytest, gunicorn, a shell — still picks up .env.
# interpolate=False keeps literal '$' in values intact (the Authentica
# API key is a bcrypt-style string containing '$').
load_dotenv(interpolate=False)


class Config:
    # ── Flask ────────────────────────────────────────────────
    SECRET_KEY = os.getenv("FLASK_SECRET_KEY", "change-me-in-prod")

    # ── CORS ─────────────────────────────────────────────────
    # Comma-separated list of allowed origins, e.g.
    # "https://app.zaytona.sa,https://staging.zaytona.sa". Defaults to "*"
    # only when unset, so local/dev keeps working without config but a
    # real deploy can lock this down without a code change.
    CORS_ORIGINS = [
        origin.strip()
        for origin in os.getenv("CORS_ORIGINS", "*").split(",")
        if origin.strip()
    ]

    # ── SQLAlchemy → Supabase Postgres ───────────────────────
    # Use the *connection pooler* string from Supabase:
    #   Project Settings → Database → Connection string → URI (pooler, 6543)
    # Example:
    #   postgresql+psycopg2://postgres.<ref>:<password>@aws-0-<region>.pooler.supabase.com:6543/postgres
    SQLALCHEMY_DATABASE_URI = os.getenv("DATABASE_URL", "")
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    # connect_timeout: fail fast (10s) instead of hanging forever if the
    # network can't complete the Postgres/TLS handshake.
    SQLALCHEMY_ENGINE_OPTIONS = {
        "pool_pre_ping": True,
        "connect_args": {"connect_timeout": 10},
    }

    # ── Supabase (Postgres host only — not used for auth/identity) ──
    SUPABASE_URL = os.getenv("SUPABASE_URL", "")
    SUPABASE_ANON_KEY = os.getenv("SUPABASE_ANON_KEY", "")
    # service-role key: used by SupabaseStorageProvider (item-images bucket)
    SUPABASE_SERVICE_KEY = os.getenv("SUPABASE_SERVICE_KEY", "")

    # Blanket cap on any request body, well above the 5MB item-image limit
    # (ItemFacadeMixin.MAX_IMAGE_BYTES) — this one's enforced by Flask
    # itself before a request even reaches app code, so an oversized
    # upload gets rejected without first being buffered fully into memory.
    MAX_CONTENT_LENGTH = 8 * 1024 * 1024  # 8 MB

    # ── App-issued session tokens ─────────────────────────────
    # There is no password: Authentica OTP is the only identity check.
    # The API mints and verifies its own JWTs (signed with SECRET_KEY)
    # instead of relying on Supabase Auth sessions.
    # Access tokens are short-lived (15 min default); the refresh token
    # (JWT_EXPIRES_SECONDS, default 7 days) is what a client holds onto
    # to mint new access tokens via /auth/refresh.
    JWT_ACCESS_EXPIRES_SECONDS = int(os.getenv("JWT_ACCESS_EXPIRES_SECONDS", str(15 * 60)))
    JWT_EXPIRES_SECONDS = int(os.getenv("JWT_EXPIRES_SECONDS", str(60 * 60 * 24 * 7)))

    # ── OTP bypass for whitelisted numbers (incl. Apple review) ──
    # Enabled in prod too — the reviewer hits the live backend. Keep the
    # whitelist a short exact-match list, never a pattern.
    DEV_OTP_CODE = os.getenv("DEV_OTP_CODE", "4444")
    DEV_OTP_WHITELIST_PHONES = [
        p.strip() for p in os.getenv("DEV_OTP_WHITELIST_PHONES", "+966555455544").split(",") if p.strip()
    ]
    DEV_OTP_ENABLED = True

    # ── Authentica (OTP provider for US-36) ──────────────────
    # https://authentica.sa  — owns OTP send + verify.
    AUTHENTICA_BASE_URL = os.getenv("AUTHENTICA_BASE_URL", "https://api.authentica.sa")
    AUTHENTICA_API_KEY = os.getenv("AUTHENTICA_API_KEY", "")
    # Primary channel; Authentica handles fallback to email itself.
    AUTHENTICA_OTP_METHOD = os.getenv("AUTHENTICA_OTP_METHOD", "whatsapp")
    AUTHENTICA_TEMPLATE_ID = int(os.getenv("AUTHENTICA_TEMPLATE_ID", "20"))
    AUTHENTICA_FALLBACK_EMAIL = os.getenv(
        "AUTHENTICA_FALLBACK_EMAIL", "zaytona.team@gmail.com"
    )

    # ── Firebase Cloud Messaging (push notifications) ────────
    # Full service-account JSON as a single-line env var (Project settings
    # -> Service accounts -> Generate new private key in the Firebase
    # console). Never a file path — keeps deploy targets that are
    # env-only (no file uploads) working the same as local dev.
    FIREBASE_CREDENTIALS_JSON = os.getenv("FIREBASE_CREDENTIALS_JSON", "")

    # ── Socket.IO message queue (real-time group/list/trip sync) ──
    # Only needed once gunicorn runs more than one worker — with a single
    # eventlet worker (the default deploy shape here), in-process pub/sub
    # is enough and this stays unset. Reuse the same Redis as Celery if
    # it's ever turned on: SOCKETIO_MESSAGE_QUEUE_URL=<CELERY_BROKER_URL>.
    SOCKETIO_MESSAGE_QUEUE_URL = os.getenv("SOCKETIO_MESSAGE_QUEUE_URL") or None

    # ── Celery (background jobs — reminder + retention sweeps) ──
    # Redis as both broker and result backend; run one locally
    # (`redis-server`) or point at a hosted instance for staging/prod.
    # beat_schedule lives here (not celery_app.conf directly) so both the
    # web process and the separate `celery beat` process agree on it.
    CELERY = {
        "broker_url": os.getenv("CELERY_BROKER_URL", "redis://localhost:6379/0"),
        "result_backend": os.getenv("CELERY_RESULT_BACKEND", "redis://localhost:6379/0"),
        "timezone": "UTC",
        "beat_schedule": {
            "sweep-list-reminders": {
                "task": "reminders.sweep_list_reminders",
                # Runs often enough to keep the 12h-per-list window tight
                # without hammering the DB; each list is only actually
                # notified once its own 12h mark has passed.
                "schedule": 15 * 60,
            },
            "sweep-expired-history": {
                "task": "retention.sweep_expired_history",
                # A 7-day window doesn't need tight polling — once a day
                # is plenty to keep completed trips/history from outliving
                # their retention period by more than a few hours.
                "schedule": 24 * 60 * 60,
            },
        },
    }


class DevelopmentConfig(Config):
    DEBUG = True


class ProductionConfig(Config):
    DEBUG = False


config_by_name = {
    "development": DevelopmentConfig,
    "production": ProductionConfig,
}


def get_config():
    return config_by_name.get(os.getenv("FLASK_ENV", "development"), DevelopmentConfig)
