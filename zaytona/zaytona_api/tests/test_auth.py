"""Smoke tests for the auth namespace (US-01/02/36).

These use Flask's test client and monkeypatch the facade so they run
without a live Supabase connection. Run with: pytest
"""
import json
import pytest

from app import create_app
from app.config import Config


class TestConfig(Config):
    TESTING = True
    SQLALCHEMY_DATABASE_URI = "sqlite:///:memory:"
    # Config.SQLALCHEMY_ENGINE_OPTIONS sets connect_args={"connect_timeout": 10}
    # for Postgres; sqlite3.connect() rejects that kwarg, so drop it here.
    SQLALCHEMY_ENGINE_OPTIONS = {}


@pytest.fixture
def client(monkeypatch):
    app = create_app(TestConfig)
    return app.test_client()


def test_register_validates_payload(client):
    # missing fields -> 400 from flask-restx validation
    resp = client.post("/api/v1/auth/register", json={"email": "x@y.com"})
    assert resp.status_code == 400


def test_login_requires_identifier(client):
    resp = client.post("/api/v1/auth/login", json={})
    assert resp.status_code == 400


def test_otp_verify_requires_token(client):
    resp = client.post("/api/v1/auth/otp/verify", json={"phone": "+966500000000"})
    assert resp.status_code == 400


def test_otp_verify_requires_phone(client):
    resp = client.post("/api/v1/auth/otp/verify", json={"token": "123456"})
    assert resp.status_code == 400


def test_otp_resend_requires_phone(client):
    resp = client.post("/api/v1/auth/otp/resend", json={})
    assert resp.status_code == 400

def test_register_creates_user_row_immediately(client, monkeypatch):
    """Per AuthFacadeMixin.register_user's docstring, register creates the
    user (phone_verified=False) and their default personal group up front,
    then sends the OTP — verify only flips phone_verified. There is no
    deferred-creation/registration_token step."""
    from app.services.providers.authentica_provider import AuthenticaProvider

    def fake_send_otp(self, **kwargs):
        return {"success": True, "method": "whatsapp"}

    monkeypatch.setattr(AuthenticaProvider, "send_otp", fake_send_otp)

    resp = client.post(
        "/api/v1/auth/register",
        json={
            "first_name": "Abdullah",
            "last_name": "Al-Otaibi",
            "email": "ah.r9625@gmail.com",
            "phone": "+966567888522",
        },
    )
    assert resp.status_code == 201
    data = resp.get_json()

    # Register's response is just the OTP dispatch outcome — the user/
    # group objects themselves aren't echoed back until /otp/verify.
    assert data["otp_sent"] is True
    assert "user" not in data
    assert "registration_token" not in data

    from app.services.facade import get_facade
    with client.application.app_context():
        facade = get_facade()
        user = facade.users.get_by_phone("+966567888522")
        assert user is not None
        assert user.phone_verified is False

        default_group = facade.groups.list_groups_for_user(user.user_id)[0]
        assert default_group.type == "individual"
        assert default_group.created_by == user.user_id


def test_otp_verify_flips_phone_verified(client, monkeypatch):
    """Per documentation: 'Backend automatically creates the user's default
    personal group' — at register time (see the test above). /otp/verify's
    job is only to confirm the code and flip phone_verified, then mint the
    session token."""
    from app.services.providers.authentica_provider import AuthenticaProvider

    monkeypatch.setattr(
        AuthenticaProvider, "send_otp",
        lambda self, **kwargs: {"success": True, "method": "whatsapp"},
    )
    monkeypatch.setattr(AuthenticaProvider, "verify_otp", lambda self, **kwargs: True)

    client.post(
        "/api/v1/auth/register",
        json={
            "first_name": "Abdullah",
            "last_name": "Al-Otaibi",
            "email": "ah.r9625@gmail.com",
            "phone": "+966567888522",
        },
    )

    resp = client.post(
        "/api/v1/auth/otp/verify",
        json={"phone": "+966567888522", "token": "123456"},
    )
    assert resp.status_code == 200
    data = resp.get_json()

    assert data["access_token"]
    assert data["user"]["phone_verified"] is True

    from app.services.facade import get_facade
    with client.application.app_context():
        facade = get_facade()
        default_group = facade.groups.list_groups_for_user(data["user"]["user_id"])[0]
        assert default_group.name == "Abdullah Al-Otaibi"
        assert default_group.type == "individual"


def test_register_rejects_email_already_used_by_a_verified_user(client, monkeypatch):
    """Regression: _email_taken used to check whether *any* user had the
    literal email 'null' instead of checking the submitted email itself —
    a check that didn't reference the submitted email at all, and would
    silently stop catching real duplicates under the right (wrong) DB
    state. Exercise the ordinary duplicate-email path end to end."""
    from app.services.providers.authentica_provider import AuthenticaProvider

    monkeypatch.setattr(
        AuthenticaProvider, "send_otp",
        lambda self, **kwargs: {"success": True, "method": "whatsapp"},
    )
    monkeypatch.setattr(AuthenticaProvider, "verify_otp", lambda self, **kwargs: True)

    client.post(
        "/api/v1/auth/register",
        json={
            "first_name": "Abdullah",
            "last_name": "Al-Otaibi",
            "email": "dup@example.com",
            "phone": "+966567888522",
        },
    )
    client.post(
        "/api/v1/auth/otp/verify",
        json={"phone": "+966567888522", "token": "123456"},
    )

    second_register = client.post(
        "/api/v1/auth/register",
        json={
            "first_name": "Sara",
            "last_name": "Al-Harbi",
            "email": "dup@example.com",
            "phone": "+966512345678",
        },
    )
    assert second_register.status_code == 409