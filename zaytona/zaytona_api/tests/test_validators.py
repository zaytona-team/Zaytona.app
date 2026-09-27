"""Unit tests for app/models/validators.py — no app context needed."""
import pytest

from app.utils.validators import validate_email, validate_phone


@pytest.mark.parametrize(
    "value",
    [
        "user@example.com",
        "first.last@sub.example.co",
    ],
)
def test_validate_email_accepts_valid(value):
    assert validate_email(value) == value.lower()


@pytest.mark.parametrize(
    "value",
    [
        "a,b@example.com",
        "user@exa,mple.com",
        "user@example,com",
        "user@example.co,m",
    ],
)
def test_validate_email_rejects_comma(value):
    with pytest.raises(ValueError):
        validate_email(value)


def test_validate_email_none_is_optional():
    assert validate_email(None) is None
    assert validate_email("   ") is None


def test_validate_phone_rejects_comma():
    with pytest.raises(ValueError):
        validate_phone("0512345,678")


@pytest.mark.parametrize(
    "value",
    ["0512345678", "+966512345678", "966512345678"],
)
def test_validate_phone_normalizes_all_shapes_to_one_canonical_form(value):
    """Regression: the three accepted shapes for the same physical number
    used to be stored verbatim, so the same real phone submitted in a
    different shape at signup vs. login would be treated as a different
    user (or let someone register twice)."""
    assert validate_phone(value) == "+966512345678"
