"""Auth mixin — US-01/02/03/36.

There is no password. Authentica OTP is the only identity check:
  * register (US-01)  -> creates the user (phone_verified=False) and
                          their default group, then sends the first OTP
  * login (US-02)      -> looks the user up, sends a fresh OTP
  * otp/verify (US-36) -> verifies the code with Authentica, then flips
                          phone_verified on the (already-existing) user
                          and issues the app's own JWT — same code path
                          for both signup and login

Requires `self.users` (UserRepository), `self.groups` (GroupRepository),
and `self.authentica` (AuthenticaProvider) from the composed facade.
"""
import logging
import time

import jwt
from flask import current_app
from sqlalchemy.exc import IntegrityError

from app.extensions import db
from app.services.facade.errors import FacadeError
from app.services.providers.authentica_provider import AuthenticaError
from app.utils.validators import require_text, validate_phone

logger = logging.getLogger("zaytona.facade")


class AuthFacadeMixin:
    # ── US-01 : register ─────────────────────────────────────
    def register_user(self, *, first_name, last_name, email, phone):
        """Create the user (phone_verified=False) and their default
        personal group, then send the signup OTP. /otp/verify simply
        flips phone_verified once Authentica confirms the code.
        """
        first_name = require_text(first_name, "first_name", max_length=80)
        last_name = require_text(last_name, "last_name", max_length=80)
        try:
            phone = validate_phone(phone)
        except ValueError as e:
            raise FacadeError(str(e), status=400)

        if self._email_taken(email):
            raise FacadeError("Email already registered", status=409)
        if self.users.get_by_phone(phone):
            raise FacadeError("Phone already registered", status=409)

        # Deferred commit: user + default group + membership are one
        # logical unit. A failure partway through (e.g. a concurrent
        # duplicate-phone insert slipping past the pre-check above) must
        # not leave an orphaned user with no group, or a group with no
        # admin — so nothing is committed until all three writes succeed.
        try:
            user = self.users.create(
                first_name=first_name,
                last_name=last_name,
                email=email,
                phone=phone,
                phone_verified=False,
                commit=False,
            )

            # ── Auto-create default personal group ───────────────
            # Named after the user themself, not "X's Personal Group" —
            # it's their own single-member space, the possessive framing
            # read as generic-grocery-app boilerplate rather than "this is
            # you." Type is 'individual' (not 'household') to mark it as
            # the free-tier personal group with the 5-list cap.
            default_group = self.groups.create(
                name=f"{first_name} {last_name}".strip(),
                created_by=user.user_id,
                type_="individual",
                commit=False,
            )
            self.groups.add_member(
                group_id=default_group.group_id,
                user_id=user.user_id,
                role="admin",
                commit=False,
            )

            # Send the OTP before writing anything at all. A phone number can
            # pass the shape check (validate_phone) yet not actually exist/be
            # reachable on any Authentica channel — in that case reject the
            # registration outright: nothing gets written to the users table.
            if self._dev_otp_bypass(phone):
                otp_sent, otp_method = True, "dev-bypass"
            else:
                try:
                    send = self.authentica.send_otp(phone=phone, email=email)
                    otp_sent, otp_method = send["success"], send["method"]
                except AuthenticaError as e:
                    logger.warning(
                        "OTP dispatch failed during registration: %s", e)
                    otp_sent, otp_method = False, None

            if not otp_sent:
                raise FacadeError(
                    "Could not send an OTP to this phone number. Please check it and try again.",
                    status=422,
                )

            db.session.commit()

            return {
                "otp_sent": otp_sent,
                "otp_method": otp_method,
                "message": "Verify the OTP we just sent to finish creating your account.",
            }
        except IntegrityError as e:
            db.session.rollback()
            logger.error(f"DEBUG IntegrityError: {e.orig}")
            raise FacadeError(
                "An account with this phone or email already exists", status=409
            )
        except Exception as e:
            db.session.rollback()
            if isinstance(e, FacadeError):
                raise e
            logger.error("Unexpected error during user registration: %s", e)
            raise FacadeError(
                "Registration failed due to a server error", status=500)

    # ── US-02 : login (request step) ─────────────────────────
    def login(self, *, identifier):
        """Look the user up by email or phone and send a fresh OTP.

        Accepts either identifier: an '@' in the string means email,
        otherwise it's treated as a phone number. Verification always
        goes through /otp/verify (US-36) — there is no direct-login path.
        """
        is_phone = "@" not in identifier
        if is_phone:
            try:
                identifier = validate_phone(identifier)
            except ValueError as e:
                raise FacadeError(str(e), status=400)
        user = self.users.get_by_phone(
            identifier) if is_phone else self.users.get_by_email(identifier)
        if not user:
            raise FacadeError(
                "No account found for that email/phone", status=404)

        if self._dev_otp_bypass(user.phone):
            send = {"success": True, "method": "dev-bypass"}
        else:
            send = self.authentica.send_otp(phone=user.phone, email=user.email)
        return {
            "phone": user.phone,
            "otp_sent": send["success"],
            "otp_method": send["method"],
            "message": "Enter the OTP sent to your phone to complete login.",
        }

    # ── US-36 : OTP resend (Authentica) ───────────────────────

    def resend_otp(self, *, phone, channel=None):
        try:
            phone = validate_phone(phone)
        except ValueError as e:
            raise FacadeError(str(e), status=400)
        if channel is not None and channel not in ("whatsapp", "sms", "email"):
            raise FacadeError("channel must be one of: whatsapp, sms, email", status=400)
        user = self.users.get_by_phone(phone)
        if not user:
            raise FacadeError("No account found for that phone", status=404)
        if self._dev_otp_bypass(phone):
            send = {"success": True, "method": "dev-bypass"}
        else:
            send = self.authentica.send_otp(phone=phone, email=user.email, channel=channel)
        return {"otp_sent": send["success"], "otp_method": send["method"]}

    # ── dev/staging only: whitelisted test numbers skip Authentica
    # entirely and accept a fixed OTP, so manual testing doesn't burn a
    # real OTP send on every login/signup. Never true in ProductionConfig.
    #
    # Phone is normalized on both sides before comparing, so
    # "0555455544" / "966555455544" / "+966555455544" all match the
    # whitelist regardless of which shape the client sent or the
    # whitelist env var was written in.
    def _dev_otp_bypass(self, phone) -> bool:
        cfg = current_app.config
        if not cfg.get("DEV_OTP_ENABLED"):
            return False
        try:
            normalized = validate_phone(phone)
        except ValueError:
            return False
        whitelist = set()
        for p in cfg.get("DEV_OTP_WHITELIST_PHONES", []):
            try:
                whitelist.add(validate_phone(p))
            except ValueError:
                continue
        return normalized in whitelist

    # ── US-36 : verify OTP -> issues the session token ────────
    def verify_otp(self, *, phone, token, email=None):
        """Verify the code with Authentica, then flip phone_verified on
        the user (created at /register for signups, pre-existing for
        logins) and mint this API's own JWT. Same path for both flows,
        since neither has a password to check separately."""
        try:
            phone = validate_phone(phone)
        except ValueError as e:
            raise FacadeError(str(e), status=400)
        if self._dev_otp_bypass(phone):
            ok = token == current_app.config["DEV_OTP_CODE"]
        else:
            ok = self.authentica.verify_otp(
                otp=token, phone=phone, email=email)
        if not ok:
            raise AuthenticaError("Invalid or expired OTP", status=400)

        user = self.users.mark_phone_verified(phone=phone)
        if not user:
            raise FacadeError("No account found for that phone", status=404)

        cfg = current_app.config
        return {
            "verified": True,
            "access_token": self._issue_token(
                user.user_id, token_type="access", expires_seconds=cfg["JWT_ACCESS_EXPIRES_SECONDS"]
            ),
            "refresh_token": self._issue_token(
                user.user_id, token_type="refresh", expires_seconds=cfg["JWT_EXPIRES_SECONDS"]
            ),
            "token_type": "Bearer",
            "user": user.to_dict(),
        }

    # ── refresh: trade a still-valid refresh token for a new access
    # token. Refresh tokens aren't rotated — there's no session store to
    # invalidate old ones against, consistent with this API's stateless
    # JWT design (see module docstring).
    def refresh_access_token(self, *, refresh_token):
        try:
            payload = jwt.decode(
                refresh_token, current_app.config["SECRET_KEY"], algorithms=[
                    "HS256"]
            )
        except jwt.ExpiredSignatureError:
            raise FacadeError("Refresh token expired", status=401)
        except jwt.InvalidTokenError:
            raise FacadeError("Invalid refresh token", status=401)

        if payload.get("type") != "refresh":
            raise FacadeError("Not a refresh token", status=401)

        user = self.users.get_by_id(payload.get("sub"))
        if not user:
            raise FacadeError("No account found for this token", status=401)

        cfg = current_app.config
        return {
            "access_token": self._issue_token(
                user.user_id, token_type="access", expires_seconds=cfg["JWT_ACCESS_EXPIRES_SECONDS"]
            ),
            "token_type": "Bearer",
        }

    def _email_taken(self, email) -> bool:
        # Treat the literal string "null" as no email at all (some clients
        # send that instead of omitting the field) — but this must depend
        # on the *submitted* email, not on whether some unrelated user
        # happens to have "null" stored: checking the latter (as this used
        # to) meant that once any such row existed, this check silently
        # passed for every future registration, since it doesn't reference
        # `email` at all.
        if not email or email.strip().lower() == "null":
            return False
        return bool(self.users.get_by_email(email))

    # ── US-03 : update profile (display name + avatar) ───────
    # reminders_enabled: the per-user switch for the 12h "list still has
    # items" push reminders — lives here since /me is already the one
    # touchpoint for personal-preference updates.
    def update_profile(self, *, user_id, first_name=None, last_name=None, email=None, avatar_url=None,
                       reminders_enabled=None):
        if email:
            existing_user = self.users.get_by_email(email)
            if existing_user and existing_user.user_id != user_id:
                raise FacadeError("Email already registered", status=409)
        user = self.users.update_profile(
            user_id,
            first_name=first_name,
            last_name=last_name,
            email=email,
            avatar_url=avatar_url,
            reminders_enabled=reminders_enabled,
        )
        if not user:
            raise FacadeError("Profile not found", status=404)
        return user.to_dict()

    # ── internal: mint this API's own session token ──────────
    # 'type' distinguishes short-lived access tokens from the longer-lived
    # refresh token — jwt_required rejects a refresh token used as an
    # access token; refresh_access_token rejects the reverse.
    def _issue_token(self, user_id: str, *, token_type: str, expires_seconds: int) -> str:
        now = int(time.time())
        payload = {
            "sub": str(user_id),
            "type": token_type,
            "iat": now,
            "exp": now + expires_seconds,
        }
        return jwt.encode(payload, current_app.config["SECRET_KEY"], algorithm="HS256")
