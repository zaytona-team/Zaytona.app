# Zaytona Design System

**Zaytona** (زيتونة — Arabic for *"olive"*) is a groceries-coordination mobile app for Saudi families and groups. Households keep shared lists, split the shopping, and see in real time what's already in the cart — so nobody buys two trays of eggs and nobody forgets the laban.

This repository is the brand's design system: tokens, fonts, reusable React components, a full mobile UI kit, and the brand guidelines below. Consuming projects link **`styles.css`** (the only fixed entry point) and pull components from the compiled bundle.

> **Vibe in one line:** a warm, playful sticker-book — bold rounded type, candy-bright colors, heavy navy outlines, and the signature 14-point star mark, equally at home in Arabic and English.

---

## Sources & provenance

Provided by the client (stored in `assets/`):
- `assets/logo-app-icon.png` — the Zaytona app icon.
- `assets/brand-sheet.png` — the master brand sheet (logo lockups + palette). Palette hex values were reconciled against `tokens/colors.css`.
- `assets/fonts/` — the brand faces: `Vazirmatn.ttf` and `MADETommySoft.otf`.

No codebase, Figma file, or slide deck was provided — the component and screen designs are an original system *derived from* the brand sheet's palette, type, and star motif, not a recreation of an existing product UI. If a production codebase or Figma exists, re-attach it and this system should be reconciled against it.

---

## Content fundamentals

How Zaytona talks. The product is **bilingual (Arabic + English)**; Arabic is first-class, not an afterthought.

- **Warm, second-person, and familial.** We address the user directly ("you"/"أنت") and by name. Copy sounds like a helpful family member, not a corporation. Greetings use everyday Gulf Arabic transliterations: *"Sabah al-khair, Reem"*, *"Suhoor is in 3 days."*
- **Short and concrete.** Labels are 1–3 words ("To buy", "Bought", "Add item", "Invite"). Helper lines are one breath: *"12 items · shared with 4."*
- **Sentence case, never SHOUTY.** Buttons and titles are sentence case ("Add to list", not "ADD TO LIST"). Overlines/eyebrows are the only uppercase, and only at micro size.
- **Culturally grounded.** Real Saudi grocery vocabulary and context: *laban, tamees bread, Sukkari dates, Arabic coffee beans, cardamom, suhoor, Ramadan pantry.* Households are named ("Al-Otaibi household").
- **Gently encouraging, lightly celebratory.** Completion is rewarded with warmth, not confetti spam: *"All bought! 🎉"*, *"Nothing here yet."*
- **Emoji: yes, but as functional category tokens** (🥛 dairy, 🥬 produce, 🍞 bakery, 🍗 meat, 🫙 pantry) and the occasional friendly greeting (👋). Never as decorative filler in body copy.
- **Numbers are friendly fractions, not dashboards.** "5/12 done" beats a percentage. Avoid data-slop stats.

**Voice cheat-sheet**
- ✅ "Sabah al-khair, Reem 👋 — suhoor is in 3 days."
- ✅ "Add to a list…"  ·  "2 cartons · full fat"  ·  "Reem checked off 3 items"
- ❌ "OPTIMIZE YOUR GROCERY WORKFLOW"  ·  "Click here to proceed"  ·  "Item successfully added to database"

---

## Visual foundations

The look is **flat, bold, and sticker-like** — closer to a children's-book sticker sheet or a fruit-stand crate label than a typical fintech app.

### Color
Six brand colors — the Sprint-4 palette, all defined in `tokens/colors.css`:
- **Coral `#FC5E4F`** — the primary. Energy, CTAs, the star mark. (`--red`)
- **Mint `#5EEDB4`** — fresh/success/"in stock"; takes **navy** ink on top. (`--mint`)
- **Periwinkle `#6A65EB`** — secondary brand, links, info. (`--indigo`)
- **Navy `#0D0050`** — the ink. All text, all outlines, deep surfaces. (`--navy`)
- **Pink `#FDDEED`** — soft accent, tags, gentle cards. (`--lilac` / `--pink`)
- **Cream `#FFF8ED`** — the paper. The default app background; *never* pure white at full bleed. (`--cream`)

Surfaces stack cream → sunken-pink (`--surface-sunken` `#FBE3F1`) → pink card (`--surface-card` `#FEF1F8`) — the brand deliberately avoids pure-white cards to lower visual fatigue against the cream paper. Each action color has a `-tint` (soft fill) and `-press` (darker) step. See `tokens/colors.css`.

