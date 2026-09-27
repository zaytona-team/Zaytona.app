# Backend Issues — `backend`

Every problem found and fixed on this branch, in the order they surfaced while wiring the frontend to this API.

1. **`email` was wrongly required on `/auth/register`.** The `users.email` column is `nullable=True` in the model, and the frontend's own copy says "Email is optional and can be used as a fallback method" — but `register_model` in `auth.py` had `fields.String(required=True)`. Any signup without an email was rejected at the validation layer before it even reached the facade. Fixed to `required=False`.

2. **Duplicate-email check false-positives once email became optional.** `register_user()` called `self.users.get_by_email(email)` unconditionally. With `email=None`, that runs `WHERE email IS NULL`, which matches *any* existing user who also skipped email — so the second person to sign up without an email would incorrectly get "Email already registered" (409). Fixed to only run the check when an email was actually provided.

3. **`/auth/login` didn't return the account's phone number.** `/otp/verify` only ever matches by `phone` (required field), but a user who logs in with an *email* identifier has no phone number on the client to send back for verification. There was no way to complete login for anyone who typed their email. Fixed `login()` to return the resolved `phone` in its response so the client always has it, regardless of which identifier the user typed.

4. **Explicit `null` for optional fields fails flask-restx validation.** Not a bug in this repo's code per se, but a sharp edge worth documenting here since it broke the *entire* OTP verify flow from the client side: a `fields.String(required=False)` field still gets JSON-Schema type-checked when present, and `null` is not a valid `"string"` per that schema — flask-restx returns 400 `"None is not of type 'string'"`. Confirmed directly: `{"phone": "...", "token": "...", "email": null}` → 400, `{"phone": "...", "token": "..."}` (key omitted) → passes validation. The fix lives on the frontend (never send the key at all when the value is absent), but worth knowing if any other optional field ever gets the same treatment.

5. **JWTs never expired... an intentional change, not a bug.** Per explicit product decision, `_issue_token()` no longer sets an `exp` claim — sessions are now permanent. Flagging directly: there is no revocation/blocklist mechanism anywhere in this codebase, so a leaked token is valid forever. `JWT_EXPIRES_SECONDS` is still in `config.py` but is now dead config if nothing reads it.

6. **No `icon` field existed for groups**, even though `update_group`'s own docstring said "admin edits group name / icon" (US-09) and the Flutter app's `create_Group.dart` already had a full 8-icon picker UI with no field to persist the selection to. Added `icon` (nullable `varchar(32)`, validated against a fixed `ICON_CHOICES` tuple mirroring the Flutter `GroupIcon` enum) to the model, `create_group`/`update_group` facade methods, the repository, and the `groups.py` swagger models. Also **manually ran `ALTER TABLE public.groups ADD COLUMN icon varchar(32);`** against the live Supabase DB, since `db.create_all()` only creates missing tables — it does not add columns to tables that already exist. `schema.sql` (the read-only reference copy) updated to match.

## Confirmed working, not touched

Verified directly against the live API + DB during this pass, no issues found:
- `/auth/register`, `/auth/login`, `/auth/otp/verify`, `/auth/otp/resend`, `/auth/me` — full round trip, including error cases (409 duplicate, 404 not found, 401 unauthorized)
- `/groups/` (POST/GET), `/groups/{id}` (GET), `/groups/join` — including validation errors, already-a-member (409), invalid invite code (404)
- Authentica OTP provider integration (send + verify, channel fallback)

## Known gap — resolved by later work

- ~~`/lists`, `/items`, `/categories`, `/histories`, `/recipes` are bare placeholder namespaces~~ — **stale.** All five are fully implemented as of the full-stack review below. `GET /groups/` also now returns `member_count`.

---

# Full-stack review — 2026-07-25

Whole-codebase pass across `backend` (Flask API) and `test-merge` (Flutter app), cross-checked against the Stage 3 technical documentation's user stories and internal API table. Grouped by where the fix lands. Items marked **[FIXED]** were corrected in this pass; items marked **[GAP — not fixed]** are feature-level work (new endpoints, new dependencies, or infra decisions) intentionally left for a separate, scoped pass rather than built blind in the same sweep as bug fixes.

## A. Wiring bugs — frontend and backend individually looked fine, but disagreed with each other

7. **[FIXED] List items never loaded.** `GET /lists/{id}` (`shopping_list.py::to_dict()`) never included an `items` key, but `ItemRepositoryImpl.getListItems` (Flutter) called that exact endpoint and read `data['items']` — always `null`, so every list-detail/buying-view load failed with "unexpected server response." The backend already has a working `GET /lists/{id}/items` endpoint; the frontend was calling the wrong one. Fixed on the frontend to call the dedicated items endpoint.

8. **[FIXED] `PATCH /lists/{id}/complete` (US-15, Must Have) 405'd on every call.** The Flutter client calls `_dio.patch('/lists/$listId/complete')`; the Flask route only ever registered `def post(self, list_id)` for that path. Closing a list — a Must-Have story — was completely broken end to end. Fixed the backend to accept `PATCH` (matches the Stage 3 API table's original verb and the frontend's existing call, so no Flutter change needed).

