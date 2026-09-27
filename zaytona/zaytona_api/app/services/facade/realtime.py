"""Real-time sync mixin — emits Socket.IO events from REST mutations.

Requires `self.socketio` (the shared SocketIO instance from
app/extensions.py) from the composed facade. Every other domain mixin
(items.py, trips.py, groups.py) calls these helpers right after a
successful write, so group members see it live without refreshing.

Room model: `group:{group_id}` for group-wide broadcasts, `user:{user_id}`
for events that must reach one specific user regardless of their current
room membership (see app/sockets/__init__.py for where these rooms are
joined at connect time).

join_room/leave_room/close_room all work with an explicit `sid=` even
outside a Socket.IO request context — which is exactly the situation
here, since these are called from an ordinary HTTP request, not a socket
event. They still unconditionally read `flask.request.namespace` when
`namespace=` isn't also passed explicitly (regardless of `sid=`), which
doesn't exist on a plain Flask request — so `namespace="/"` (the default
Socket.IO namespace, since this app never uses custom namespaces) must be
passed on every call here.
"""
from flask_socketio import close_room, join_room, leave_room

from app.sockets.registry import registry


class RealtimeFacadeMixin:
    def _room_for_group(self, group_id) -> str:
        return f"group:{group_id}"

    def _room_for_user(self, user_id) -> str:
        return f"user:{user_id}"

    def _emit_group(self, event, payload, *, group_id) -> None:
        self.socketio.emit(event, payload, room=self._room_for_group(group_id))

    def _emit_user(self, event, payload, *, user_id) -> None:
        self.socketio.emit(event, payload, room=self._room_for_user(user_id))

    def _join_user_to_group(self, user_id, group_id) -> None:
        for sid in registry.sids_for_user(user_id):
            join_room(self._room_for_group(group_id), sid=sid, namespace="/")

    def _evict_user_from_group(self, user_id, group_id) -> None:
        for sid in registry.sids_for_user(user_id):
            leave_room(self._room_for_group(group_id), sid=sid, namespace="/")

    def _evict_group_room(self, group_id) -> None:
        close_room(self._room_for_group(group_id), namespace="/")
