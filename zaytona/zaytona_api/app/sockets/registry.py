"""In-memory user_id <-> Socket.IO session-id map.

Needed because REST-triggered facade methods (an ordinary HTTP request,
not a socket event) run outside any Socket.IO request context, so they
can't rely on flask_socketio's own request-scoped `request.sid` to know
which connections belong to a given user when joining/evicting them from
a room (see RealtimeFacadeMixin._join_user_to_group /
_evict_user_from_group in app/services/facade/realtime.py).

In-memory and single-process: correct as long as the app runs behind a
single gunicorn worker (the documented deploy shape for this feature —
see Procfile). If that's ever scaled past one worker, this must move to
Redis (a hash keyed by user_id) instead, same instance already used as
the Celery broker.
"""


class ConnectionRegistry:
    def __init__(self):
        self._sids_by_user: dict[str, set[str]] = {}
        self._user_by_sid: dict[str, str] = {}

    def add(self, user_id, sid) -> None:
        self._sids_by_user.setdefault(user_id, set()).add(sid)
        self._user_by_sid[sid] = user_id

    def remove_sid(self, sid) -> None:
        user_id = self._user_by_sid.pop(sid, None)
        if user_id is None:
            return
        sids = self._sids_by_user.get(user_id)
        if sids is not None:
            sids.discard(sid)
            if not sids:
                del self._sids_by_user[user_id]

    def sids_for_user(self, user_id) -> set[str]:
        return set(self._sids_by_user.get(user_id, ()))


registry = ConnectionRegistry()
