"""Repository for GROUP / GROUP_MEMBER (+ the group-scoped delete paths for
SHOPPING_LIST and RECIPE used by US-11/US-12).

Encapsulates all SQLAlchemy access for the group domain so the
facade/service layer never builds queries inline. Mirrors UserRepository.
"""
import secrets
import string

from app.extensions import db
from app.models.group import Group
from app.models.group_member import GroupMember
from app.models.history import History
from app.models.instruction import Instruction
from app.models.list_item import ListItem
from app.models.recipe import Recipe
from app.models.recipe_ingredient import RecipeIngredient
from app.models.shopping_list import ShoppingList
from app.models.trip import Trip

_INVITE_CODE_ALPHABET = string.ascii_uppercase + string.digits
_INVITE_CODE_LENGTH = 6


class GroupRepository:
    # ── group ──────────────────────────────────────────────────
    def create(self, *, name, created_by, image_url=None, icon=None, type_="household", commit=True) -> Group:
        # Individual (private) groups are never joinable, so they get no
        # invite code — the column is nullable specifically for this case.
        invite_code = None
        if type_ != "individual":
            invite_code = self._unique_invite_code()

        group = Group(
            name=name,
            created_by=created_by,
            image_url=image_url,
            icon=icon,
            type=type_,
            invite_code=invite_code,
        )
        
        db.session.add(group)
        if commit:
            db.session.commit()
        else:
            db.session.flush()
        return group

    def _unique_invite_code(self) -> str:
        while True:
            code = "".join(secrets.choice(_INVITE_CODE_ALPHABET) for _ in range(_INVITE_CODE_LENGTH))
            if not self.get_by_invite_code(code):
                return code

    def get_by_id(self, group_id) -> Group | None:
        return db.session.get(Group, group_id)

    def get_by_invite_code(self, invite_code) -> Group | None:
        return db.session.query(Group).filter_by(invite_code=invite_code.upper()).first()

    def update(self, group_id, **fields) -> Group | None:
        group = self.get_by_id(group_id)
        if not group:
            return None
        for key, value in fields.items():
            if hasattr(group, key) and value is not None:
                setattr(group, key, value)
        db.session.commit()
        return group

    # ── membership ─────────────────────────────────────────────
    def add_member(self, *, group_id, user_id, role="member", commit=True) -> GroupMember:
        member = GroupMember(group_id=group_id, user_id=user_id, role=role)
        db.session.add(member)
        if commit:
            db.session.commit()
        else:
            db.session.flush()
        return member

    def get_member(self, *, group_id, user_id) -> GroupMember | None:
        return db.session.query(GroupMember).filter_by(group_id=group_id, user_id=user_id).first()

    def remove_member(self, *, group_id, user_id) -> bool:
        member = self.get_member(group_id=group_id, user_id=user_id)
        if not member:
            return False
        db.session.delete(member)
        db.session.commit()
        return True

    def list_members(self, group_id) -> list[GroupMember]:
        return db.session.query(GroupMember).filter_by(group_id=group_id).all()

    def list_groups_for_user(self, user_id) -> list[Group]:
        return (
            db.session.query(Group)
            .join(GroupMember, GroupMember.group_id == Group.group_id)
            .filter(GroupMember.user_id == user_id)
            .all()
        )

    def member_counts(self, group_ids: list[str]) -> dict[str, int]:
        """One grouped query for the member count of each of `group_ids`
        — used by list_my_groups so the group switcher can show "N
        members" without an N+1 query per group."""
        if not group_ids:
            return {}
        rows = (
            db.session.query(GroupMember.group_id, db.func.count(GroupMember.member_id))
            .filter(GroupMember.group_id.in_(group_ids))
            .group_by(GroupMember.group_id)
            .all()
        )
        return {group_id: count for group_id, count in rows}

    def roles_for_user(self, user_id, group_ids: list[str]) -> dict[str, str]:
        """The caller's own role in each of `group_ids` — used by
        list_my_groups so clients can gate admin-only UI without an
        extra round trip per group."""
        if not group_ids:
            return {}
        rows = (
            db.session.query(GroupMember.group_id, GroupMember.role)
            .filter(GroupMember.user_id == user_id, GroupMember.group_id.in_(group_ids))
            .all()
        )
        return {group_id: role for group_id, role in rows}

    def set_role(self, *, group_id, user_id, role, commit=True) -> GroupMember | None:
        member = self.get_member(group_id=group_id, user_id=user_id)
        if not member:
            return None
        member.role = role
        if commit:
            db.session.commit()
        else:
            db.session.flush()
        return member

    # ── leave/delete group: tear the whole group down ─────────
    def delete_group(self, group_id) -> bool:
        group = self.get_by_id(group_id)
        if not group:
            return False
        # Same child-first ordering as delete_list/delete_recipe below,
        # just applied to every list/recipe the group owns instead of one —
        # nothing here has an ON DELETE behavior at the DB level.
        list_ids = [
            row.list_id
            for row in db.session.query(ShoppingList.list_id).filter_by(group_id=group_id)
        ]
        if list_ids:
            db.session.query(Trip).filter(Trip.list_id.in_(list_ids)).delete(synchronize_session=False)
            db.session.query(History).filter(History.list_id.in_(list_ids)).delete(synchronize_session=False)
            db.session.query(ListItem).filter(ListItem.list_id.in_(list_ids)).delete(synchronize_session=False)
            db.session.query(ShoppingList).filter_by(group_id=group_id).delete(synchronize_session=False)

        recipe_ids = [
            row.recipe_id
            for row in db.session.query(Recipe.recipe_id).filter_by(group_id=group_id)
        ]
        if recipe_ids:
            db.session.query(RecipeIngredient).filter(
                RecipeIngredient.recipe_id.in_(recipe_ids)
            ).delete(synchronize_session=False)
            db.session.query(Instruction).filter(
                Instruction.recipe_id.in_(recipe_ids)
            ).delete(synchronize_session=False)
            db.session.query(Recipe).filter_by(group_id=group_id).delete(synchronize_session=False)

        db.session.query(GroupMember).filter_by(group_id=group_id).delete(synchronize_session=False)
        db.session.delete(group)
        db.session.commit()
        return True

    # ── US-11: admin removes a list from the group ────────────
    def get_list(self, *, group_id, list_id) -> ShoppingList | None:
        return db.session.query(ShoppingList).filter_by(group_id=group_id, list_id=list_id).first()

    def delete_list(self, *, group_id, list_id) -> bool:
        shopping_list = self.get_list(group_id=group_id, list_id=list_id)
        if not shopping_list:
            return False
        # Children FK to shopping_lists.list_id with no ON DELETE behavior,
        # so they must go first — a list with any item/history/trip ever
        # recorded against it would otherwise hit a ForeignKeyViolation.
        db.session.query(Trip).filter_by(list_id=list_id).delete()
        db.session.query(History).filter_by(list_id=list_id).delete()
        db.session.query(ListItem).filter_by(list_id=list_id).delete()
        db.session.delete(shopping_list)
        db.session.commit()
        return True

    # ── US-12: admin removes a recipe from the group ─────────
    def get_recipe(self, *, group_id, recipe_id) -> Recipe | None:
        return db.session.query(Recipe).filter_by(group_id=group_id, recipe_id=recipe_id).first()

    def delete_recipe(self, *, group_id, recipe_id) -> bool:
        recipe = self.get_recipe(group_id=group_id, recipe_id=recipe_id)
        if not recipe:
            return False
        db.session.delete(recipe)
        db.session.commit()
        return True
