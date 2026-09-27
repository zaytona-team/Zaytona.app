"""Group Management mixin — US-04..US-12.

Requires `self.groups` (GroupRepository) from the composed facade, plus
GuardsMixin's `_require_membership` / `_require_admin`.
"""
from sqlalchemy.exc import IntegrityError

from app.extensions import db
from app.models.group import ICON_CHOICES
from app.services.facade.errors import FacadeError
from app.utils.util import _is_uuid


class GroupFacadeMixin:
    # ── US-04 : create group (creator becomes admin) ──────────
    def create_group(self, *, user_id, name, image_url=None, icon=None, type_="household"):
        """Create a group on behalf of a member.

        `type_` is intentionally ignored beyond validation — every
        client-created group is 'household'. 'individual' is reserved for
        the single free-tier personal group auto-provisioned at
        registration (see AuthFacadeMixin.register_user), which calls
        GroupRepository.create directly rather than through here. Letting
        clients request 'individual' themselves would let a user spin up
        unlimited personal groups, each with its own fresh 5-list cap.
        """
        self._validate_icon(icon)
        group = self.groups.create(
            name=name, created_by=user_id, image_url=image_url, icon=icon, type_="household"
        )
        self.groups.add_member(group_id=group.group_id, user_id=user_id, role="admin")
        # Room membership is otherwise only assigned once, at connect time
        # (app/sockets/__init__.py) — without this, a user already
        # connected when they create a group gets no live events for it
        # (someone joining, a list being added...) until their next
        # reconnect. Every other membership-changing method already does
        # this; create_group was the one gap (see join_group below).
        self._join_user_to_group(user_id, group.group_id)
        invite_code = group.invite_code

        result = group.to_dict()
        result["invite_code"] = invite_code
            
        return result

    @staticmethod
    def _validate_icon(icon):
        if icon is not None and icon not in ICON_CHOICES:
            raise FacadeError(f"icon must be one of {', '.join(ICON_CHOICES)}", status=400)

    # ── US-05 : join group by invite code ─────────────────────
    def join_group(self, *, user_id, invite_code):
        group = self.groups.get_by_invite_code(invite_code)
        if not group:
            raise FacadeError("Invalid invite code", status=404)
        # An individual group is one person's private space — its invite
        # code exists only because every group has one, not because it's
        # joinable. Block it here rather than relying on the UI alone.
        if group.type == "individual":
            raise FacadeError("This group cannot be joined", status=403)
        if self.groups.get_member(group_id=group.group_id, user_id=user_id):
            raise FacadeError("Already a member of this group", status=409)

        try:
            member = self.groups.add_member(group_id=group.group_id, user_id=user_id, role="member")
        except IntegrityError:
            # Two concurrent joins for the same user+group both pass the
            # check above and race to the unique (group_id, user_id)
            # constraint on group_members.
            db.session.rollback()
            raise FacadeError("Already a member of this group", status=409)

        result = group.to_dict()
        self._join_user_to_group(user_id, group.group_id)
        self._emit_group(
            "group.member_joined",
            {"group_id": group.group_id, "actor_user_id": user_id, "member": member.to_dict()},
            group_id=group.group_id,
        )
        self._emit_user(
            "group.membership_changed",
            {"group_id": group.group_id, "reason": "joined", "group": result},
            user_id=user_id,
        )
        return result

    # ── US-06 : list groups I belong to ───────────────────────
    def list_my_groups(self, *, user_id):
        groups = self.groups.list_groups_for_user(user_id)
        counts = self.groups.member_counts([g.group_id for g in groups])
        roles = self.groups.roles_for_user(user_id, [g.group_id for g in groups])
        return [
            {**g.to_dict(), "member_count": counts.get(g.group_id, 0), "role": roles.get(g.group_id)}
            for g in groups
        ]

    # ── US-07 : group detail (invite code included for members) ─
    def get_group(self, *, user_id, group_id):
        group = self._require_membership(user_id=user_id, group_id=group_id)
        caller = self.groups.get_member(group_id=group_id, user_id=user_id)
        return {
            **group.to_dict(),
            # The caller's own role — the frontend uses this to gate
            # admin-only UI (rename, icon change, member management).
            # Without it every client sees itself as a plain member.
            "role": caller.role if caller else None,
            "members": [m.to_dict() for m in self.groups.list_members(group_id)],
        }

    # ── US-08 : list a group's members ────────────────────────
    def list_group_members(self, *, user_id, group_id):
        self._require_membership(user_id=user_id, group_id=group_id)
        return [m.to_dict() for m in self.groups.list_members(group_id)]

    # ── US-09 : admin edits group name / icon ─────────────────
    def update_group(self, *, user_id, group_id, name=None, image_url=None, icon=None):
        self._require_admin(user_id=user_id, group_id=group_id)
        self._validate_icon(icon)
        group = self.groups.update(group_id, name=name, image_url=image_url, icon=icon)
        result = group.to_dict()
        self._emit_group(
            "group.updated",
            {"group_id": group_id, "actor_user_id": user_id, "group": result},
            group_id=group_id,
        )
        return result

    # ── US-08 : admin removes a member ────────────────────────
    def remove_group_member(self, *, user_id, group_id, target_user_id):
        self._require_admin(user_id=user_id, group_id=group_id)
        if target_user_id == user_id:
            raise FacadeError("Admin cannot remove themselves — transfer admin first", status=400)
        if not _is_uuid(target_user_id):
            raise FacadeError("That user is not a member of this group", status=404)

        target = self.groups.get_member(group_id=group_id, user_id=target_user_id)
        if not target:
            raise FacadeError("That user is not a member of this group", status=404)
        if target.role == "admin":
            raise FacadeError("Cannot remove the group admin — transfer admin first", status=400)

        self.groups.remove_member(group_id=group_id, user_id=target_user_id)
        self._emit_group(
            "group.member_removed",
            {"group_id": group_id, "actor_user_id": user_id, "target_user_id": target_user_id},
            group_id=group_id,
        )
        self._evict_user_from_group(target_user_id, group_id)
        self._emit_user(
            "group.membership_changed",
            {"group_id": group_id, "reason": "removed"},
            user_id=target_user_id,
        )

    # ── US-10 : admin transfers admin role ────────────────────
    def transfer_group_admin(self, *, user_id, group_id, new_admin_user_id):
        self._require_admin(user_id=user_id, group_id=group_id)
        if new_admin_user_id == user_id:
            raise FacadeError("You are already the admin", status=400)
        if not _is_uuid(new_admin_user_id):
            raise FacadeError("That user is not a member of this group", status=404)

        new_admin = self.groups.get_member(group_id=group_id, user_id=new_admin_user_id)
        if not new_admin:
            raise FacadeError("That user is not a member of this group", status=404)

        # Both role flips must land together — a failure between them
        # would leave the group with zero admins and no way to recover,
        # since every admin action (including this one) requires one.
        self.groups.set_role(group_id=group_id, user_id=user_id, role="member", commit=False)
        self.groups.set_role(group_id=group_id, user_id=new_admin_user_id, role="admin", commit=False)
        db.session.commit()
        self._emit_group(
            "group.admin_transferred",
            {"group_id": group_id, "actor_user_id": user_id, "new_admin_user_id": new_admin_user_id},
            group_id=group_id,
        )

    # ── leave group (any member, self-service) ────────────────
    def leave_group(self, *, user_id, group_id):
        self._require_membership(user_id=user_id, group_id=group_id)
        members = self.groups.list_members(group_id)
        if len(members) == 1:
            # The leaving member is the only one left — there is no one
            # left to own the group, so it goes with them rather than
            # sitting around ownerless with no admin.
            self.groups.delete_group(group_id)
            self._emit_group(
                "group.deleted", {"group_id": group_id, "actor_user_id": user_id}, group_id=group_id
            )
            self._emit_user(
                "group.membership_changed",
                {"group_id": group_id, "reason": "group_deleted"},
                user_id=user_id,
            )
            self._evict_group_room(group_id)
            return {"group_deleted": True}

        caller = self.groups.get_member(group_id=group_id, user_id=user_id)
        if caller.role == "admin":
            raise FacadeError(
                "Transfer the admin role to another member before leaving", status=400
            )
        self.groups.remove_member(group_id=group_id, user_id=user_id)
        self._emit_group(
            "group.member_left",
            {"group_id": group_id, "actor_user_id": user_id},
            group_id=group_id,
        )
        self._evict_user_from_group(user_id, group_id)
        self._emit_user(
            "group.membership_changed",
            {"group_id": group_id, "reason": "left"},
            user_id=user_id,
        )
        return {"group_deleted": False}

    # ── admin deletes the group outright ──────────────────────
    def delete_group(self, *, user_id, group_id):
        self._require_admin(user_id=user_id, group_id=group_id)
        group = self.groups.get_by_id(group_id)
        if not group:
            raise FacadeError("Group not found", status=404)
    
        if group.type == "individual":
            raise FacadeError(
            "Cannot delete your personal group. It was created automatically with your account.",
            status=403
        )
        self.groups.delete_group(group_id)
        self._emit_group(
            "group.deleted", {"group_id": group_id, "actor_user_id": user_id}, group_id=group_id
        )
        self._evict_group_room(group_id)

        return {"message": "Group deleted successfully"}

    # ── US-11 : admin removes a list from the group ───────────
    def remove_group_list(self, *, user_id, group_id, list_id):
        self._require_admin(user_id=user_id, group_id=group_id)
        if not _is_uuid(list_id):
            raise FacadeError("List not found in this group", status=404)
        if not self.groups.delete_list(group_id=group_id, list_id=list_id):
            raise FacadeError("List not found in this group", status=404)
        self._emit_group(
            "list.deleted",
            {"group_id": group_id, "actor_user_id": user_id, "list_id": list_id},
            group_id=group_id,
        )

    # ── US-12 : admin removes a recipe from the group ─────────
    def remove_group_recipe(self, *, user_id, group_id, recipe_id):
        self._require_admin(user_id=user_id, group_id=group_id)
        if not _is_uuid(recipe_id):
            raise FacadeError("Recipe not found in this group", status=404)
        if not self.groups.delete_recipe(group_id=group_id, recipe_id=recipe_id):
            raise FacadeError("Recipe not found in this group", status=404)
        self._emit_group(
            "recipe.deleted",
            {"group_id": group_id, "actor_user_id": user_id, "recipe_id": recipe_id},
            group_id=group_id,
        )
