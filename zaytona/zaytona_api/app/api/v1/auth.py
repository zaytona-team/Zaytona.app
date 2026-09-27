"""Auth API namespace — US-01, US-02, US-03, US-36.

Endpoints (all under /api/v1/auth):
  POST  /register      US-01  create the user (phone_verified=False) + their
                               default group, send the signup OTP
  POST  /login          US-02  look up by email/phone, send a fresh OTP
  POST  /otp/verify     US-36  verify the OTP -> flips phone_verified, JWT
  POST  /otp/resend     US-36  resend OTP (Authentica; WhatsApp + email fallback)
  GET   /me              current user's profile (jwt_required)
  PATCH /me              US-03  update display name / avatar (jwt_required)

There's no password: Authentica OTP is the only identity check. Both
register and login end at the same /otp/verify step, which is what
actually mints the session token (see AuthFacadeMixin).
"""
import logging
import os

from app.api.v1.security import jwt_required
from app.services.facade import FacadeError, get_facade
from app.services.providers.authentica_provider import AuthenticaError
from flask import g, request
from flask_restx import Namespace, Resource, fields
from supabase import Client, create_client

ns = Namespace("auth", description="Authentication & onboarding (US-01/02/03/36)")

# ── Swagger models ───────────────────────────────────────────
register_model = ns.model(
    "RegisterRequest",
    {
        "first_name": fields.String(required=True, example="Abdullah"),
        "last_name": fields.String(required=True, example="Al-Otaibi"),
        "email": fields.String(required=False, example="ab@example.com"),
        "phone": fields.String(required=True, example="+966500000000"),
    },
)

login_model = ns.model(
    "LoginRequest",
    {
        # email OR phone — anything with '@' is treated as email
        "identifier": fields.String(required=True, example="+966500000000"),
    },
)

otp_verify_model = ns.model(
    "OtpVerifyRequest",
    {
        "phone": fields.String(required=True, example="+966500000000"),
        "email": fields.String(required=False, example="ab@example.com"),
        "token": fields.String(required=True, example="123456"),
    },
)

otp_resend_model = ns.model(
    "OtpResendRequest",
    {
        "phone": fields.String(required=True, example="+966500000000"),
        "channel": fields.String(
            required=False, enum=["whatsapp", "sms", "email"], example="whatsapp"
        ),
    },
)

refresh_model = ns.model(
    "RefreshRequest",
    {
        "refresh_token": fields.String(required=True, example="eyJhbGciOi..."),
    },
)

update_profile_model = ns.model(
    "UpdateProfileRequest",
    {
        "first_name": fields.String(required=False, example="Abdullah"),
        "last_name": fields.String(required=False, example="Al-Otaibi"),
        "email": fields.String(required=False, example="Al-Otaibi@test.test"),
        "reminders_enabled": fields.Boolean(
            required=False, example=True, description="Toggle the 12h list-reminder push notifications"
        ),
    },
)

select_avatar_model = ns.model(
    "SelectAvatarRequest",
    {
        "avatar_id": fields.String(
            required=True,
            example="av-1.png",
            description="The filename of the selected avatar (e.g., av-1.png, av-2.png)"
        ),
    },
)


def _handle(fn):
    """Run a facade call and map provider/facade errors to a clean HTTP error."""
    try:
        return fn()
    except (FacadeError, AuthenticaError) as e:
        ns.abort(e.status, e.message)


# ── US-01 ────────────────────────────────────────────────────
@ns.route("/register")
class Register(Resource):
    @ns.expect(register_model, validate=True)
    @ns.response(201, "User + default group created; OTP dispatched to verify the phone")
    @ns.response(400, "Validation error")
    @ns.response(409, "Email or phone already registered")
    def post(self):
        data = ns.payload
        facade = get_facade()
        result = _handle(
            lambda: facade.register_user(
                first_name=data["first_name"],
                last_name=data["last_name"],
                email=data.get("email"),
                phone=data["phone"],
            )
        )
        return result, 201


# ── US-02 ────────────────────────────────────────────────────
@ns.route("/login")
class Login(Resource):
    @ns.expect(login_model, validate=True)
    @ns.response(200, "OTP dispatched; verify it at /otp/verify to get a token")
    @ns.response(404, "No account found for that phone")
    def post(self):
        data = ns.payload
        facade = get_facade()
        result = _handle(lambda: facade.login(identifier=data["identifier"]))
        return result, 200


