# Backend / API needs

Running log of any STAGE3-documented endpoint that is missing, ambiguous, or that the live Render API doesn't actually match once the frontend hits it. Each entry: what the frontend expected, what's blocked, what was assumed instead. This file is the handoff artifact for backend work deferred to later — not shipped code.

---

## Open

- **Duplicate-name detection ignores brand** — the "possible duplicate" hint (US-25) is computed purely on the client by comparing the typed name against the names of items already on the list — brand is not part of that comparison. So typing "Laban" while a "Laban / Nadec" item is already on the list warns even if the user meant "Laban / Almarai," a genuinely different product. This is intentional for manual typing (a name-only guess deserves a name-only warning) and unrelated to catalog quick-add, which now merges client-side on an exact name+brand match instead of relying on this warning at all (see `CatalogCubit.quickAdd` / `_findMergeTarget`). Flagging in case a future backend-side duplicate check is added — it should not inherit this name-only looseness, or it will produce false positives across different brands of the same product name.
- **`categories` has no `slug` column** — `CategoryRegistry` (`mobile/lib/features/items/data/category_registry.dart`) bridges the design system's fixed `CategoryId` enum to backend category UUIDs via a hardcoded `Map<CategoryId, String>` of English display names (`CategoryId.dairy: 'Dairy & Eggs'`), then matches those names against `GET /categories` to get UUIDs. If the `categories` table had a `slug` column (e.g. `"dairy"`, matching `CategoryId.name`) alongside the existing UUID and display name, the app could build a single flat slug→uuid map straight from the API response and drop the hardcoded name table entirely — one less thing to keep in sync by hand when a category is renamed or added.
- **No "get my default group" endpoint** — `HomeRedirect` (`mobile/lib/features/groups/presentation/pages/home_redirect.dart`) always calls `GET /groups` then picks the caller's private group client-side (`groups.firstWhere((g) => g.isPrivate, ...)`) before navigating to `/groups/{groupId}`. A dedicated endpoint returning just that group would let the app skip fetching the full groups list to land on the home screen, cutting one round trip off the slowest part of cold start.
- **`POST /lists` (create) doesn't accept `color`** — only `PATCH /lists/{listId}` (edit) does (see Resolved → Lists & items → "List accent/colour"). `CreateListSheet` now shows the same `ZaytonaColorPicker` as the edit flow so a user isn't limited to fewer colors at creation than at edit time, but the selection can't be sent yet — `CreateListCubit.submit` has no `color` param and the create endpoint doesn't document one. Once `POST /lists` accepts `color` (same 5-value `ZaytonaListAccent` enum as the PATCH route), wire it through `CreateListParams` / `CreateListCubit.submit`.

---

## Resolved

Everything below was either already correct (just undocumented) or fixed in commit `d41c62c` (2026-08-10), except the final subsection which was fixed in this round (2026-08-12).

### Auth

- **Dev/App-Review OTP bypass** — whitelisted number `+966555455544` (configurable via `DEV_OTP_WHITELIST_PHONES` env var) skips Authentica entirely on `/auth/register`, `/auth/login`, `/auth/otp/resend`; `/auth/otp/verify` accepts the fixed code `4444` for it without calling Authentica. Enabled in every environment, including production, since TestFlight/App Store builds hit the same production backend Apple's reviewer needs to log into. No behavior change for any other number.
- **Session tokens now expire** — `POST /auth/otp/verify` returns both `access_token` (15 min) and `refresh_token` (7 days). New `POST /auth/refresh` — body `{"refresh_token": "..."}` → `{"access_token": "...", "token_type": "Bearer"}`. A `refresh_token` cannot be used as an `Authorization` bearer token (401 if you try) — only `access_token`s work there.

### Lists & items

- **`DELETE /lists/{listId}`** — now implemented, admin-only (same rule as `PATCH /lists/{listId}`). 204 on success, 403 if not admin, 404 if the list doesn't exist.
- **`GET /lists/{listId}` doesn't embed items** — intentional, not a bug. Use the existing `GET /lists/{listId}/items` (was already live, just undocumented in STAGE3).
- **Bought items lingered on `GET /lists/{listId}/items` after trip completion** — fixed: that endpoint now excludes items already claimed by a trip. They stop showing on the active list and only appear via `GET /groups/{group_id}/trips` (history).
- **`brand` on `POST /lists/{listId}/items`** — now accepted and persisted, onto both `ITEM.brand` (catalog, via existing match-or-create-by-name-and-brand) and `LIST_ITEM.brand`. Previously silently dropped at the API layer.
- **`LIST_ITEM.item_id` for a typed (non-catalog) name** — already match-or-creates an `ITEM` row by name+brand; `item_id` stays non-null. No change needed.
- **Personal catalog `GET /users/me/items`** — response shape already matches `{name, category_id, brand, image_url, last_used_at}` exactly. No change needed.
- **Custom item table** — confirmed as an explicit "won't build," not an oversight; manual name entry already covers it.
- **Catalog browse/search (US-18)** — confirmed dropped from MVP scope, replaced by the personal catalog above.

