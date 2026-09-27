# Zaytona / Zaytona — Components manifest (Flutter/BLoC handoff)

Handoff spec for reimplementing the Zaytona component library in Flutter. Every
component below is a real export from `ui_kits/zaytona-app/ui.jsx` (interactive
primitives) or `ui_kits/zaytona-app/art.jsx` (star art). Props, variants, and
defaults are transcribed from the actual `.jsx` source — there are no `.d.ts`
files, so **this doc is the prop contract**.

- **Theme source:** `deliverables/zaytona_theme.dart` (`ZaytonaColors` / `ZaytonaSpacing` / `ZaytonaRadius` / `ZaytonaShadows` / `ZaytonaType`). Do not hardcode hex/px — reference these.
- **Signature detail:** most controls carry a **2.5px navy border** (`ZaytonaShadows.strokeBold`, `ZaytonaColors.borderBold`) + the **hard-offset pop shadow** (`ZaytonaShadows.shadowPop`, `blurRadius: 0`). Pressed state = translate `Offset(2,3)` into the shadow and drop the shadow. Build a shared `ZaytonaPressable` wrapper for this so every widget shares one press animation.
- **Naming:** prefix custom widgets `Zaytona*`. Prefer composing/subclassing Material widgets; drop to a raw `Container`+`InkWell` only where Material's chrome fights the flat sticker look (noted per row).
- **Fonts:** display = `MADE Tommy Soft` (`ZaytonaType.fontDisplay`), body/Arabic = `Vazirmatn`. Ensure `Directionality`/RTL is honored — the app is bilingual AR/EN.

Legend: **P** = primary/likely Flutter mapping.

---

## core

