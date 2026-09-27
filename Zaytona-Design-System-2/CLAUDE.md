# Zaytona — porting the live app onto this design system

This project is the **Zaytona design system + reference prototype**. Use it as the source of truth when
restyling or rebuilding the functional app. Work **feature by feature**, not screen-by-pixel: for each
feature below, read the reference implementation, lift the tokens/components, keep your own data layer.

## What is in here

| Path | What it is |
| --- | --- |
| `styles.css` | The only entry point consumers link. Imports everything in `tokens/`. |
| `tokens/` | `colors`, `typography`, `fonts`, `spacing`, `radii`, `shadows`, `base`. All values are CSS variables. |
| `components/core` | `Button`, `IconButton`, `Badge`, `Avatar`, `AvatarGroup`, `Card` |
| `components/forms` | `Input`, `Checkbox`, `QtyStepper`, `SegmentedControl` |
| `components/patterns` | `Star` (14-point seal, alias `Blob`), `CategoryStar`/`CatBadge`, `CategoryChip`, `GroceryItem`, `ListSummaryCard` (list card), `CatalogItemCard` (catalog product card), `TripCard` (trip history card), `AlertWidget` (trip-alert row), `EmptyState`, `ErrorState`, `BuyingHeader`, `FamilyCard` (group card), `Sidebar` (nav drawer), `Banner`, `FAB`, `Sheet`, `Dialog`, `Toast` |
| `ui_kits/zaytona-app/` | The interactive reference prototype — every screen and interaction described below |
| `guidelines/*.card.html` | Foundation specimens (colour, type, spacing, brand) |
| `assets/` | Logo mark, logo lockup, app icon, heart mark, team characters, brand fonts |
| `readme.md` | Brand voice, visual foundations, iconography, motion |

Prototype file map (`ui_kits/zaytona-app/`):

- `index.html` — shell, keyframes, script order
- `app.jsx` — routing stack, app state, `RootNav`, `TabBar`, FAB, drawer, `Account`, `AboutSheet`, `TipsCoach`
- `screens-auth.jsx` — `Splash`, `Welcome`, `Register`, `Login`, `Otp`, `FirstGroup`, `ChooseAvatar`
- `screens-main.jsx` — `GroupDetail`, `ListCard`, `RecipeCard`, `ListDetail`, list menu + `EditListSheet`, item rows
- `screens-flows.jsx` — `AddItemSheet` (catalog screen + create popup), `ManualForm`, `CatalogPicker`, `CreateListSheet`, `BuyingView`, `GroupsOverview`, group create/join, invite
- `screens-more.jsx` — `History` (activity + trips), `Notifications` (trip alerts), `RecipeDetail`, `RecipeForm`, `AdminSettings`
- `screens-recipes.jsx` — `RecipeBook`
- `icons.jsx` — Lucide-style line icon set · `art.jsx` — category seals · `i18n.jsx` — AR/EN strings, categories, seed data

## Non-negotiable rules

1. **Light mode only. No gradients** as decoration (the only allowed gradient is the cream fade behind a sticky bottom CTA).
2. **Never pure white.** Paper is `--cream`; cards are `--surface-card` (pink), insets `--surface-sunken`.
3. **Navy outline + hard pop shadow** is the signature: emphasis cards and solid buttons take `2.5px solid var(--navy)` + `var(--shadow-pop)`, and press *into* the shadow.
4. **RTL-first.** Arabic is primary. Use `inset-inline-*`, `margin-inline-*`, `text-align: start/end`. Only pin things physically (`left`/`right` + `dir="ltr"` on the row) when the control must stay put in both directions — the app header does this.
5. **Two fonts only:** `--font-display` (MADE Tommy Soft) for titles/numbers, `--font-body` (Vazirmatn) for everything else and all Arabic.
6. **Line-height ≥ 1.3 on Arabic display text** or descenders clip.
7. Use `Star`/`CategoryStar` for decorative and category art. Do not draw new illustrative SVGs.

## Feature-by-feature migration

Order is the recommended sequence — each step is shippable on its own.

### 1. Foundations (do this first)
Link `styles.css`, load the fonts, replace every hard-coded colour/radius/shadow in your app with the
tokens. Nothing else in this list works properly until the token layer is in.
**Check:** no hex values left in your app CSS except inside `tokens/`.

### 2. Core controls
Swap your buttons, icon buttons, inputs, checkboxes, steppers, segmented controls, badges and avatars for
the `components/` versions. Button variants: `primary` (coral), `secondary`, `mint`, `outline`, `ghost`,
`danger`. Sizes `sm|md|lg`; `block` for full width. Don't invent new variants — if a button needs a new
look, it's probably `outline` or `ghost`.