### Notifications

- **Dedicated notification endpoints** — implemented, body `{"user_id": "<member user id>"}` for the two that target a specific member:
  - `POST /lists/{listId}/notifications/assign-buyer` — assigns the buyer and pushes a notification to them. 409 if the list already has an active trip.
  - `POST /lists/{listId}/notifications/remind-member` — pushes a reminder to the named member. No trip required.
  - `POST /lists/{listId}/notifications/remind-me` — pushes a reminder to the caller's own devices. No body.
  All three return `{"message": "Notification sent successfully"}` on 2xx — treat any 2xx as success, same convention as the existing heading-to-store endpoint.

### Trips

- **No documented response body in swagger** for `POST /lists/{list_id}/trip`, `GET /lists/{list_id}/trips/active`, `PATCH /trips/{trip_id}/complete` (plus `cancel`/`heading-out`/`ask`) — swagger only showed a status code, no schema, so the frontend was relying on shapes it inferred by testing. Fixed: all six routes now document their actual response body (`Trip`, `TripCompleteResponse` = `{trip, list}`, `NotifiedDevicesResponse`, `AskTripGroupResponse`) in `/api/v1/swagger.json` / `/api/v1/docs`. No behavior change — same fields as what the frontend already parses (`trip_id`, `buyer_id`, `status`, etc.), just now documented instead of inferred. `GET .../trips/active` can still return `null` when there's no active trip.

### Recipes

- **No way to save a customized/forked copy of a recipe** — `POST /recipes/groups/{group_id}/recipes` now accepts an optional `source_recipe_id`. Flow: a recipe-book recipe is *forked*, not mutated — "add to a group" POSTs a new recipe to that group with the (possibly edited) `name`/`instructions`/`image_url`/`ingredients` plus `source_recipe_id` set to the original's `recipe_id`. The backend creates an independent `Recipe` row; editing the group's copy (`PATCH /recipes/{recipe_id}`) never touches the original. `GET`/`PATCH /recipes/{recipe_id}` responses now include `source_recipe_id` (`null` for a non-forked recipe). Importing ingredients into a list is unchanged: `POST /recipes/lists/{list_id}/items/from-recipe/{recipe_id}`.
- **Recipe ingredients weren't reaching the shared item catalog** — a typed ingredient with no `item_id` used to create a `RecipeIngredient` with `item_id: null`, which then produced a `ListItem` with `item_id: null` when imported into a list. Fixed: `POST /recipes/groups/{group_id}/recipes` now resolves each ingredient against the shared catalog the same way `POST /lists/{listId}/items` already does (match-or-create by name+brand), so `item_id` is always populated — this is the seed data for the shared/company-wide catalog planned for later. No request/response shape change, just `item_id` no longer being null.

### History

