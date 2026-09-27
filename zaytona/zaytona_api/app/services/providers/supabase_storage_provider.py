"""Supabase Storage provider — user-uploaded item images.

Mirrors FirebaseProvider's shape: lazy init (a missing/misconfigured
credential must not break every unrelated API request), one plain
method the facade calls, its own error type.

Uses the service-role key (SUPABASE_SERVICE_KEY) — never the anon key —
since uploads bypass Supabase's own row-level auth and rely entirely on
this backend's own membership guard (ItemFacadeMixin.upload_item_image)
having already run before this is ever called.
"""
import uuid

from flask import current_app
from supabase import create_client

ITEM_IMAGES_BUCKET = "item-images"


class StorageError(Exception):
    def __init__(self, message, status=502):
        super().__init__(message)
        self.message = message
        self.status = status


class SupabaseStorageProvider:
    def __init__(self):
        self._client = None

    def _ensure_client(self):
        if self._client is not None:
            return self._client
        url = current_app.config.get("SUPABASE_URL")
        key = current_app.config.get("SUPABASE_SERVICE_KEY")
        if not url or not key:
            raise StorageError(
                "SUPABASE_URL / SUPABASE_SERVICE_KEY are not set", status=500
            )
        self._client = create_client(url, key)
        return self._client

    # ── replace the image for one list item ──────────────────
    def upload_item_image(
        self, *, item_id: str, file_bytes: bytes, content_type: str, ext: str
    ) -> str:
        """Uploads file_bytes as the new image for this item, deleting
        any image(s) already stored for it first — each item gets its
        own folder (item_id/...) so "replace" is just "empty the folder,
        then write one new object into it," regardless of whether the
        format changed between uploads (jpg -> png, etc.)."""
        client = self._ensure_client()
        bucket = client.storage.from_(ITEM_IMAGES_BUCKET)

        try:
            existing = bucket.list(item_id)
        except Exception as e:
            raise StorageError(f"Could not list existing image(s): {e}") from e
        if existing:
            stale_paths = [f"{item_id}/{f['name']}" for f in existing]
            try:
                bucket.remove(stale_paths)
            except Exception as e:
                raise StorageError(f"Could not remove the previous image: {e}") from e

        path = f"{item_id}/{uuid.uuid4()}.{ext}"
        try:
            bucket.upload(
                path, file_bytes, {"content-type": content_type}
            )
        except Exception as e:
            raise StorageError(f"Image upload failed: {e}") from e

        return bucket.get_public_url(path)
