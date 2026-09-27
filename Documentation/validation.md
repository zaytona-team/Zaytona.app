# Zaytona Validation, Authentication, and Authorization Tables 

## Main Difference

| Concept        | What It Means                                           | Example in Thalaja                                    |
| -------------- | --------------------------------------------------------- | ------------------------------------------------------- |
| Validation     | Checks if the data is correct, complete, and reasonable | Quantity must be greater than 0                        |
| Authentication | Checks who the user is                                  | User logs in with phone + OTP and receives a JWT token |
| Authorization  | Checks what the logged-in user is allowed to do         | Only group owner/admin can invite members              |

---

# 1. Authentication



## Signup / Registration

| Area / Feature | Validation or Check Needed | Why We Need It |
| --------------- | --------------------------- | ---------------- |
| Signup | First name is required, cannot be empty/only spaces, has a max length | To keep a complete, clean user profile |
| Signup | Last name is required, cannot be empty/only spaces, has a max length | To keep a complete, clean user profile |
| Signup | Phone number is required and must have a valid format | Phone number is the main identity for Thalaja |
| Signup | Phone number must be unique | Prevents two accounts sharing one identity |
| Signup | Email is optional; if provided, must be valid format and unique | Email is a fallback contact/recovery method only, not required |
| Signup | New users are always created with the default "user" role | Prevents self-assigned admin access |
| Signup | Role/admin status is never accepted from the frontend | Prevents privilege escalation via request body |
| Signup | Backend automatically creates the user's default personal group right after signup | Every user needs a personal space immediately |
| Signup | The new user is set as the owner of their default group | Default group must clearly belong to its creator |
| Signup | Signup does not require or accept a password field | Thalaja is OTP-only |

## Login (OTP)

| Area / Feature | Validation or Check Needed | Why We Need It |
| --------------- | --------------------------- | ---------------- |
| Login | Phone number is required and must have a valid format | Phone number is the login identity |
| Login | Backend looks up the user by phone number | Confirms the account exists |
| Login | OTP is sent to the phone number on login request | Core of the OTP flow |
| Login | OTP requests are rate-limited (e.g., cooldown between resends) | Prevents SMS abuse/spam |
| Login | OTP must match, be unvalidated, and not expired | Confirms the user owns the phone number |
| Login | OTP can be used only once | Prevents replay of the same code |
| Login | Failed OTP attempts return a general error message | Avoids leaking account details |
| Login | API never returns the OTP value in any response | Protects the authentication secret |
| Login | JWT token is issued only after successful OTP verification | Grants access only after identity is confirmed |
| Login | Whether email can be used as an alternative login identifier | **Open decision — confirm with user story** |

## JWT Authentication

| Area / Feature | Validation or Check Needed | Why We Need It |
| --------------- | --------------------------- | ---------------- |
| JWT | Every protected route requires a token | Private APIs must only serve logged-in users |
| JWT | Token must be present, valid, unexpired, and untampered | Prevents fake or reused sessions |
| JWT | Token payload includes user_id | Backend needs to know who is calling |
| JWT | Token payload may include role and plan_type | Lets backend check admin-only and plan-based limits without extra lookups |
| JWT | Backend always reads the current user from the token, never from the request body | Prevents identity spoofing |
| JWT | Missing/invalid/expired token → 401 | Clear, consistent signal that login is required |

## Current User Rule

| Area / Feature | Validation or Check Needed | Why We Need It |
| --------------- | --------------------------- | ---------------- |
| Current User Rule | Backend never trusts `user_id`, `owner_id`, `added_by`, `created_by`, `updated_by`, `role`, or timestamps from the request body | All of these can be faked by a malicious client |
| Current User Rule | `user_id` always comes from the JWT | Safely identifies the caller |
| Current User Rule | `owner_id`, `added_by`, `created_by` are always assigned by backend logic | Keeps ownership and activity records accurate |
| Current User Rule | `created_at` / `updated_at` always come from the database/backend clock | Keeps timestamps trustworthy |

## Logout

| Area / Feature | Validation or Check Needed | Why We Need It |
| --------------- | --------------------------- | ---------------- |
| Logout | Flutter removes the JWT from secure storage | Ends the local session |
| Logout | Flutter clears local cached user/session data | Prevents old account data leaking after logout |
| Logout | User must log in again (new OTP) to reach protected features | Protects private data after logout |
| Logout | Server-side token blacklisting | Optional — not required for a student project unless a story requires it |

---

# 2. Group Plan Validation

## Default Group

| Area / Feature | Validation or Check Needed | Why We Need It |
| --------------- | --------------------------- | ---------------- |
| Default Group | Created automatically right after signup | Every user gets a personal space immediately |
| Default Group | Belongs to exactly one user, who is the only member | It's a private, non-collaborative space |
| Default Group | Cannot invite or add members, under any request | Enforces the free/default plan boundary |
| Default Group | Can hold unlimited items | Matches the default plan design |
| Default Group | Limited to a maximum of 5 lists | Enforces the default plan list limit |
| Default Group | Exactly one default group per user | Prevents duplicate personal spaces |
| Default Group | Owner ID always comes from the backend/JWT, never the request body | Prevents fake ownership |