9. **[FIXED] Every "Trip Alert" notification action 404'd.** The frontend calls `POST /lists/{id}/notifications/{heading-to-store,assign-buyer,remind-member,remind-me}` — the URL scheme from the planning doc. The backend never built a `/notifications` namespace; the same three features (assign buyer, heading-out broadcast, private remind) were built instead under `/lists/{id}/trip`, `/trips/{id}/heading-out`, `/trips/{id}/ask`, with buyer-lock semantics the doc's flatter scheme didn't have. Neither side is "wrong" in isolation — nobody reconciled them. Fixed by pointing the Flutter notification datasource at the real trip-based routes, and adding the one missing piece needed to do that: `GET /lists/{id}/trips/active` (the frontend has no way to learn a trip's ID otherwise). `remind-me` (US-43, Could Have, a scheduled personal reminder) has no backend equivalent at all — left as a documented gap below rather than wired to a fake endpoint.

## B. Backend bugs (`backend` branch)

10. **[FIXED] `DELETE /groups/{id}/lists/{list_id}` (US-11) 500'd on any list that ever had an item added.** `GroupRepository.delete_list` deleted the `shopping_lists` row directly with no cascade; `list_items`, `list_actions`, and `trips` all FK to `list_id` with no `ON DELETE` behavior, and `add_list_item` always writes a history row — so essentially every real list had a dependent row by the time an admin tried to remove it, and Postgres raised `ForeignKeyViolation` → unhandled 500. Fixed by deleting child rows (trips, history, items) before the list, in one transaction — matching the pattern `RecipeRepository.delete` already used correctly for recipes.

11. **[FIXED] No `IntegrityError` handling anywhere (grep-confirmed zero occurrences).** Two concurrent `POST /auth/register` with the same phone, or two concurrent `POST /groups/join` for the same user+group, both passed their pre-checks and then hit a unique-constraint violation on the INSERT — unhandled 500 instead of a clean 409. Fixed by catching `IntegrityError`, rolling back, and translating to `FacadeError(..., 409)` in both paths.

12. **[FIXED] `item_id` / `category_id` accepted on item add/update with no validation.** A malformed or non-existent ID from the client tripped the FK constraint at commit time → unhandled 500 instead of a 400/404. Fixed by validating UUID shape and existence before insert/update.

13. **[FIXED] IDOR: `DELETE /devices/{fcm_token}` had no ownership check.** `jwt_required` guarded the route, but the caller's identity was never used — any authenticated user who obtained someone else's FCM token could silently unregister that person's push notifications. Fixed by scoping the delete to `(user_id, fcm_token)`.

14. **[FIXED] Recipe import (US-34) never wrote to the action log.** `import_recipe_to_list` created `ListItem` rows in a loop but, unlike every other item-mutation path, never called `history.create(...)` — items imported from a recipe were invisible to `GET /lists/{id}/history`, breaking US-28 for that one path. Fixed to log one history entry per imported item.

15. **[FIXED] Stale comment + dead code in `login()`.** Docstring claimed "OTP verification is disabled to save Authentica credits during testing" above a commented-out direct-login block, while the live code below actually sends and requires an OTP. Removed the dead block and corrected the docstring so it doesn't mislead the next person touching auth.

16. **[FIXED] 5-list cap (US-13) was bypassable.** The cap applies to `type == "individual"` groups, but `POST /groups` let any client pass `type: "individual"` freely, so a user could create unlimited fresh personal groups, each with its own 5-list allowance. `"individual"` is meant to be an internal designation for the one auto-provisioned personal group created at registration. Fixed by having the public `create_group` facade method always force `type="household"`, regardless of what the client sends — the auto-provisioning path in `register_user` is untouched (it calls the repository directly, not this method).

17. **[FIXED] CORS was wide open (`origins: "*"`) unconditionally.** Lower risk since auth is bearer-token (not cookie-based), but still worth not hardcoding. Fixed to read from a `CORS_ORIGINS` env var (comma-separated), defaulting to `*` only when unset, so a real origin list can be set in production without a code change.

18. **[FIXED] `DELETE /groups/{id}/recipes/{recipe_id}` (US-12) didn't exist**, despite the module's own docstring advertising it and `GroupRepository.get_recipe`/`delete_recipe` existing specifically for it. The facade method and route were simply never written. Added `remove_group_recipe` to the facade (mirrors `remove_group_list`) and registered the route.

19. **[FIXED] `register_user` and `transfer_group_admin` weren't transactional.** Each did 2-3 independently-committed writes; a failure partway through left orphaned/inconsistent rows (e.g. a group with no members, or a group with zero admins that nothing in the API can recover, since every admin action requires an existing admin). Fixed by deferring the commit until all writes in the sequence succeed, rolling back the whole sequence on any failure.