# ── US-36 ────────────────────────────────────────────────────
@ns.route("/otp/verify")
class OtpVerify(Resource):
    @ns.expect(otp_verify_model, validate=True)
    @ns.response(200, "OTP verified; returns the session token")
    @ns.response(400, "Invalid or expired OTP")
    def post(self):
        data = ns.payload
        facade = get_facade()
        result = _handle(
            lambda: facade.verify_otp(
                phone=data["phone"],
                email=data.get("email"),
                token=data["token"],
            )
        )
        return result, 200


@ns.route("/otp/resend")
class OtpResend(Resource):
    @ns.expect(otp_resend_model, validate=True)
    @ns.response(200, "OTP re-dispatched via Authentica")
    def post(self):
        data = ns.payload
        facade = get_facade()
        result = _handle(
            lambda: facade.resend_otp(phone=data["phone"], channel=data.get("channel"))
        )
        return result, 200


@ns.route("/refresh")
class Refresh(Resource):
    @ns.expect(refresh_model, validate=True)
    @ns.response(200, "New access token issued")
    @ns.response(401, "Invalid or expired refresh token")
    def post(self):
        data = ns.payload
        facade = get_facade()
        result = _handle(lambda: facade.refresh_access_token(refresh_token=data["refresh_token"]))
        return result, 200


# ── /me : profile ──────────────────────────────────────────
@ns.route("/me")
class Me(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(200, "Current user's profile")
    @ns.response(401, "Unauthorized")
    def get(self):
        facade = get_facade()
        user = facade.users.get_by_id(g.user_id)
        if not user:
            ns.abort(404, "Profile not found")
        return user.to_dict(), 200

    # ── US-03 ────────────────────────────────────────────────
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.expect(update_profile_model, validate=True)
    @ns.response(200, "Profile updated")
    @ns.response(401, "Unauthorized")
    def patch(self):
        data = ns.payload
        facade = get_facade()
        result = _handle(
            lambda: facade.update_profile(
                user_id=g.user_id,
                first_name=data.get("first_name"),
                last_name=data.get("last_name"),
                email=data.get("email"),
                avatar_url=data.get("avatar_url"),
                reminders_enabled=data.get("reminders_enabled"),
            )
        )
        return result, 200


# ── Default Avatars Endpoints ──────────────────────────────────────────────
supabase: Client = create_client(
    os.getenv("SUPABASE_URL"), os.getenv("SUPABASE_SERVICE_KEY")
)


@ns.route("/avatars")
class DefaultAvatarsList(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(200, "List of available avatars")
    def get(self):
        """Fetch the list of available default avatars from storage."""
        try:
            # Fetch files from the 'avatars' bucket
            files = supabase.storage.from_('avatars').list()

            avatars = []
            for file in files:
                # Filter for image files starting with 'av-'
                if file['name'].startswith('av-') and file['name'].endswith(('.jpg', '.jpeg', '.png', '.webp')):
                    avatar_url = supabase.storage.from_('avatars').get_public_url(file['name'])
                    clean_url = avatar_url.replace('.co//', '.co/').rstrip('?')
                    avatars.append({
                        "id": file['name'],
                        "url": clean_url,
                    })

            return {"avatars": avatars}, 200
            
        except Exception as e:
            logging.error(f"Failed to fetch avatars: {str(e)}")
            return {"error": "Failed to load avatars"}, 500


@ns.route("/profile/avatar/select")
class SelectAvatar(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.expect(select_avatar_model)
    @ns.response(200, "Avatar selected successfully")
    @ns.response(404, "Avatar not found")
    def post(self):
        """Select a default avatar and update the user's profile."""
        user_id = g.user_id
        data = request.get_json()
        
        avatar_id = data.get('avatar_id')
        if not avatar_id:
            return {"error": "avatar_id is required"}, 400
        
        try:
            # Verify the avatar exists in the storage bucket
            files = supabase.storage.from_('avatars').list()
            file_names = [f['name'] for f in files]
            
            if avatar_id not in file_names:
                return {"error": "Avatar not found"}, 404
            
            # Get the public URL for the selected avatar
            avatar_url = supabase.storage.from_('avatars').get_public_url(avatar_id)
            
            # Update user profile with the new avatar URL
            facade = get_facade()
            updated_user = facade.update_profile(
                user_id=user_id,
                avatar_url=avatar_url
            )
            
            return {
                "message": "Avatar selected successfully",
                "user": updated_user
            }, 200
            
        except Exception as e:
            logging.error(f"Failed to select avatar for user {user_id}: {str(e)}")
            return {"error": f"Failed to select avatar: {str(e)}"}, 500
