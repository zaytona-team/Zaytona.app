"""History / Activity Log mixin — LIST_ACTION.

Requires `self.lists` (ListRepository) and `self.history`
(HistoryRepository) from the composed facade, plus GuardsMixin's
`_require_membership`.
"""
from app.services.facade.errors import FacadeError
from app.utils.util import _is_uuid


class HistoryFacadeMixin:
    def list_list_history(self, *, user_id, list_id, list_item_id=None):
        """Return the activity log for a list, newest first.

        Authorization: caller must be a member of the list's group.
        """
        if not _is_uuid(list_id):
            raise FacadeError("List not found", status=404)

        shopping_list = self.lists.get_by_id(list_id)
        if not shopping_list:
            raise FacadeError("List not found", status=404)

        self._require_membership(user_id=user_id, group_id=shopping_list.group_id)

        if list_item_id is not None and not _is_uuid(list_item_id):
            raise FacadeError("Item not found", status=404)

        entries = self.history.list_by_list(list_id, list_item_id=list_item_id)
        return [entry.to_dict() for entry in entries]