20. **[FIXED] US-38 (lock list into trip; auto-return unbought items) wasn't implemented**, despite the `Trip` model's own docstring promising it ("so two members can't 'check off' the same list at once"). `complete_trip` only flipped `Trip.status`; nothing locked concurrent purchases and nothing rolled unbought items into a new active list. Fixed: `mark_item_purchased` now rejects any non-buyer while the list has an active trip; completing a trip (or completing a list directly, US-15) now closes the list and moves any unbought items onto a freshly created active list in the same group, so the next shopping run starts with exactly what wasn't bought — bought items stay on the closed list for trip history (US-29).

## C. Frontend bugs (`test-merge` branch)

21. **[FIXED] US-02 "login with email or phone" only supported phone.** `LoginValidator.validateEmailOrPhone` existed but was dead code (grep-confirmed, never called); the login screen had one phone-only field. A user who only has an email on file had no way to sign in. Added an identifier-type toggle and wired the existing validator in.

22. **[FIXED] Join Group succeeded server-side but never navigated in and gave no feedback.** `JoinGroupSuccess` carries the full joined `Group`, but the page's listener only did `Navigator.pop(true)` — contrast with Create Group, which correctly does `context.go('/groups/${state.group.groupId}')`. Fixed Join Group to do the same.

23. **[FIXED] US-25 duplicate-item warning was wired but unreachable.** The only real "add a new item" path (`CatalogPage → _openManualForm → AddItemSheet`) never passed `existingNames`, so the non-blocking duplicate banner never had data to work with in the one flow real users hit. Fixed by passing the current list's item names through on that path.

24. **[FIXED] OTP resend/verify race could crash with `StateError: emit after close`.** The resend button was only disabled by the countdown timer, not by an in-flight verify. If verify succeeded and navigated away while a resend call was still in flight, the resend's later `emit()` landed on an already-closed cubit. Fixed by also disabling resend while a verify is in progress.

25. **[FIXED] Sensitive request/response logging was unconditional, including in release builds.** `Dio`'s `LogInterceptor(requestHeader: true, requestBody: true, ...)` — logging the `Authorization: Bearer <jwt>` header, phone numbers, and OTP codes — was registered with no `kDebugMode` gate. Fixed to only attach in debug builds.

26. **[FIXED] No current-user identity stored anywhere on the client**, root-causing a wrong "you" badge in Group Settings for non-admin viewers (`isSelf` only worked when the viewer was themselves the admin) and blocking any future "is this mine?" check (e.g. US-37 recipe-owner permissions). `verifyOtp`'s response already includes `user.user_id`; the client discarded it. Fixed by persisting it alongside the token and using it for the "you" comparison.

27. **[FIXED] Onboarding after registration was fully built but unreachable.** OTP verify routed straight to `/groups` regardless of `purpose`, so the avatar-picker screen was dead code. Since the backend already auto-creates a personal group at registration, routing through the old "first group" screen too would create a redundant duplicate group — so only the avatar step is wired in for new registrations; login still goes straight to `/groups`.

## D. Gaps — real, but out of scope for a bug-fix pass (need their own design/build)

These are Must-Have stories with no working flow on either side. Fixing them means building a feature, not fixing a defect, so they were **not** attempted in this pass:

- **US-24 — Real-time sync.** No websocket/SSE/Supabase Realtime wiring anywhere in the backend; the Supabase keys in `config.py` are declared but never used. Needs an explicit choice of transport (Supabase Realtime vs. a custom websocket channel vs. polling) before writing any code.
- **US-17 — Item history / re-add.** The `Item` catalog table exists with no repository, facade methods, or routes. Needs a real design for how the catalog gets populated (seeded data? grows from user submissions?) before building the API.
- **US-37 — Recipes (frontend).** No recipe entity, screen, or endpoint call exists on the client at all — just a placeholder tab. The backend side (`recipes.py`) is fully built; only the Flutter feature needs building.
- **US-30 — Push notification receiving.** `pubspec.yaml` has no `firebase_messaging`/`firebase_core`; device registration is implemented through the repository layer but never called from any screen. Needs Firebase project config on both iOS and Android before it can be wired in and tested.
- **US-43 — Remind me to go shopping.** No backend endpoint exists for a user-triggered personal reminder (the existing Celery sweep in `app/tasks/reminders.py` is a generic "list idle 12h" nudge to the whole group, not this). Lowest priority (Could Have) of everything in this list.

Also not fixed, noted for awareness:
- Group leave/delete are UI-complete but permanently stubbed to fail (`ServerFailure`) — no backend endpoint exists for either. Fails gracefully today rather than lying about success, so left as-is pending a real backend decision on whether groups can be left/deleted at all.
- `InviteToGroupPage.joinedMembers` is always empty (no "who just joined" data source exists) — the underlying share-code UX still works.
- Broad pattern of unchecked `as String` casts in `fromJson` parsers across several entities — would throw an uncaught `TypeError` on a malformed/partial API response rather than degrading to a friendly error. Worth a dedicated hardening pass, not fixed piecemeal here.