### 3. App chrome
Reference: `app.jsx` → `RootNav`, `TabBar`, the FAB, `DrawerNav`.
- Header is physically fixed in both directions: **settings on the left, drawer button on the right**, logo
  lockup centred on the group screen; other root screens show the screen title right-aligned next to the drawer.
- Primary "add" action is a **floating action button** pinned bottom-right, not a header button.
- Bottom tab bar: Home / Recipes / Settings, active tab in coral.

### 4. Splash + welcome
Reference: `screens-auth.jsx` → `Splash`, `Welcome`.
- Splash: cream, faint rotating brand seals, the mark eases in, then everything crossfades out into the
  welcome screen (same background, so the handoff is invisible). No text, no character, no circle.
- Welcome: logo lockup, the slogan, `ابدأ الآن` primary + sign-in ghost, Zaytona character peeking in from
  the top-right edge. Invite codes belong in the create/join group step, not here.

### 5. Auth (register / login / OTP)
Reference: `screens-auth.jsx`. Field labels above `Input`s, optional fields marked `(اختياري)`, one primary
submit at the bottom, inline error text under the field.

### 6. Group home
Reference: `screens-main.jsx` → `GroupDetail`.
- Group card = `FamilyCard`: flat tint (no gradient), navy outline + pop shadow, role badge, group name, member `AvatarGroup`, seal on the end side.
- `SegmentedControl` for Lists / Recipes with counts.
- **List cards** = `ListSummaryCard`: pink surface, navy outline + pop shadow, seal at the text start,
  name, `N items · updated`, urgent pill at the top end. No progress bar, no "bought" count (that lives in trip history).
- Recipe cards use the same card language.

### 7. List detail
Reference: `screens-main.jsx` → `ListDetail`.
- Minimal header: back, seal + large list name, item count + urgent badge, hairline divider — plus exactly
  two actions: **bell** (trip alerts) and **⋯** (menu).
- The ⋯ opens a **compact popover anchored under the button** with: list settings (rename + colour),
  history, delete all items, delete list. Each opens its own sheet/dialog.
- Items are grouped by aisle with `CategoryStar` badges and a `QtyStepper`; sticky bottom bar has
  "Start trip" + "Add item".

### 8. Add item
Reference: `screens-flows.jsx` → `AddItemSheet`, `CatalogPicker`, `ManualForm`.
- Add item opens a **full screen** (status-bar safe area, back button, title + subtitle), not a sheet.
- Catalog: search field, category chip row, two-column **item cards** (`CatalogItemCard`) — category image
  block, name, brand/unit, centred quantity stepper, mint "Add" button.
- Empty search state offers "create «what you typed»".
- A "Create item" button pinned to the bottom opens the manual form **as a popup sheet**: photo upload
  rectangle, name, category as a searchable chip select, quantity, urgent toggle, and brand/note hidden
  behind a minimal coral **"تفاصيل إضافية؟"** text toggle.

### 9. Shopping trip + history
Reference: `screens-flows.jsx` → `BuyingView`, `screens-more.jsx` → `History`.
- Buying view checks items off by aisle and completes a trip.
- History has Activity and Trips tabs. A trip card (`TripCard`) shows the **buyer's avatar**, date, item count, the
  bought items (3 with a "View more +N" toggle) and an "add these back to the list" button.

### 10. Trip alerts
Reference: `screens-more.jsx` → `Notifications`. A bottom-sheet popup with three compact `AlertWidget`s
(heading to the store / assign a buyer / remind someone). Picking a member shows them selected inline with
a "change" action.

### 11. Recipes
Reference: `screens-recipes.jsx`, `screens-more.jsx`. Recipe book with My / Saved tabs (no header blurb),
recipe detail with add-all-ingredients, recipe form, and "add to a group" creating a group-customised copy.

### 12. Account + about
Reference: `app.jsx` → `Account`, `EditAccount`, `AboutSheet`. Profile card, language, notifications, about,
sign-out pinned to the bottom. Edit form: avatar picker block, first/last name, phone, optional email.
About sheet: the Zaytona heart, "built with love", the name story, and the team grid.

### 13. First-run tips
Reference: `app.jsx` → `TipsCoach`. After sign-up (and after creating a group) three coach marks point at
the drawer, the group settings gear, and the add button. The invite code is *not* auto-popped.

### 14. Failure states
Use `Toast` only for transient confirmations and `Banner` for an inline warning inside a working screen.
When a screen **cannot render** (offline, failed load, dead invite link) show the full-screen `ErrorState`:
coral seal, plain-language title, what to do next, a primary "Try again", an optional escape route, and a
quiet code pill for support. Never leave a blank screen or a bare spinner.

