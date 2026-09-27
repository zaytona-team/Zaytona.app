"""Small helpers shared across every facade mixin."""
import uuid


def _is_uuid(value) -> bool:
    """Group/member/list/recipe ids are Postgres UUID columns — a malformed
    id (e.g. a typo'd URL segment) would otherwise reach the DB driver and
    surface as a raw 500 instead of a clean 404."""
    try:
        uuid.UUID(str(value))
        return True
    except (ValueError, AttributeError, TypeError):
        return False
