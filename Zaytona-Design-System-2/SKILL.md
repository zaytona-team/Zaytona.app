---
name: zaytona-design
description: Use this skill to generate well-branded interfaces and assets for Zaytona (زيتونه), the groceries-coordination app for Saudi families — either for production or throwaway prototypes/mocks. Contains essential design guidelines, colors, type, fonts, assets, and UI kit components for prototyping.
user-invocable: true
---

Read the `readme.md` file within this skill, and explore the other available files (`styles.css` + `tokens/` for foundations, `components/` for the React primitives and their `.prompt.md` usage notes, `ui_kits/zaytona-app/` for full-screen recreations, `assets/` for the logo, starburst, and fonts).

If creating visual artifacts (slides, mocks, throwaway prototypes, etc), copy assets out and create static HTML files for the user to view — link `styles.css` for tokens and reuse the inlined primitives/patterns from `ui_kits/zaytona-app/ui.jsx` as a starting point. If working on production code, copy assets and read the rules here to become an expert in designing with this brand.

Core brand reminders: cream background (never pure white at full bleed), heavy navy outlines, the hard-pop offset shadow (not soft blur), everything rounded/pill, the mint starburst sticker motif, and bilingual Arabic-first copy in warm sentence case. Display type = CooperArabic + Baloo 2; body = Tajawal.

If the user invokes this skill without any other guidance, ask them what they want to build or design, ask some questions, and act as an expert designer who outputs HTML artifacts _or_ production code, depending on the need.
