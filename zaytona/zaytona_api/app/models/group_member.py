"""GROUP_MEMBER model — junction user<->group with role (US-04..US-10).

Admin role is singular per group: transferring it (US-10) flips the old
admin's role to "member" in the same transaction as promoting the new one.
"""
from datetime import datetime, timezone

from app.extensions import db
from app.models.base_model import _utcnow, UUIDType, gen_uuid



class GroupMember(db.Model):
    __tablename__ = "group_members"
    __table_args__ = (db.UniqueConstraint("group_id", "user_id", name="uq_group_member"),)

    member_id = db.Column(UUIDType, primary_key=True, default=gen_uuid)
    group_id = db.Column(UUIDType, db.ForeignKey("groups.group_id"), nullable=False, index=True)
    user_id = db.Column(UUIDType, db.ForeignKey("users.user_id"), nullable=False, index=True)
    role = db.Column(db.Enum("admin", "member", name="group_role"), nullable=False, default="member")
    joined_at = db.Column(db.DateTime(timezone=True), default=_utcnow, nullable=False)


    user = db.relationship("User", foreign_keys=[user_id], lazy="joined")
    
    def to_dict(self) -> dict:
        return {
            "member_id": self.member_id,
            "group_id": self.group_id,
            "user_id": self.user_id,
            "first_name": self.user.first_name if self.user else None,
            "last_name": self.user.last_name if self.user else None,
            "avatar_url": self.user.avatar_url if self.user else None,
            "role": self.role,
            "joined_at": self.joined_at.isoformat() if self.joined_at else None,
        }