- **`buyer_id` on `GET /groups/{group_id}/trips`** — already present on every trip object; no change needed. Also confirmed: `buyer_id` can never be reassigned on an already-started trip (`assign_trip_buyer` 409s if one's already active), so the mismatch reported earlier wasn't a reassignment bug.

### Groups

- **Picked avatar never showed in the group card's member row** — real gap: `GroupMember.to_dict()` never read `avatar_url` off the linked user, even though `User.avatar_url` was already saved correctly. Fixed — each member object in `GET /groups/{group_id}/members`, and each entry in the `members` array in `GET /groups/{group_id}`, now includes `"avatar_url"` (`null` if that member never picked one).

### Auth (2026-08-12)

- **`POST /auth/otp/resend` now takes an optional `channel` param** — `"whatsapp" | "sms" | "email"`. When given, the OTP is sent via exactly that channel, no fallback (a deliberate user pick shouldn't silently degrade to a channel they didn't choose). Omit it and behavior is unchanged — the existing whatsapp→sms→email automatic fallback chain. Register/login OTP dispatch untouched, still always use the automatic chain.

### Lists & items (2026-08-12)

- **Bulk-delete-all-items already existed** (`DELETE /lists/{listId}/items`, US-23) — it just wasn't documented as resolved. It's a single atomic call, membership-checked. What *was* a real gap: it wrote one `HISTORY` row per deleted item instead of one for the whole action. Fixed — now writes a single row, `action: "deleted"`, `metadata: {"items": [{name, quantity, unit}, ...], "count": N}`. Client-side Undo can now key off one entry per bulk-delete instead of reconstructing the batch from N rows.
- **List accent/colour** — `ShoppingList` now has a `color` column (nullable `varchar(20)`), returned in every list payload. `PATCH /lists/{listId}` accepts `color`, admin-only same as `name`, one of `"red" | "indigo" | "mint" | "navy" | "lilac"` (5 values — `zaytona_design_system`'s `ZaytonaListAccent` enum, not the 4 originally guessed). `EditListSheet`'s colour picker can be wired up for real now instead of the client-only `listId.hashCode` derivation.

### Trips (2026-08-12)

- **List-scoped trip history** — new `GET /lists/{list_id}/trips`, returns every completed trip for that one list, newest first, same shape as the old group-scoped endpoint. **The old `GET /groups/{group_id}/trips` has been removed** — `HistoryCubit.load()` needs to switch to the list-scoped route.
- **Trip items are now full objects, not bare strings** — each entry in a trip's `items` array is now `{item_id, name, quantity, unit, category_id}` instead of just a name string, on both the (now-removed) group endpoint's replacement and the new list-scoped one. Enough to prefill a "re-add this trip's items to the current list" action.
- **Cascade-delete of trips on list delete** — already implemented before this round (`group_repository.py` deletes `Trip` rows before `History`/`ListItem`/the list itself in `delete_list`), just hadn't been documented as resolved. No orphaned trips left behind by `DELETE /lists/{listId}`.
- **Trips namespace mount-path bug, fixed** — `app/__init__.py` was passing `path=""` to `api.add_namespace(trips_ns, ...)`, which flask-restx silently falls back on to `/` + the namespace name, so every trip route lived under `/api/v1/trips/...` instead of the intended `/api/v1/...`. Fixed by mounting with `path="/"` instead. All trip routes are now genuinely at their documented paths: `POST /api/v1/lists/{list_id}/trip`, `GET /api/v1/lists/{list_id}/trips/active`, `GET /api/v1/lists/{list_id}/trips`, `PATCH /api/v1/trips/{trip_id}/complete`, `PATCH /api/v1/trips/{trip_id}/cancel`, `POST /api/v1/trips/{trip_id}/heading-out`, `POST /api/v1/trips/{trip_id}/ask`. **This is a breaking URL change for any client already calling the old double-prefixed `/api/v1/trips/lists/...` / `/api/v1/trips/trips/...` paths** — update the mobile app's base paths for trip endpoints accordingly.

## Changelog — 2026-08-12 batch

Plain-English, one line per edit, file + lines (paths relative to `zaytona/zaytona_api/` unless noted):

- `app/api/v1/auth.py` (56-63, 162-164) — `otp_resend_model` gets an optional `channel` field; the resend route passes it through.
- `app/services/facade/auth.py` (158-171) — `resend_otp` validates and forwards `channel`.
- `app/services/providers/authentica_provider.py` (94-115) — `send_otp` sends via the requested channel only, with no fallback, when `channel` is given; unchanged automatic fallback chain otherwise.
- `app/services/facade/items.py` (317-322) — `bulk_delete_list_items` writes one combined `HISTORY` row (`metadata: {items, count}`) instead of one per item.
- `zaytona/supabase/schema.sql` (76-87) — `shopping_lists.color varchar(20)` added (also applied directly to the live Supabase project — no migration tool in this repo).
- `app/models/shopping_list.py` (31-44, 55) — `color` column, `ALLOWED_COLORS` (`red, indigo, mint, navy, lilac`), `@validates("color")`, and `to_dict()` now includes it.
- `app/services/facade/lists.py` (7-8, 100-124) — `update_list` accepts and validates `color`.
- `app/api/v1/lists.py` (16-24, 49-59) — `UpdateListRequest` swagger model + route pass `color` through.
- `app/persistence/repositories/trip_repository.py` (9-11, 41-50) — `list_completed_for_group` replaced with `list_completed_for_list` (filters by `list_id` directly, no join); unused `ShoppingList` import removed.
- `app/services/facade/trips.py` (179-233) — `list_group_trips` replaced with `list_list_trips` (list-scoped, membership-checked via the list's `group_id`); serialization factored into a shared `_serialize_trip_history` helper used by both old and new call sites; `items` now serializes to `{item_id, name, quantity, unit, category_id}` per item instead of bare names.
- `app/api/v1/trips.py` (48-77, 108-121, module docstring) — new `GET /lists/<list_id>/trips` route + `TripHistoryEntry`/`TripHistoryItem` swagger models.
- `app/__init__.py` (87) — fixed the `trips_ns` mount path from `path=""` to `path="/"`, so trip routes are mounted at their intended `/api/v1/...` paths instead of falling back to `/api/v1/trips/...`.
- `app/api/v1/trips.py` (module docstring) — updated to document the corrected paths, dropping the `path=""` workaround explanation.
- `tests/test_lists.py` (404, 427, 446, 469) — trip-history request URLs updated from `/api/v1/trips/lists/{list_id}/trips` to `/api/v1/lists/{list_id}/trips`.
- `app/api/v1/groups.py` (320-336 removed) — old `GET /<group_id>/trips` route deleted.
- `app/models/list_item.py` (49), `app/persistence/repositories/item_repository.py` (105) — stale comments renamed `list_group_trips` → `list_list_trips`.
- `tests/test_lists.py`, `tests/test_histories.py` — updated to call the new list-scoped trips route and assert the consolidated bulk-delete history entry.
