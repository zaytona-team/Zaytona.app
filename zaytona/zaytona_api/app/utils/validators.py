"""Shared field-validation helpers for SQLAlchemy `@validates` methods.

Centralised here so every model raises the same, clean `ValueError` shape
for a given kind of bad input (empty string, too long, bad format). The
`ValueError` is caught by the app-level error handler (see
`app/__init__.py`) and turned into a 400, per validation.md section 6.
"""
import re
from app.utils.text_utils import normalize_if_arabic

_EMAIL_RE = re.compile(r"^[^@\s,]+@[^@\s,]+\.[^@\s,]+$")
# Saudi mobile numbers only, per product rule:
#   local:         0 + 9 digits  -> 10 digits total, e.g. 0512345678
#   international: +966 + 5 + 8 digits -> e.g. +966512345678
_PHONE_RE = re.compile(r"^(05\d{8}|\+9665\d{8}|9665\d{8})$")

# Defense-in-depth only — SQLAlchemy already parameterizes every query, so
# these fields can't reach raw SQL. This rejects classic injection-shaped
# input (statement separators, comment markers, quote+keyword combos)
# before it's ever stored, on top of that existing protection.
_SQL_INJECTION_RE = re.compile(
    r"(--|;|/\*|\*/|\bxp_\w+)"
    r"|\b(or|and)\b\s*['\"\d]+\s*=\s*['\"\d]+"
    r"|\b(select|insert|update|delete|drop|union|exec(?:ute)?|alter|truncate)\b"
    r".{0,80}?\b(from|table|database|into|values)\b",
    re.IGNORECASE | re.DOTALL,
)


def _reject_sql_injection(cleaned: str, field: str) -> None:
    if _SQL_INJECTION_RE.search(cleaned):
        raise ValueError(f"{field} contains disallowed characters")


def require_text(value, field: str, max_length: int) -> str:
    """Strip, then require a non-empty, injection-safe string within `max_length`."""
    if value is None or not str(value).strip():
        raise ValueError(f"{field} is required")
    cleaned = str(value).strip()
    cleaned = normalize_if_arabic(cleaned)
    if len(cleaned) > max_length:
        raise ValueError(f"{field} must be at most {max_length} characters")
    _reject_sql_injection(cleaned, field)
    return cleaned


def require_optional_text(value, field: str, max_length: int) -> str | None:
    """Like require_text, but None/empty is allowed through as None."""
    if value is None or not str(value).strip():
        return None
    cleaned = str(value).strip()
    cleaned = normalize_if_arabic(cleaned)
    if len(cleaned) > max_length:
        raise ValueError(f"{field} must be at most {max_length} characters")
    _reject_sql_injection(cleaned, field)
    return cleaned


def validate_email(value) -> str | None:
    """Email is optional; if provided it must look like an email."""
    if value is None or not str(value).strip():
        return None
    cleaned = str(value).strip().lower()
    if not _EMAIL_RE.match(cleaned):
        raise ValueError("email is not a valid email address")
    return cleaned


def validate_phone(value) -> str:
    """Phone is required and must be a Saudi mobile number, accepted in any
    of three shapes — 05XXXXXXXX (local), +9665XXXXXXXX, or 9665XXXXXXXX
    (international with/without the leading '+') — but always normalized
    to the single canonical +9665XXXXXXXX form before being returned.

    Without this normalization, the same physical number submitted in a
    different shape (e.g. once as "0512345678", once as "+966512345678")
    would fail the `users.phone` uniqueness check and create a second
    account, and a login attempt in a different shape than the one used
    at signup would fail to find the existing user at all — phone is the
    only identity check in this system (see AuthFacadeMixin), so a single
    canonical form is required for both to work.
    """
    if value is None or not str(value).strip():
        raise ValueError("phone is required")
    cleaned = str(value).strip()
    if not _PHONE_RE.match(cleaned):
        raise ValueError(
            "phone must be a valid Saudi mobile number: 05XXXXXXXX (10 digits) "
            "or +9665XXXXXXXX"
        )
    if cleaned.startswith("+966"):
        return cleaned
    if cleaned.startswith("966"):
        return f"+{cleaned}"
    return f"+966{cleaned[1:]}"  # local 05XXXXXXXX -> +9665XXXXXXXX


def require_positive_quantity(value, max_value: float = 100_000) -> float:
    if value is None:
        raise ValueError("quantity is required")
    try:
        quantity = float(value)
    except (TypeError, ValueError):
        raise ValueError("quantity must be a number")
    if quantity <= 0:
        raise ValueError("quantity must be greater than 0")
    if quantity > max_value:
        raise ValueError(f"quantity must be at most {max_value}")
    return quantity


def require_allowed_unit(value, allowed_units) -> str:
    if value not in allowed_units:
        raise ValueError(f"unit must be one of: {', '.join(allowed_units)}")
    return value


def require_one_of(value, field: str, allowed) -> str:
    """Generic enum-membership check.

    SQLAlchemy's `Enum` type only rejects out-of-set values at read time on
    backends without a native enum (e.g. sqlite) — on write it silently
    stores whatever string it's given. Postgres (prod) enforces this itself
    via a native enum type, but this closes the gap everywhere else.
    """
    if value not in allowed:
        raise ValueError(f"{field} must be one of: {', '.join(allowed)}")
    return value


def require_positive_int(value, field: str, max_value: int = 100_000) -> int:
    if value is None:
        raise ValueError(f"{field} is required")
    try:
        as_float = float(value)
    except (TypeError, ValueError):
        raise ValueError(f"{field} must be a whole number")
    if not as_float.is_integer():
        raise ValueError(f"{field} must be a whole number")
    number = int(as_float)
    if number <= 0:
        raise ValueError(f"{field} must be greater than 0")
    if number > max_value:
        raise ValueError(f"{field} must be at most {max_value}")
    return number