## Premium Groups

| Area / Feature | Validation or Check Needed | Why We Need It |
| --------------- | --------------------------- | ---------------- |
| Premium Groups | Only premium users can create shared groups | Separates free and premium features |
| Premium Groups | A premium user can own up to 5 shared groups | Enforces the group-count limit |
| Premium Groups | A premium user has a total balance of 20 members across all owned groups | Enforces the premium member limit |
| Premium Groups | The 20-member balance can be distributed across the 5 groups however the owner wants | Gives premium users flexibility |
| Premium Groups | Members belong to groups, not lists | Keeps the data model consistent |
| Premium Groups | Only the owner/admin of a group can invite or remove members | Protects group management |
| Premium Groups | The same user cannot be added twice to the same group | Prevents duplicate membership records |
| Premium Groups | The target group must exist before adding a member | Avoids operating on a deleted/fake group |
| Premium Groups | Members can only be invited via an invite code or invite link — no other invitation method | Matches your invite-code/link-only design |
| Premium Groups | Invite code/link must be valid and unexpired before it can be redeemed | Prevents stale or fake invites from being used |
| Premium Groups | Redeeming an invite code/link still enforces the 20-member balance and the "not already a member" check | Invite-based joins must follow the same limits as owner-added joins |

---

# 3. Authorization

| Area / Feature | Validation or Check Needed | Why We Need It |
| --------------- | --------------------------- | ---------------- |
| Authorization | Must be logged in (valid JWT) to reach any private API | Protects private data |
| Authorization | A user can only edit their own profile | Prevents editing other accounts |
| Authorization | Must be a group member to view that group's data, lists, or items | Protects shared-group privacy |
| Authorization | Only owner/admin can rename or delete a group | Prevents unauthorized group changes |
| Authorization | Only owner/admin can add or remove members | Controls who manages the group |
| Authorization | Must have access to a list before adding/editing/deleting its items | Prevents cross-account tampering |
| Authorization | Admin-only routes must explicitly check the role from the JWT | Protects restricted system features |
| Authorization | Every endpoint that takes `group_id`, `list_id`, or `item_id` must verify the caller has access to that resource | Prevents unauthorized access via ID guessing |

---

# 4. General Data Validation

## User Profile

| Area / Feature | Validation or Check Needed | Why We Need It |
| --------------- | --------------------------- | ---------------- |
| User Profile | First and last name cannot be empty | Keeps the profile valid |
| User Profile | New phone number, if changed, must be valid and unique | Keeps the main identity usable and conflict-free |
| User Profile | New email, if added/changed, must be valid and unique | Keeps fallback contact usable and conflict-free |
| User Profile | Profile image must be an allowed type and within a size limit | Prevents unsupported/oversized uploads |

## Groups

| Area / Feature | Validation or Check Needed | Why We Need It |
| --------------- | --------------------------- | ---------------- |
| Groups | Group name is required, non-empty, with a max length | Keeps every group clearly identifiable |
| Groups | Group must exist before update or delete | Avoids operating on deleted/fake groups |
| Groups | Group type must be one of the allowed values (default/shared) | Keeps default vs. shared groups distinct |

## Members

| Area / Feature | Validation or Check Needed | Why We Need It |
| --------------- | --------------------------- | ---------------- |
| Members | Added member must be an existing user | Avoids broken memberships |
| Members | Member cannot already be in the group | Prevents duplicate membership |
| Members | Member role must be one of the allowed values | Prevents invalid permissions |
| Members | Adding a member cannot push the owner's total past their 20-member balance | Enforces the premium member limit |
| Members | Default groups can never receive members | Enforces the default-group restriction |
| Members | If the sole owner/admin leaves, they must either assign another member as the new admin or delete the group | A group can never be left without an admin |
| Members | Assigning a new admin does not consume the new admin's own member/token balance | Ownership transfer is free for the person receiving it |
| Members | Deleting the group removes all its data (lists, items, history, etc.) | Deletion is a full cleanup, not a soft-delete |
| Members | Deleting the group still counts against the original owner's token/credit usage | The credit spent creating the group is not refunded on deletion |

## Lists

| Area / Feature | Validation or Check Needed | Why We Need It |
| --------------- | --------------------------- | ---------------- |
| Lists | List name is required, non-empty, with a max length | Keeps lists understandable |
| Lists | List belongs to a valid user or group (no orphan lists) | Keeps data integrity |
| Lists | `group_id` is nullable for private lists, and must reference a real group when set | Matches the private-vs-shared list design |
| Lists | List type must be one of the allowed values | Keeps list data consistent |
| Lists | Default group is capped at 5 lists | Enforces the default plan limit |
| Lists | Caller must belong to the target group before creating a list in it | Protects group data |

## Items

