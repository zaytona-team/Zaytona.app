"""Groups API namespace — US-04..US-12 (Group Management).

Endpoints (all under /api/v1/groups, all jwt_required):
  POST   /                              US-04  create group -> invite code, creator is admin
  GET    /                              US-06  list groups the current user belongs to
  POST   /join                          US-05  join a group by invite code
  GET    /<group_id>                    US-07  group detail incl. invite code + members
  PATCH  /<group_id>                    US-09  admin: edit name / icon
  DELETE /<group_id>                            admin: delete the group outright
  POST   /<group_id>/leave                      any member: leave (deletes the group if last member)
  DELETE /<group_id>/members/<user_id>  US-08  admin: remove a member
  POST   /<group_id>/transfer-admin     US-10  admin: transfer admin role
  DELETE /<group_id>/lists/<list_id>    US-11  admin: remove a list from the group
  DELETE /<group_id>/recipes/<recipe_id> US-12  admin: remove a recipe from the group
"""
from flask import g
from flask_restx import Namespace, Resource, fields

from app.api.v1.security import jwt_required
from app.models.group import ICON_CHOICES
from app.services.facade import get_facade, FacadeError
from flask import g, request

ns = Namespace("groups", description="Group management (US-04..US-12)")

# ── Swagger models ───────────────────────────────────────────
create_group_model = ns.model(
    "CreateGroupRequest",
    {
        "name": fields.String(required=True, example="Al-Otaibi Household"),
        "image_url": fields.String(required=False, example="https://.../group.png"),
        "icon": fields.String(required=False, enum=list(ICON_CHOICES), example="home"),
        "type": fields.String(required=False, enum=["individual", "household"], example="household"),
    },
)

join_group_model = ns.model(
    "JoinGroupRequest",
    {"invite_code": fields.String(required=True, example="7F3K9A")},
)

update_group_model = ns.model(
    "UpdateGroupRequest",
    {
        "name": fields.String(required=False, example="New Group Name"),
        "image_url": fields.String(required=False, example="https://.../group.png"),
        "icon": fields.String(required=False, enum=list(ICON_CHOICES), example="home"),
    },
)

transfer_admin_model = ns.model(
    "TransferAdminRequest",
    {"new_admin_user_id": fields.String(required=True, example="3fa85f64-5717-4562-b3fc-2c963f66afa6")},
)


def _handle(fn):
    """Run a facade call and map FacadeError to a clean HTTP error."""
    try:
        return fn()
    except FacadeError as e:
        ns.abort(e.status, e.message)


