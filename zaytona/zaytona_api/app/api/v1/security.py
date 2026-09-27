"""JWT verification for this API's own session tokens.

There's no Supabase Auth session — after /otp/verify succeeds, the
facade mints a JWT signed with the app's SECRET_KEY (see
app/services/facade.py::_issue_token). Clients send it back as
`Authorization: Bearer <token>` on protected routes.
"""
from functools import wraps

import jwt
from flask import current_app, g, request
from flask_restx import abort


def _extract_token():
    header = request.headers.get("Authorization", "")
    if not header.startswith("Bearer "):
        return None
    return header.split(" ", 1)[1].strip()


def decode_access_token(token: str) -> dict:
    """Decode + validate one of this app's own JWTs. Raises
    jwt.ExpiredSignatureError / jwt.InvalidTokenError on failure — callers
    decide how to surface that (an HTTP 401 here, a rejected Socket.IO
    handshake in app/sockets). Shared by jwt_required below and the
    socket "connect" handler, so REST and real-time auth can't drift.
    """
    payload = jwt.decode(
        token,
        current_app.config["SECRET_KEY"],
        algorithms=["HS256"],
    )
    if payload.get("type") == "refresh":
        raise jwt.InvalidTokenError("Refresh tokens cannot be used to access resources")
    return payload


def jwt_required(fn):
    @wraps(fn)
    def wrapper(*args, **kwargs):
        token = _extract_token()
        if not token:
            abort(401, "Missing or malformed Authorization header")
        try:
            payload = decode_access_token(token)
        except jwt.ExpiredSignatureError:
            abort(401, "Token expired")
        except jwt.InvalidTokenError as e:
            abort(401, f"Invalid token: {e}")

        g.user_id = payload.get("sub")
        g.jwt_payload = payload
        return fn(*args, **kwargs)

    return wrapper