| Area / Feature | Validation or Check Needed | Why We Need It |
| --------------- | --------------------------- | ---------------- |
| Items | Item name is required, non-empty, with a max length | Keeps items meaningful and readable |
| Items | Quantity is required (or defaulted), numeric, greater than 0, and under a sane max | Prevents invalid or unrealistic amounts |
| Items | Unit must be one of the allowed values | Keeps item data consistent |
| Items | Category must reference a real category | Avoids fake categories |
| Items | List must exist and caller must have access to it | Protects private/group data |
| Items | Notes field has a max length | Avoids excessively long text |
| Items | `added_by` always comes from the JWT/backend | Prevents fake ownership |
| Items | Default group items are unlimited | Matches the default plan rule |

**Allowed units:** pcs, kg, g, L, ml, pack, box, bottle

## Categories

| Area / Feature | Validation or Check Needed | Why We Need It |
| --------------- | --------------------------- | ---------------- |
| Categories | Category is picked from a fixed system enum (no free-text categories) | Matches the fixed-category-enum design decision |
| Categories | Category name/enum value is required | Every item needs a clear category |
| Categories | Only admin can manage the system category list, if it's ever made editable | Protects system-wide categories |

## History / Activity Log

| Area / Feature | Validation or Check Needed | Why We Need It |
| --------------- | --------------------------- | ---------------- |
| History | `item_id` must reference a real item | Keeps history connected to real data |
| History | Action type must be one of the allowed values | Keeps history consistent |
| History | `user_id` and timestamp always come from JWT/backend | Prevents fake activity records |
| History | Caller must have access to the item before viewing its history | Protects private activity |

**Allowed actions:** created, updated, deleted, consumed, restocked

## Notifications / Reminders

| Area / Feature | Validation or Check Needed | Why We Need It |
| --------------- | --------------------------- | ---------------- |
| Notifications | `item_id` must reference a real item | Connects reminder to real data |
| Notifications | Reminder date must be a valid date | Ensures the reminder can be scheduled correctly |
| Notifications | Notification type must be one of the allowed values | Keeps behavior consistent |
| Notifications | Caller must have access to the related item | Prevents private reminders leaking |

## Search and Filters

| Area / Feature | Validation or Check Needed | Why We Need It |
| --------------- | --------------------------- | ---------------- |
| Search/Filters | Keyword has a max length and is sanitized | Avoids unsafe or oversized queries |
| Search/Filters | Category/expiry filters reference allowed values | Avoids fake filters |
| Search/Filters | Sort field is from an allowed list; sort order is only `asc`/`desc` | Prevents invalid queries |
| Search/Filters | Page number and limit are positive integers; limit has a max | Keeps pagination safe and performant |

## Files / Images

| Area / Feature | Validation or Check Needed | Why We Need It |
| --------------- | --------------------------- | ---------------- |
| Files/Images | File type restricted to JPG/PNG/WebP | Prevents unsupported uploads |
| Files/Images | File size is limited | Protects storage and performance |
| Files/Images | File name is sanitized; storage path is backend-controlled | Prevents unsafe paths or overwrites |
| Files/Images | Caller must have permission over the profile/item/group the file is attached to | Prevents unauthorized uploads |

---

# 5. Database Constraints

| Area / Feature | Database Constraint Needed | Why We Need It |
| --------------- | ---------------------------- | ---------------- |
| Database | `NOT NULL` on first name, last name, phone number | Prevents incomplete required user records |
| Database | `UNIQUE` on phone number | Keeps phone number as the sole unique identity |
| Database | `UNIQUE` on email (nullable) | Avoids duplicate fallback emails without forcing email to exist |
| Database | `UNIQUE` on (`group_id`, `user_id`) in `group_members` | Prevents duplicate memberships |
| Database | `CHECK` quantity > 0 | Enforces valid item quantity |
| Database | `CHECK` plan type in (default, premium) | Prevents invalid plan values |
| Database | `CHECK` group type in (default, shared) | Separates personal and shared groups |
| Database | `CHECK` list type in allowed values | Keeps list types consistent |
| Database | `CHECK` member role in allowed values | Prevents invalid roles |
| Database | Foreign key `groups.owner_id → users.id` | Every group has a real owner |
| Database | Foreign key `group_members.group_id → groups.id` and `group_members.user_id → users.id` | Keeps memberships valid |
| Database | Foreign key `lists.group_id → groups.id` (nullable) | Connects shared lists to real groups |
| Database | Foreign key `items.list_id → lists.id` | Keeps items connected to real lists |
| Database | Foreign key `items.category_id → categories.id` | Keeps categories valid |
| Database | Foreign key `history.item_id → items.id` and `notifications.item_id → items.id` | Keeps logs/reminders connected to real items |
| Database | Cascade or restrict rules defined for deletes on groups/lists/items | Avoids orphan records |

---

# 6. API Error Handling

| Error Type | When to Use It | Example |
| ----------- | ---------------- | --------- |
| 400 Bad Request | Invalid input or failed validation | Quantity must be greater than 0 |
| 401 Unauthorized | Missing, invalid, or expired token; invalid/expired OTP | Login is required |
| 403 Forbidden | Logged in but not permitted to do this action | Only group admin can add members |
| 404 Not Found | Requested resource doesn't exist | Group not found |
| 409 Conflict | Duplicate/conflicting data | Phone number already exists, already a group member, category already exists |
| 500 Internal Server Error | Unexpected server error only | Something went wrong on the server |

---