# ── US-04 / US-06 ────────────────────────────────────────────
@ns.route("/")
class Groups(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.expect(create_group_model, validate=True)
    @ns.response(201, "Group created; caller is admin")
    @ns.response(401, "Unauthorized")
    def post(self):
        data = ns.payload
        facade = get_facade()
        result = _handle(
            lambda: facade.create_group(
                user_id=g.user_id,
                name=data["name"],
                image_url=data.get("image_url"),
                icon=data.get("icon"),
                type_=data.get("type", "household"),
            )
        )
        return result, 201

    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(200, "Groups the current user belongs to")
    @ns.response(401, "Unauthorized")
    def get(self):
        facade = get_facade()
        result = _handle(lambda: facade.list_my_groups(user_id=g.user_id))
        return result, 200


# ── US-05 ────────────────────────────────────────────────────
@ns.route("/join")
class JoinGroup(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.expect(join_group_model, validate=True)
    @ns.response(200, "Joined the group")
    @ns.response(404, "Invalid invite code")
    @ns.response(409, "Already a member")
    def post(self):
        data = ns.payload
        facade = get_facade()
        result = _handle(
            lambda: facade.join_group(user_id=g.user_id, invite_code=data["invite_code"])
        )
        return result, 200


# ── US-07 / US-09 ────────────────────────────────────────────
@ns.route("/<string:group_id>")
class GroupDetail(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(200, "Group detail, including invite code and members")
    @ns.response(403, "Not a member of this group")
    @ns.response(404, "Group not found")
    def get(self, group_id):
        facade = get_facade()
        result = _handle(lambda: facade.get_group(user_id=g.user_id, group_id=group_id))
        return result, 200

    @ns.doc(security="Bearer")
    @jwt_required
    @ns.expect(update_group_model, validate=True)
    @ns.response(200, "Group updated")
    @ns.response(403, "Admin role required")
    @ns.response(404, "Group not found")
    def patch(self, group_id):
        data = ns.payload
        facade = get_facade()
        result = _handle(
            lambda: facade.update_group(
                user_id=g.user_id,
                group_id=group_id,
                name=data.get("name"),
                image_url=data.get("image_url"),
                icon=data.get("icon"),
            )
        )
        return result, 200

    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(204, "Group deleted")
    @ns.response(403, "Admin role required")
    @ns.response(404, "Group not found")
    def delete(self, group_id):
        """Admin-only: permanently deletes the group and everything it
        owns (lists, recipes, members)."""
        facade = get_facade()
        _handle(lambda: facade.delete_group(user_id=g.user_id, group_id=group_id))
        return "", 204


# ── leave group (self-service, any member) ────────────────────
@ns.route("/<string:group_id>/leave")
class LeaveGroup(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(200, "Left the group (or deleted it, if you were the last member)")
    @ns.response(400, "Admin must transfer the role before leaving a group with other members")
    @ns.response(403, "Not a member of this group")
    @ns.response(404, "Group not found")
    def post(self, group_id):
        facade = get_facade()
        result = _handle(lambda: facade.leave_group(user_id=g.user_id, group_id=group_id))
        return result, 200


# ── US-08 ────────────────────────────────────────────────────
@ns.route("/<string:group_id>/members")
class GroupMembers(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(200, "Members of the group")
    @ns.response(403, "Not a member of this group")
    @ns.response(404, "Group not found")
    def get(self, group_id):
        """Return all members for a group."""
        facade = get_facade()
        result = _handle(
            lambda: facade.list_group_members(user_id=g.user_id, group_id=group_id)
        )
        return result, 200
@ns.route("/<string:group_id>/members/<string:user_id>")
class GroupMemberResource(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(204, "Member removed")
    @ns.response(400, "Cannot remove yourself or the group admin")
    @ns.response(403, "Admin role required")
    @ns.response(404, "Group or member not found")
    def delete(self, group_id, user_id):
        facade = get_facade()
        _handle(
            lambda: facade.remove_group_member(
                user_id=g.user_id, group_id=group_id, target_user_id=user_id
            )
        )
        return "", 204


# ── US-10 ────────────────────────────────────────────────────
@ns.route("/<string:group_id>/transfer-admin")
class TransferAdmin(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.expect(transfer_admin_model, validate=True)
    @ns.response(200, "Admin role transferred")
    @ns.response(400, "Already the admin")
    @ns.response(403, "Admin role required")
    @ns.response(404, "Group or target member not found")
    def post(self, group_id):
        data = ns.payload
        facade = get_facade()
        _handle(
            lambda: facade.transfer_group_admin(
                user_id=g.user_id,
                group_id=group_id,
                new_admin_user_id=data["new_admin_user_id"],
            )
        )
        return {"message": "Admin role transferred"}, 200


# ── US-11 ────────────────────────────────────────────────────
@ns.route("/<string:group_id>/lists/<string:list_id>")
class GroupListResource(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(204, "List removed from the group")
    @ns.response(403, "Admin role required")
    @ns.response(404, "Group or list not found")
    def delete(self, group_id, list_id):
        facade = get_facade()
        _handle(
            lambda: facade.remove_group_list(user_id=g.user_id, group_id=group_id, list_id=list_id)
        )
        return "", 204


# ── US-12 ────────────────────────────────────────────────────
@ns.route("/<string:group_id>/recipes/<string:recipe_id>")
class GroupRecipeResource(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(204, "Recipe removed from the group")
    @ns.response(403, "Admin role required")
    @ns.response(404, "Group or recipe not found")
    def delete(self, group_id, recipe_id):
        facade = get_facade()
        _handle(
            lambda: facade.remove_group_recipe(
                user_id=g.user_id, group_id=group_id, recipe_id=recipe_id
            )
        )
        return "", 204


# ── US-13 : Group Lists (Create & List) ──────────────────────
create_list_model = ns.model(
    "CreateListRequest",
    {
        "name": fields.String(required=True, example="Weekly Groceries"),
    },
)

@ns.route("/<string:group_id>/lists")
@ns.param("group_id", "The group UUID")
class GroupLists(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.expect(create_list_model, validate=True)
    @ns.response(201, "List created")
    @ns.response(400, "Validation error")
    @ns.response(403, "Not a member of the group")
    @ns.response(404, "Group not found")
    @ns.response(409, "Default group list limit (5) exceeded")
    def post(self, group_id):
        """US-13: Create a new shopping list inside a group."""
        data = ns.payload
        facade = get_facade()
        result = _handle(
            lambda: facade.create_list(
                user_id=g.user_id,
                group_id=group_id,
                name=data["name"],
            )
        )
        return result, 201

    @ns.doc(security="Bearer")
    @jwt_required
    @ns.param("status", "Filter by status: 'active' or 'completed'", _in="query")
    @ns.response(200, "List of shopping lists for the group")
    @ns.response(400, "Invalid status filter")
    @ns.response(403, "Not a member of the group")
    def get(self, group_id):
        """Return all lists for a group."""

        status = request.args.get("status")
        if status and status not in ("active", "completed"):
            ns.abort(400, "status must be 'active' or 'completed'")

        facade = get_facade()
        return _handle(
            lambda: facade.list_group_lists(
                user_id=g.user_id,
                group_id=group_id,
                status=status,
            )
        )