### Type
- **Display:** **MADE Tommy Soft** — a rounded geometric Latin display face; retro warmth. Used for screen titles, card titles, numbers. (`--font-display`)
- **Body/UI + Arabic:** **Vazirmatn** — a clean variable bilingual sans, excellent for Arabic, covering both body text and Arabic display weights. All body, labels, inputs. (`--font-body`)
- Both faces are self-hosted from `assets/fonts/` and declared in `tokens/fonts.css` (`Vazirmatn.ttf`, weights 100–900; `MADETommySoft.otf`, weights 400–800).
- Display is set tight (`-0.01em`, line-height 1.05–1.2) and heavy (700–800). Body is 16px, weight 400–500, line-height 1.45.

### Shape, border & elevation — the signature
- **Everything is rounded.** Radii run 8 → 40px, with `--radius-pill` (999) for all buttons, chips, avatars, and steppers.
- **Heavy navy outlines.** Primary controls and emphasis cards carry a `2.5px` navy stroke. This is the system's backbone — when in doubt, outline it in navy.
- **The "hard pop" shadow.** The brand's signature elevation is a *hard, blur-less offset shadow* in navy (`--shadow-pop: 4px 5px 0 navy`), not a soft blur. Buttons and pop-cards visibly **depress into their shadow on press** (translate 2px/3px, shadow → none). Soft blurry shadows (`--shadow-md`) are reserved for floating sheets, menus, and toasts only.
- **Cards:** pink fill (`--surface-card`), either a soft `1.5px` pink hairline (default) or the navy outline + hard-pop (featured). Tinted pastel cards for callouts. Corner radius `--radius-lg` (24px).

### The 14-point star
The most recognizable device. A **14-point star seal** — the `_STAR14` path in `ui_kits/zaytona-app/art.jsx`, drawn on a `0 0 220 220` viewBox with 14 evenly-spaced rounded points (Bézier lobes, not straight spikes). It is *not* a wavy starburst blob. Rendered by the `Art` components:
- `CatStar` — the star filled in a **soft tint of its category hue** (`catSoft`, mixed 55% toward cream), holding the category's Lucide line icon (or emoji placeholder) upright at center.
- `CatBadge` — the category token used on item rows / ingredients (a `CatStar` at ~42px).
- `CategorySticker` — soft star + display label beside it, for section headers.
- `CatArt` — just the line icon inline, for compact rows.

Category fills are derived from each category's brand hue via the `_mix`-toward-cream helper (`catSoft` 0.55, `catTint` 0.86), keeping the stars quiet in dense lists. Use the star for avatars, category/empty-state art, and decorative accents rather than inventing new illustrative SVGs.

### Motion
Quick and tactile, never floaty. Transitions are `.08–.15s ease`. The vocabulary is **press feedback**: buttons depress into their shadow; icon buttons and chips `scale(0.9–0.96)`; checkboxes fill mint with a chunky tick. Progress bars ease their width. No long fades, no parallax, no infinite decorative loops.

### Backgrounds & imagery
Solid cream, or a soft radial warm-peach glow from the top (`radial-gradient(circle at 50% 0%, #ffe6df, cream)`). No photography in the core UI; imagery is emoji category tokens + soft stars. Imagery, where used, should read **warm and bright**, never cold or desaturated.

### States
- **Hover/active:** color controls keep their fill; feedback comes from the press transform, not a color shift.
- **Press:** solid buttons translate into the shadow; soft/ghost controls scale down.
- **Disabled:** `opacity 0.45`, `not-allowed`.
- **Focus:** `2px periwinkle` border + a `4px` periwinkle-tint ring on inputs (`--focus-ring`).
- **Checked (list rows):** row dims to `0.72`, label strikes through in `ink-300`.

### Layout
Mobile-first, `390px` phone canvas, `20px` gutters. Sticky bottom CTA over a cream protection-gradient. Bottom tab bar with the active tab in coral. Content scrolls under fixed headers/footers; never use `scrollIntoView`.

---

## Iconography

