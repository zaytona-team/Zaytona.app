"""Membership / role guards shared by every domain mixin that touches a
group or something scoped to one (lists, items, recipes, history).

Split out on its own so no single domain mixin "owns" authorization —
every mixin that needs it composes this one in via ZaytonaFacade's MRO.
"""
from app.services.facade.errors import FacadeError
from app.utils.util import _is_uuid


class GuardsMixin:
    """Requires `self.groups` (GroupRepository) from the composed facade."""

    def _require_membership(self, *, user_id, group_id):
        if not _is_uuid(group_id):
            raise FacadeError("Group not found", status=404)
        group = self.groups.get_by_id(group_id)
        if not group:
            raise FacadeError("Group not found", status=404)
        if not self.groups.get_member(group_id=group_id, user_id=user_id):
            raise FacadeError("Not a member of this group", status=403)
        return group

    def _require_admin(self, *, user_id, group_id):
        group = self._require_membership(user_id=user_id, group_id=group_id)
        member = self.groups.get_member(group_id=group_id, user_id=user_id)
        if member.role != "admin":
            raise FacadeError("Admin role required for this action", status=403)
        return group
