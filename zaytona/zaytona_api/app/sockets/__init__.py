"""Socket.IO connect/disconnect handlers — real-time group/list/trip sync.

Imported for side effects only (registers the @socketio.on(...) handlers
below), same pattern as `from app import tasks` in the factory.

Room model: one room per group (`group:{group_id}`, joined for every
group the user belongs to at connect time) plus one personal room per
user (`user:{user_id}`, for events that must reach a specific user
regardless of their current group-room membership — e.g. being removed
from a group, or the moment they join one). See
app/services/facade/realtime.py for the emit/join/evict helpers that
target these same room names from REST-triggered facade methods.
"""
from flask import request
from flask_socketio import join_room

from app.api.v1.security import decode_access_token
from app.extensions import socketio
from app.services.facade import get_facade
from app.sockets.registry import registry


def room_for_group(group_id) -> str:
    return f"group:{group_id}"


def room_for_user(user_id) -> str:
    return f"user:{user_id}"


@socketio.on("connect")
def handle_connect(auth):
    """auth is the dict the client passes as `auth: {...}` on connect
    (flask-socketio's supported way to authenticate a handshake — the
    real-time equivalent of the Authorization header). Returning False
    rejects the connection.
    """
    token = (auth or {}).get("token")
    if not token:
        return False
    try:
        payload = decode_access_token(token)
    except Exception:
        return False

    user_id = payload.get("sub")
    sid = request.sid
    registry.add(user_id, sid)
    join_room(room_for_user(user_id), sid=sid)
    for group in get_facade().groups.list_groups_for_user(user_id):
        join_room(room_for_group(group.group_id), sid=sid)


@socketio.on("disconnect")
def handle_disconnect():
    # flask-socketio removes this sid from every room it was in
    # automatically — no manual leave_room calls needed here.
    registry.remove_sid(request.sid)