- **System:** **Lucide** (line icons, ~2.2px stroke, round caps/joins) is the canonical icon set — it matches the brand's rounded, friendly geometry. In the UI kit these are inlined as a small hand-picked set (`ui_kits/zaytona-app/icons.jsx`) so the kit is self-contained; in production, pull from Lucide directly (`lucide-react` or the CDN). **This is a substitution** — no icon assets shipped with the brand — chosen for stroke-weight and corner-radius compatibility. ⚠️ *If the real product uses a different icon set, swap `icons.jsx`.*
- **Stroke, not fill.** Icons are outline-style in navy (or the control's ink color), never duotone or filled.
- **Emoji as category tokens.** Grocery categories use emoji (🥛🥬🍞🍗🫙) inside the soft 14-point star — this is intentional and on-brand, the one sanctioned "illustrative" device alongside the star mark.
- **The 14-point star** (`_STAR14` / the `Art` components) is the brand's own icon-shape; use it for avatars and decorative accents rather than inventing new illustrative SVGs.
- Icon sizes: 18 (sm) / 24 (md) / 28 (lg), from `--icon-*` tokens.

---

## Font substitutions ⚠️

The system self-hosts two faces in `assets/fonts/`, declared in `tokens/fonts.css`:
- **MADE Tommy Soft** (`MADETommySoft.otf`) — the **Latin display** face. Rounded and warm.
- **Vazirmatn** (`Vazirmatn.ttf`) — the **bilingual body/UI + Arabic display** face.

If the brand has different official display or body fonts, **please send the files** and we'll swap them in `tokens/fonts.css` + `tokens/typography.css`.

---

## Index / manifest

**Foundations**
- `styles.css` — global entry point (imports only). Consumers link this.
- `tokens/` — `fonts.css`, `colors.css`, `typography.css`, `spacing.css`, `radii.css`, `shadows.css`, `base.css`.
- `guidelines/*.card.html` — foundation specimen cards (Colors, Type, Spacing, Brand) shown in the Design System tab.

**Components** (`components/`, namespace `window.ThalajaDesignSystem_ed2185` — the compiled global; it is generated from the project id, the brand itself is Zaytona) — split out of the UI kit into typed, standalone modules.
- `core/` — `Button`, `IconButton`, `Badge`, `Avatar`, `AvatarGroup`, `Card`.
- `forms/` — `Input`, `Checkbox`, `QtyStepper`, `SegmentedControl`.
- `patterns/` — `CategoryChip`, `Star` (the 14-point seal; `Blob` is a legacy alias), `CategoryStar` + `CatBadge` (the 16 permanent category seals), `GroceryItem`, `ListSummaryCard` (list overview card), `CatalogItemCard` (add-item catalog product card), `TripCard` (shopping-trip history card), `AlertWidget` (trip-alert action row), `EmptyState`, `ErrorState` (full-screen failure), `BuyingHeader` + `BuyingFilterChip` (shopping-trip band), `FamilyCard` (group identity card), `Sidebar` (+ `SidebarLink` / `SidebarGroupItem` / `SidebarSection` / `SidebarDivider`), `Banner`, `FAB`, `Sheet`, `Dialog`, `Toast`.
- Each component ships `<Name>.jsx` (the exported source) + `<Name>.d.ts` (typed prop contract); each directory ships one `*.card.html` specimen for the Design System tab.
- `GroceryItem`, `ListSummaryCard`, `CatalogItemCard`, `TripCard` and `FamilyCard` are first-class reusable components promoted out of the prototype screens — presentational, slot-based, and kept in sync with the app.
- **Avatars are branded:** `Avatar` renders a Zaytona mascot character (inlined, self-contained) — no letter/initials fallback.

**Prototype** (`ui_kits/zaytona-app/`) — the interactive product, unchanged by the refactor.
- `index.html` — interactive click-through: home (shared lists) → list detail (filter, check off, adjust qty) → add-item sheet → aggregated Shop view → Household. `icons.jsx` (Lucide set), `art.jsx` (14-point star category art), `app.jsx` + `screens-*.jsx` (screens + state).
- `ui.jsx` has been **removed** entirely. The prototype now loads the compiled design system (`_ds_bundle.js`) and a tiny inline bridge aliases the components onto the globals the screen scripts use — so `components/` is the single source of truth, with no hand-maintained duplicate. The prototype renders identically.

**Assets** (`assets/`)
- `logo-app-icon.png`, `brand-sheet.png`, `fonts/Vazirmatn.ttf`, `fonts/MADETommySoft.otf`.

**Other**
- `SKILL.md` — Agent-Skills manifest for use in Claude Code.
