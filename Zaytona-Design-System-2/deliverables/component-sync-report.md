# Component sync report — Zaytona / Zaytona

> **UPDATE 3 (product-alignment + collapse):** `ui.jsx` **removed** — the prototype now consumes `_ds_bundle.js` directly (a one-line global bridge feeds its screen scripts), so `components/` is the sole source of truth. **CategoryStar/CatBadge** (16 permanent category seals), **FamilyCard** (group header), and **Sidebar** (+ sub-parts) promoted to first-class components. `care.png` (personal-care) was missing its lilac star — recut from `categories.png`. New Brand guideline cards for the mascot avatars and the 16-category art. Fonts already Tommy Soft + Vazirmatn.

> **UPDATE 2 (refactor pass):** design system aligned to current product & prepped for Flutter — legacy **Cooper/Baloo/Tajawal** font references purged (tokens already use MADE Tommy Soft + Vazirmatn); **letter/initials avatars removed** in favor of the inlined Zaytona **mascot** system; **GroceryItem** and **ListSummaryCard** promoted to first-class components; the **orphan root `app.jsx`** duplicate deleted; and `ui_kits/zaytona-app/ui.jsx` is now a **generated/derived** build of `components/` (single source of truth). Prototype verified **pixel-identical**. Component count: **20**.

> **UPDATE 1 (resolved):** the `components/` library described below as missing has since been **built** — `ui.jsx` was split into `components/{core,forms,patterns}/<Name>.jsx` + `<Name>.d.ts`, with one `*.card.html` specimen per group. `check_design_system` now compiles the full component set, and `--success-ink` was added to `tokens/colors.css`. The original finding is kept below for provenance.

---

_Packaging pass for Figma import + Flutter handoff. No components were added, removed, or changed._

## Headline finding — the `components/` triples do not exist on disk

The readme (`readme.md`) advertises a component library at:

```
components/core/    Button, IconButton, Badge, Avatar + AvatarGroup, Card
components/forms/   Input, Checkbox, QtyStepper, SegmentedControl
components/patterns/ GroceryItem, CategoryChip, ListSummaryCard, category star art
…each with <Name>.jsx, <Name>.d.ts, <Name>.prompt.md + one *.card.html
```

**None of that folder tree exists.** `check_design_system` reports **0 compiled components**, and `list_files` shows no `components/` directory. The readme index is aspirational/planned, not built.

The components it describes **do exist as source** — but as inlined primitives in a single file:

- `ui_kits/zaytona-app/ui.jsx` — all the interactive primitives (18 exports).
- `ui_kits/zaytona-app/art.jsx` — the 14-point star / category art.
- `ui_kits/zaytona-app/icons.jsx` — the Lucide icon subset.

So there is **nothing to "confirm in sync"** in the `.jsx` / `.d.ts` / `.card.html` sense, because no `.d.ts` and no per-component `.card.html` were ever authored. Per the "do not introduce new components" constraint, **this pass did not fabricate the triples** — doing so would be authoring new design-system surface, not packaging existing work. It is documented here instead so nothing is lost in translation.

## What exists vs. what the readme claims

| Readme group | Readme claims | Actually in source | Status |
|---|---|---|---|
| core | Button, IconButton, Badge, Avatar, AvatarGroup, Card | all present in `ui.jsx` | ✅ source exists (no `.d.ts`/`.card.html`) |
| forms | Input, Checkbox, QtyStepper, SegmentedControl | all present in `ui.jsx` | ✅ source exists (no `.d.ts`/`.card.html`) |
| patterns | GroceryItem, CategoryChip, ListSummaryCard, star art | `CategoryChip` in `ui.jsx`; star art (`Blob`) in `ui.jsx` + `art.jsx`; **`GroceryItem` and `ListSummaryCard` are screen-level code in `app.jsx`, not standalone exports** | ⚠ partial |
| — | (not in readme) | `Banner`, `FAB`, `Sheet`, `Dialog`, `Toast` also exported from `ui.jsx` | ➕ undocumented extras |

## Token gap that affects components

- **`--success-ink` is referenced but never defined.** `ui.jsx` uses `var(--success-ink)` in the mint variants of `IconButton`, `Badge`, and `Banner`, but no such token exists in `tokens/colors.css`. It currently resolves to nothing (inherits/transparent). The Figma JSON and Flutter theme include a **proposed** value (`#0D8A5E`, darkened mint for navy-on-mint contrast) flagged `⚠`. **Action:** confirm with brand and add `--success-ink` to `colors.css`, or repoint those variants to `--navy`.

## Recommended next step (not done here — would add surface)

If you want the real `components/` library the readme promises, the clean path is to **split `ui.jsx` into per-component `components/<group>/<Name>.jsx` + author a matching `<Name>.d.ts` + one `*.card.html` per directory**, then re-run `check_design_system` so they compile into the bundle and show as cards. That is a build task, deliberately out of scope for this packaging pass. Say the word and it's a follow-up.
