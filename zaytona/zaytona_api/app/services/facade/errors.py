"""FacadeError — the one exception type every facade mixin raises for
client-facing failures, carrying the HTTP status the API layer should
map it to."""


class FacadeError(Exception):
    """Raised for auth-flow errors that aren't provider-specific."""

    def __init__(self, message, status=400):
        super().__init__(message)
        self.message = message
        self.status = status
