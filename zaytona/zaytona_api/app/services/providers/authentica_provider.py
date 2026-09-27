"""Authentica OTP provider (US-36).

OTP is owned by Authentica (https://authentica.sa), NOT Supabase. This
provider sends and verifies one-time passwords via Authentica's v2 REST API.

Confirmed contract (github.com/AuthenticaSA/Authentica — official examples
+ docs/otp.md, since the Apiary page itself is a JS app with no static
content to read):
  Base URL : https://api.authentica.sa
  Auth     : header  X-Authorization: <API_KEY>
  Headers  : Accept: application/json, Content-Type: application/json

  POST /api/v2/send-otp
    body: {"method": "sms"|"whatsapp"|"email", "phone": "+9665..."}  (or "email" instead of "phone")
    -> 200 {"success": true, "data": null, "message": "OTP sent successfully."}

  POST /api/v2/verify-otp
    body: {"phone": "+9665...", "otp": "123456"}  (or "email" instead of "phone")
    -> 200 {"status": true, "message": "OTP verified successfully"}   -- live response,
       confirmed 2026-07-06 against a real code. NOT "verified" or "success" as the
       published examples suggest — checking those two keys made a *correct* code
       always read back as "Invalid or expired OTP" (see verify_otp below).

Authentica does not fall back between channels on its own — its own docs
say "if delivery is inconsistent, try another channel" — so the automatic
fallback required by US-36 ("if one channel fails, the app automatically
falls back to an available alternative") is implemented in this class:
send_otp tries whatsapp, then sms, then email in turn, stopping at the
first channel Authentica accepts.
"""
import logging

import requests
from flask import current_app

logger = logging.getLogger("zaytona.authentica")

# Fallback order tried after the configured primary channel.
_CHANNEL_FALLBACK_ORDER = ("whatsapp", "sms", "email")


class AuthenticaError(Exception):
    def __init__(self, message, status=400):
        super().__init__(message)
        self.message = message
        self.status = status


class AuthenticaProvider:
    def __init__(self):
        cfg = current_app.config
        self.base_url = cfg["AUTHENTICA_BASE_URL"].rstrip("/")
        self.api_key = cfg["AUTHENTICA_API_KEY"]
        self.method = cfg["AUTHENTICA_OTP_METHOD"]          # primary channel, e.g. "whatsapp"
        self.template_id = cfg["AUTHENTICA_TEMPLATE_ID"]    # WhatsApp-only approved template id
        self.fallback_email = cfg["AUTHENTICA_FALLBACK_EMAIL"]

    def _headers(self):
        return {
            "Accept": "application/json",
            "Content-Type": "application/json",
            "X-Authorization": self.api_key,
        }

    def _post(self, path, payload):
        url = f"{self.base_url}{path}"
        # Loud logging so requests are visible in the terminal (project goal).
        # Never log the code itself.
        safe = {k: v for k, v in payload.items() if k != "otp"}
        logger.info("→ Authentica POST %s  %s", path, safe)
        resp = requests.post(url, json=payload, headers=self._headers(), timeout=20)
        data = resp.json() if resp.content else {}
        logger.info("← Authentica %s  status=%s  body=%s", path, resp.status_code, data)
        if not resp.ok:
            msg = data.get("message") or data.get("error") or "Authentica request failed"
            raise AuthenticaError(msg, status=resp.status_code)
        return data

    def _send_via(self, method, *, phone=None, email=None):
        body = {"method": method}
        if method == "email":
            if not email:
                raise AuthenticaError("No email address available for the email channel", status=400)
            body["email"] = email
        else:
            body["phone"] = phone
            # template_id is a Meta-approved WhatsApp template id; sms/email don't take one.
            if method == "whatsapp" and self.template_id:
                body["template_id"] = self.template_id
        data = self._post("/api/v2/send-otp", body)
        return {"success": bool(data.get("success", True)), "method": method, "raw": data}

    # ── US-36 : send OTP, falling back across channels ourselves ────
    def send_otp(self, *, phone, email=None, channel=None):
        """Try the configured primary channel first, then whatsapp/sms/email
        (skipping duplicates) until one is accepted by Authentica.

        If `channel` is given, it's an explicit user choice (e.g. the
        resend picker) — send via that channel only, no fallback, so a
        pick of "sms" never silently degrades to whatsapp/email.
        """
        fallback_email = email or self.fallback_email

        if channel is not None:
            return self._send_via(channel, phone=phone, email=fallback_email)

        chain = []
        for channel in (self.method, *_CHANNEL_FALLBACK_ORDER):
            if channel in chain:
                continue
            if channel == "email" and not fallback_email:
                continue
            chain.append(channel)

        last_error = None
        for channel in chain:
            try:
                return self._send_via(channel, phone=phone, email=fallback_email)
            except AuthenticaError as e:
                logger.warning("OTP send via %s failed (%s); trying next channel", channel, e)
                last_error = e

        raise last_error or AuthenticaError("All OTP channels failed", status=502)

    # ── US-36 : verify OTP ───────────────────────────────────
    def verify_otp(self, *, otp, phone=None, email=None):
        body = {"otp": otp}
        if phone:
            body["phone"] = phone
        elif email:
            body["email"] = email
        data = self._post("/api/v2/verify-otp", body)
        # Confirmed against the live API: a correct code comes back as
        # {"status": true, "message": "OTP verified successfully"} — not
        # "verified" or "success". Checking only those two keys made this
        # always fall through to False, so a *correct* code was reported
        # as "Invalid or expired OTP". Keep the other keys as a fallback
        # in case Authentica's shape ever changes.
        return bool(data.get("status", data.get("verified", data.get("success", False))))

    # ── optional: account balance (handy for terminal testing) ──
    def balance(self):
        url = f"{self.base_url}/api/v2/balance"
        resp = requests.get(url, headers={"Accept": "application/json", "X-Authorization": self.api_key}, timeout=15)
        data = resp.json() if resp.content else {}
        if not resp.ok:
            raise AuthenticaError(data.get("message", "balance failed"), status=resp.status_code)
        return data