## Flutter handoff

`deliverables/` carries the platform-neutral layer:

- `zaytona_theme.dart` — every token as a Dart constant (`ZaytonaColors`, `ZaytonaRadii`, `ZaytonaShadows`, `ZaytonaType`), 1:1 with `tokens/*.css`, plus the pubspec font registration snippet.
- `zaytona-tokens.tokens.json` — the same values in Design Tokens format (Figma variable source).
- `components-manifest.md` — the component inventory.

There are **no Flutter widgets yet** — `components/` is React. Build the widgets from these tokens,
using each component's `.d.ts` as the prop contract and the prototype as the behavioural spec. Keep the
names below so the two sides stay greppable.

| React (source of truth) | Flutter widget | Notes |
| --- | --- | --- |
| `Button` | `ZaytonaButton` | `variant`: primary/secondary/mint/outline/ghost/danger · `size`: sm/md/lg · `block`. Solid variants press *into* the pop shadow. |
| `IconButton` | `ZaytonaIconButton` | `tone`: indigo/red/mint/navy · `variant`: soft/solid/outline/ghost · circle or square. |
| `Badge` | `ZaytonaBadge` | tone + soft/solid/outline, `dot`. |
| `Avatar` / `AvatarGroup` | `ZaytonaAvatar` / `ZaytonaAvatarGroup` | Character images, `ring` colour, `max` overlap. |
| `Card` | `ZaytonaCard` | `variant`: plain/pop/sunken/brand. `pop` = navy outline + hard shadow. |
| `Input` | `ZaytonaTextField` | 54px, navy border, indigo focus ring, error text under the field. |
| `Checkbox` | `ZaytonaCheckbox` | Chunky mint tick. |
| `QtyStepper` | `ZaytonaQtyStepper` | `min` 0 deletes the row in list detail. |
| `SegmentedControl` | `ZaytonaSegmentedControl` | With per-option `badge` counts. |
| `Star` (alias `Blob`) | `ZaytonaSeal` | The 14-point seal; takes a child glyph + `rotate`. |
| `CategoryStar` / `CatBadge` | `ZaytonaCategorySeal` | 16 permanent category images from `cat-art/`. |
| `CategoryChip` | `ZaytonaCategoryChip` | Selected = filled tone + pop shadow. |
| `GroceryItem` | `ZaytonaGroceryTile` | Urgent = red tint + red border + flame. |
| `ListSummaryCard` | `ZaytonaListCard` | No "done" state — bought items go to trip history. |
| `CatalogItemCard` | `ZaytonaCatalogCard` | Two-up grid card in the add-item catalog. |
| `TripCard` | `ZaytonaTripCard` | Buyer avatar, count pill, items with view-more, add-back action. |
| `AlertWidget` | `ZaytonaAlertTile` | Trip-alert row; `selected` replaces the body once a member is picked. |
| `FamilyCard` | `ZaytonaGroupCard` | Flat tint, navy outline, badge, members, seal. |
| `Sidebar` + `SidebarLink`/`SidebarGroupItem`/`SidebarSection`/`SidebarDivider` | `ZaytonaDrawer` + rows | Slides from the inline-start edge (right in RTL). |
| `Sheet` | `ZaytonaSheet` | Bottom sheet + scrim + grab handle; body scrolls, actions pinned. |
| `Dialog` | `ZaytonaDialog` | Centred confirm; cancel = outline, confirm = primary/danger. |
| `Toast` | `ZaytonaToast` | Transient confirmations only. |
| `Banner` | `ZaytonaBanner` | Inline warning inside a working screen. |
| `EmptyState` | `ZaytonaEmptyState` | Seal + title + one line + CTA. |
| `ErrorState` | `ZaytonaErrorState` | Full-screen failure; never a blank screen or bare spinner. |
| `BuyingHeader` + `BuyingFilterChip` | `ZaytonaBuyingHeader` | Navy band on the trip screen; the cream item sheet rounds over it and the status bar goes navy too. |
| `FAB` | `ZaytonaFab` | Pinned bottom-right physically, in both directions. |

RTL in Flutter: rely on `Directionality` + `EdgeInsetsDirectional`/`AlignmentDirectional` everywhere,
except the app header and FAB, which stay physically placed in both directions.

## Working here

- Editing components: change `<Name>.jsx` **and** `<Name>.d.ts`, then run `check_design_system` until clean.
- The prototype loads the compiled bundle `_ds_bundle.js` — never hand-edit `_ds_bundle.js`,
  `_ds_manifest.json`, or `_adherence.oxlintrc.json`; they are generated.
- Don't add a component to `components/` unless it is used at least twice in the prototype.