### Button
- **Props:** `children`, `variant='primary'`, `size='md'`, `iconLeft`, `iconRight`, `block=false`, `disabled=false`, `style`, `...rest`
- **variant:** `primary` (coral, cream text) · `secondary` (indigo, cream) · `mint` (mint, navy text) · `outline` (transparent, navy border, no shadow) · `ghost` (transparent, indigo text, no border/shadow) · `danger` (red-tint fill, red-press text, red border)
- **size:** `sm` h38 / `md` h48 / `lg` h56 · font = display 700 · radius = pill
- **Behaviour:** solid variants show `shadowPop` and depress into it on press; `outline`/`ghost` have no shadow. `disabled` → opacity .45, not-allowed.
- **Flutter:** **P** `ZaytonaButton extends StatelessWidget` wrapping an `ElevatedButton` for solid variants (`outline`→`OutlinedButton`, `ghost`→`TextButton`). Use `WidgetStateProperty` for the fills; render the pop shadow via a wrapping `DecoratedBox` (ElevatedButton elevation can't do a blur-less offset). `iconLeft/iconRight` → `Row` children; `block` → `minimumSize: Size.fromWidth(double.infinity)`.

### IconButton
- **Props:** `children` (icon), `variant='soft'`, `size='md'`, `shape='circle'`, `tone='indigo'`, `ariaLabel`, `style`
- **variant:** `soft` (tinted fill, no border) · `solid` (tone fill + navy border) · `outline` (navy border) · `ghost`
- **tone:** `indigo` · `red` · `mint` · `navy` · **size:** sm38 / md44 / lg52 · **shape:** `circle` (pill radius) / else `radius-md`
- **Behaviour:** press → `scale(0.9)`.
- **Flutter:** **P** `ZaytonaIconButton` = `IconButton.filled` / `.filledTonal` / `.outlined` by variant, wrapped in a `ScaleTransition` press. Enforce `ZaytonaSpacing.tapMin` min size.

### Badge
- **Props:** `children`, `tone='neutral'`, `variant='soft'`, `size='md'`, `dot=false`, `style`
- **tone:** `neutral` · `red` · `mint` · `indigo` · `lilac` · **variant:** `soft` / `solid` / `outline` · **size:** sm (f11,h20) / md (f13,h24) · `dot` prepends a 6px current-color dot.
- **Flutter:** **P** `ZaytonaBadge` = `Container` with `ZaytonaRadius.pill`, body font 700. (Material `Badge` is notification-count only — don't use it here.)

### Avatar — BRANDED (no initials)
- **Props:** `name=''`, `src`, `character` (1–5), `size=44`, `ring='navy'`, `style`
- **Behaviour:** always renders a **Zaytona brand mascot** character image, cover-cropped in a circle with a 2px ring. Selection: `src` → `character` (1-based) → deterministic pick from `name`. The 5 mascots are inlined (data URIs) so the component is self-contained. **No letter/initials fallback** — the old alphabet-avatar system was removed.
- **Flutter:** **P** `ZaytonaAvatar` = `CircleAvatar` with `backgroundImage`; bundle the 5 mascots as assets (`assets/avatars/av-1..5.png`) and map `character`/`name`→asset the same way; wrap in a `Container` for the 2px navy ring. Never render initials.

### AvatarGroup
- **Props:** `children`, `max=4`, `size=36`, `style`
- **Behaviour:** overlaps avatars by `-0.32 * size`; overflow shows a navy `+N` chip.
- **Flutter:** **P** `ZaytonaAvatarGroup` = `Stack` of `Positioned` avatars (RTL-aware offset via `marginInlineStart` → use `EdgeInsetsDirectional`) + a `+N` `CircleAvatar`.

### Card
- **Props:** `children`, `variant='plain'`, `tone`, `padding='md'`, `radius='lg'`, `style`, `...rest`
- **variant:** `plain` (surface-card + soft pink hairline) · `pop` (navy border + `shadowPop`) · `sunken` (surface-sunken) · `brand` (red fill, navy border, pop, cream text)
- **tone (fill override):** `red` · `mint` · `indigo` · `lilac` · **padding:** none/sm12/md18/lg26 · **radius:** md/lg/xl
- **Flutter:** **P** `ZaytonaCard` = `Container` (`BoxDecoration`: fill by variant/tone, `border` for pop/brand, `boxShadow: ZaytonaShadows.shadowPop`, `borderRadius` from `ZaytonaRadius`). Wrap in `Material`+`InkWell` only if tappable.

---

## forms

### Input
- **Props:** `value`, `onChange`, `placeholder`, `type='text'`, `icon`, `error`, `onBlur`, `autoFocus`, `dir`, `style`
- **Behaviour:** h54, surface-card fill, 2px border (navy → indigo on focus → red on error); focus adds a 4px indigo-tint ring. Error text below with alert icon. `dir` for RTL.
- **Flutter:** **P** `ZaytonaTextField` = `TextField` (or `TextFormField` with a validator) styled via `InputDecoration` (`filled`, `OutlineInputBorder` radius-md, `focusedBorder`/`errorBorder`). `icon` → `prefixIcon`; `error` → `errorText`; `dir` → wrap in `Directionality`. Drive `value`/`onChange` from a BLoC field state.

### Checkbox
- **Props:** `checked=false`, `onChange`, `label`, `size=24`, `style`
- **Behaviour:** box fills **mint** with a chunky navy tick when checked; 2.5px navy border; radius ≈ 0.32×size. Label strikes through + dims to .55 when checked (list-row semantics).
- **Flutter:** **P** `ZaytonaCheckbox` = custom (Material `Checkbox` can't do the mint fill + strike-through label cleanly). `GestureDetector` + `AnimatedContainer` box + `AnimatedDefaultTextStyle` label with `TextDecoration.lineThrough`.

### QtyStepper
- **Props:** `value=1`, `onChange`, `min=0`, `max=99`, `unit`, `size='md'`, `style`
- **Behaviour:** −/＋ pill buttons (2px navy border, `scale(0.88)` press), tabular-nums value in display font 800, optional `unit` suffix. Clamps to min/max.
- **Flutter:** **P** `ZaytonaQtyStepper` = `Row` of two `ZaytonaIconButton` (`remove`/`add`) around a tabular-nums `Text`. Clamp in the widget; emit `onChange`. No direct Material equivalent.

### SegmentedControl
- **Props:** `options=[]` (string | `{value,label,badge}`), `value`, `onChange`, `size='md'`, `style`
- **Behaviour:** sunken pill track, 2px navy border; active segment = navy fill + cream text; optional per-segment count badge.
- **Flutter:** **P** `ZaytonaSegmented` = `SegmentedButton<T>` themed (selected → navy bg/cream fg, track → surfaceSunken, pill shape) **or** a custom `Row` if the badge-in-segment is needed (SegmentedButton icon slot can host it).

---

## patterns

### CategoryChip
- **Props:** `label`, `icon`, `selected=false`, `onClick`, `tone='indigo'`, `style`
- **tone:** `indigo` · `red` · `mint` · `lilac` · **Behaviour:** h38 pill; unselected = surface-card + soft border; selected = tone fill + navy border + `shadowPopSm` (mint/lilac take navy ink, else cream); `scale(0.96)` press. `icon` is usually an emoji category token.
- **Flutter:** **P** `ZaytonaCategoryChip` = Material `FilterChip` themed to the pill/pop look (`selectedColor`, `side`, `shape: StadiumBorder`, `avatar` for the emoji), or a custom `ChoiceChip`.

### Blob (14-point star) — `ui.jsx` + `art.jsx`
- **Props:** `size=80`, `tone='red'`, `halo='cream'`, `haloWidth=7`, `rotate=0`, `children`, `style`
- **tone:** red · mint · indigo · lilac · navy · cream · **Behaviour:** renders the `BLOB_PATH` 14-point rounded star on a `0 0 220 220` viewBox, optional halo stroke, counter-rotates centered `children` (an icon/emoji) so it stays upright.
- **Flutter:** **P** `ZaytonaStar` = `CustomPaint` with a `Path` transcribed from `BLOB_PATH` (scale to `size/220`), fill by tone, optional stroke halo; center a child via `Stack`/`Align`. This is the brand mark — build it once, reuse for avatars, category badges, empty states.
- **Related art:** now first-class components — see **CategoryStar / CatBadge** below (the 16 designed category seals).

### CategoryStar / CatBadge — ✅ 16 permanent category seals
- **Source:** `components/patterns/CategoryStar.jsx` (+ `.d.ts`). Exports `CategoryStar`, `CatBadge`, `CATEGORY_IDS`, `CATEGORY_LABELS`.
- **Props:** `catId` (one of 16) or `src`, `base=''` (path prefix for the PNGs), `size=40` (CatBadge 42), `alt`, `style`
- **The 16 ids:** produce · bakery · meat · dairy · frozen · pantry · cooking · breakfast · snacks · beverages · ready · baby · care · health · household · pets. Each is a bespoke designed 14-point star illustration on a transparent ground.
- **Accessibility:** `alt` defaults to the category label; decorative uses can pass `alt=""`.
- **Flutter:** **P** `ZaytonaCategoryStar` = `Image.asset('assets/cat-art/$catId.png')` sized to the slot (list 30 · row 42 · header 40). Ship the 16 PNGs as bundled assets; expose a `CategoryId` enum matching `CATEGORY_IDS`. `CatBadge` is the row/ingredient token (default 42).

### GroceryItem — ✅ promoted to a first-class component
- **Source:** `components/patterns/GroceryItem.jsx` (+ `.d.ts`). Presentational & composition-friendly.
- **Props:** `name`, `subtitle`, `leading` (category art node), `trailing` (control node), `urgent=false`, `checked=false`, `onClick`, `style`
- **Variants/states:** default · **urgent** (red-tint fill, red border, flame glyph) · **checked/bought** (dims to .72, strikes the name). Pass a `<QtyStepper>` as `trailing` for to-buy rows, a `<Checkbox>` for bought rows; `leading` is a category `<Star>`/CatBadge.
- **Tokens:** `surface-card`/`red-tint` fill, `border-soft`/`red` border, `radius-md`, body font 700 15.5 / muted 12.5, `ink-300` strike color.
- **Accessibility:** row `onClick` is isolated from the trailing control (stops propagation); ensure the trailing control has its own label; hit target ≥44px.
- **Flutter:** **P** `ZaytonaGroceryItem` = a `ListTile`-style `Row` — `leading` slot, title/subtitle `Column`, `trailing` slot; `urgent`/`checked` drive the `BoxDecoration` + `TextStyle`. Prefer composition (pass widgets into the slots) over hardcoding.

### ListSummaryCard — ✅ promoted to a first-class component
- **Source:** `components/patterns/ListSummaryCard.jsx` (+ `.d.ts`). Self-contained (no cross-component deps); text labels are props (i18n-agnostic).
- **Props:** `name`, `total=0`, `done=0`, `urgent=0`, `updated`, `accent='indigo'` (red/indigo/mint), `completed=false`, `onClick`, label overrides (`ofLabel`/`boughtLabel`/`urgentLabel`/`doneLabel`), `style`
- **Variants/states:** active (accent edge + progress) · **urgent** (red pill when `urgent>0`) · **completed** (mint edge, "Done" pill, dimmed .82). Press → translateY(1px).
- **Tokens:** left edge bar `accent`/`mint`, progress track `surface-sunken`, `radius-lg`, `shadow-sm`-equivalent, display 700 19 title, muted 12.5 footer.
- **Accessibility:** whole card is the tap target; progress is conveyed by both the bar and the "5 of 12 bought" text (not color alone).
- **Flutter:** **P** `ZaytonaListSummaryCard` = `Row` (a 6px color-edge `Container` + a `Column` with title/`LinearProgressIndicator`/footer). Map `accent`/`completed` to the edge + progress colors.

> Note: the prototype keeps its own inline `ItemRow`/`ListCard` (in `screens-main.jsx`) so its screens stay pixel-identical; these promoted components are the canonical reusable versions to build the Flutter widgets from and to use in new surfaces.

### FamilyCard — ✅ group ("family") header
- **Source:** `components/patterns/FamilyCard.jsx` (+ `.d.ts`). Presentational & composition-friendly.
- **Props:** `name`, `meta`, `leading` (group seal node), `trailing`, `children` (controls row), `personal=false`, `onTitleClick`, `style`
- **Variants/states:** default · **personal** (meta tinted indigo) · **switchable** (`onTitleClick` → title becomes a button with a chevron, opens the group switcher).
- **Tokens:** display 800 24 name, body 600 13 meta, `text-muted`/`indigo` meta.
- **Accessibility:** title is a real `<button>` when `onTitleClick` is set; `children` (SegmentedControl) keeps its own semantics.
- **Flutter:** **P** `ZaytonaFamilyCard` = `Column`(`Row`[leading, `Column`(title,meta), trailing], slot). `onTitleClick` → tappable title with a `keyboard_arrow_down`.

### Sidebar — ✅ navigation drawer (promoted from DrawerNav)
- **Source:** `components/patterns/Sidebar.jsx` (+ `.d.ts`). Exports `Sidebar`, `SidebarLink`, `SidebarGroupItem`, `SidebarSection`, `SidebarDivider`.
- **Props (Sidebar):** `onClose`, `header`, `children`, `footer`, `width=296`, `rtl=false`, `style`. Positioned absolutely inside a relative, clipped container; scrim + slide-in panel (RTL-aware entry via `--dx`).
- **Sub-parts:** `SidebarLink` (icon chip + label, `tone`) · `SidebarGroupItem` (leading seal + name/meta + active red check) · `SidebarSection` (uppercase label) · `SidebarDivider` (hairline).
- **Tokens:** `surface-card` panel, `shadow-md`, `surface-sunken` icon chips / active row, `radius-md`/`radius-pill`.
- **Accessibility:** `role="dialog" aria-modal`; scrim closes; keep focus trapped in Flutter; respects `prefers-reduced-motion` via the shared reduce rule.
- **Flutter:** **P** `Sidebar` → `Drawer` (or a `SlideTransition` overlay for the exact motion). `SidebarLink`/`SidebarGroupItem` → `ListTile`; `SidebarSection` → a padded caption; RTL handled by `Directionality` (drawer auto-flips to the right).

---

## Extras exported from the kit (not in the original readme index, but real)

| Component | Props (key) | Flutter mapping |
|---|---|---|
| **Banner** | `tone` red/mint/indigo, `icon`, `title`, `children`, `action` | `ZaytonaBanner` = `MaterialBanner` themed, or `Container` row (tinted fill + 2px tone border) |
| **FAB** | `icon`, `label`, `onClick`, `tone` red/indigo | `FloatingActionButton` / `.extended` (label) — override to navy border + `shadowPop`, press translate |
| **Sheet** | `onClose`, `children`, `maxHeight='86%'` | `showModalBottomSheet` with a `ZaytonaSheet` shell (32px top radius, navy border, grab handle) |
| **Dialog** | `onClose`, `children` | `showDialog` + `ZaytonaDialog` (`Dialog` with radius-xl, navy border, `shadowPopLg`) |
| **Toast** | `icon`, `children` | `SnackBar` themed navy pill (`ZaytonaRadius.pill`, `shadowMd`), or an overlay widget |

---

## Global implementation notes for Flutter/BLoC

1. **One `ZaytonaPressable`** encapsulating the two press behaviours (`translate Offset(2,3)` + shadow-off for solids; `scale 0.88–0.96` for soft/icon). Every interactive widget wraps it — matches the CSS `transition: .08s`.
2. **Border + shadow are a pair.** Solids/pops get `border: 2.5px navy` **and** `shadowPop`. Keep them together in a shared `BoxDecoration` factory.
3. **No pure white.** Cards use `surfaceCard`/`surfaceSunken`; app background `bgApp` (cream). Never `Colors.white`.
4. **Mint takes navy ink** (`textOnMint`), everything else on brand color takes cream (`textOnColor`).
5. **RTL first-class.** Use `EdgeInsetsDirectional`, `Directionality`, `AlignmentDirectional` throughout — the app is bilingual and Arabic is not an afterthought.
6. **Resolve `--success-ink`** (see component-sync-report.md) before shipping mint IconButton/Badge/Banner variants.
