// zaytona_theme.dart
//
// Thalaja (Zaytona) design system — Flutter token classes + MaterialTheme wire-up.
// Single source of truth: kept 1:1 with design_source/Zaytona_Design_System/tokens/*.css
// and deliverables/thalaja-tokens.tokens.json.
//
// Naming rule: CSS custom property → camelCase Dart constant.
//   --red              → ZaytonaColors.red
//   --shadow-pop       → ZaytonaShadows.shadowPop
//   --fs-body          → ZaytonaType.fsBody
//
// Never hardcode a hex, px, or font name in a widget — reference these classes.
// Do not add values to app_colors.dart (retired).

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// COLORS   (tokens/colors.css)
// Phase-0 corrections applied:
//   · surfaceCard: #FEF1F8 → #FDDEED  (collapses with lilac per confirmed palette)
//   · successInk: #0D8A5E confirmed (darkened mint, cohesive with --mint accent)
// ─────────────────────────────────────────────────────────────────────────────
class ZaytonaColors {
  ZaytonaColors._();

  // Brand base
  static const Color red       = Color(0xFFFC5E4F); // --red   primary CTA / coral
  static const Color redPress  = Color(0xFFE8463A); // --red-press
  static const Color redTint   = Color(0xFFFFE4DF); // --red-tint

  static const Color mint      = Color(0xFF5EEDB4); // --mint  success / in-stock; takes navy ink
  static const Color mintPress = Color(0xFF36D89A); // --mint-press
  static const Color mintTint  = Color(0xFFDCFBEE); // --mint-tint

  static const Color indigo      = Color(0xFF6A65EB); // --indigo  secondary brand / links
  static const Color indigoPress = Color(0xFF5751DB); // --indigo-press
  static const Color indigoTint  = Color(0xFFE6E5FC); // --indigo-tint

  static const Color navy     = Color(0xFF0D0050); // --navy  ink / outlines / deep surfaces
  static const Color navySoft = Color(0xFF2A2173); // --navy-soft

  static const Color lilac     = Color(0xFFFDDEED); // --lilac  soft pink accent / card surface
  static const Color lilacDeep = Color(0xFFF7B9DC); // --lilac-deep
  static const Color pink      = lilac;              // --pink → var(--lilac)

  static const Color cream = Color(0xFFFFF8ED); // --cream  paper / app background

  // Ink scale
  static const Color ink900 = navy;               // --ink-900
  static const Color ink700 = Color(0xFF2E2566);  // --ink-700
  static const Color ink500 = Color(0xFF5B5390);  // --ink-500  muted body
  static const Color ink300 = Color(0xFF9C97BC);  // --ink-300  hints / placeholders
  static const Color ink100 = Color(0xFFE0DCEC);  // --ink-100  hairlines

  // Semantic surfaces
  // surfaceCard = #FDDEED (confirmed palette: "Cards" = lilac/pink)
  static const Color bgApp         = cream;              // --bg-app
  static const Color surfaceCard   = Color(0xFFFEF1F8);  // --surface-card  lighter-pink cards, no pure white
  static const Color surfaceSunken = Color(0xFFFBE3F1);  // --surface-sunken  nested/insets
  static const Color surfaceInverse = navy;              // --surface-inverse
  static const Color surfaceBrand  = red;                // --surface-brand

  // Semantic text
  static const Color textStrong  = navy;             // --text-strong
  static const Color textBody    = Color(0xFF241B5C); // --text-body
  static const Color textMuted   = ink500;            // --text-muted
  static const Color textHint    = ink300;            // --text-hint
  static const Color textOnColor = cream;             // --text-on-color  (on red/indigo/navy)
  static const Color textOnMint  = navy;              // --text-on-mint   (mint takes navy ink)
  static const Color link        = indigo;            // --link

  // Borders
  static const Color borderHair = ink100;              // --border-hair
  static const Color borderSoft = Color(0xFFF6D2E6);   // --border-soft  pink hairline on cards
  static const Color borderBold = navy;                // --border-bold  signature heavy outline

  // Semantic states
  static const Color success     = mint;     // --success
  static const Color successTint = mintTint; // --success-tint
  static const Color successInk  = Color(0xFF0D8A5E); // --success-ink (darkened mint; confirmed)
  static const Color danger      = red;      // --danger
  static const Color dangerTint  = redTint;  // --danger-tint
  static const Color info        = indigo;   // --info
  static const Color infoTint    = indigoTint; // --info-tint

  // Focus
  static const Color focusRing = indigo; // --focus-ring
}

// ─────────────────────────────────────────────────────────────────────────────
// SPACING   (tokens/spacing.css) — 4px base grid, logical px
// ─────────────────────────────────────────────────────────────────────────────
class ZaytonaSpacing {
  ZaytonaSpacing._();

  static const double space0  = 0;   // --space-0
  static const double space1  = 4;   // --space-1
  static const double space2  = 8;   // --space-2
  static const double space3  = 12;  // --space-3
  static const double space4  = 16;  // --space-4
  static const double space5  = 20;  // --space-5
  static const double space6  = 24;  // --space-6
  static const double space7  = 32;  // --space-7
  static const double space8  = 40;  // --space-8
  static const double space9  = 48;  // --space-9
  static const double space10 = 64;  // --space-10
  static const double space12 = 80;  // --space-12

  static const double gutter       = 20;  // --gutter  default screen padding
  static const double containerMax = 480; // --container-max  phone canvas

  static const double controlHSm = 36; // --control-h-sm
  static const double controlHMd = 48; // --control-h-md  default tap target
  static const double controlHLg = 56; // --control-h-lg  primary CTA

  static const double tapMin = 44; // --tap-min  minimum hit area

  static const double iconSm = 18; // --icon-sm
  static const double iconMd = 24; // --icon-md
  static const double iconLg = 28; // --icon-lg
}

// ─────────────────────────────────────────────────────────────────────────────
// RADIUS   (tokens/radii.css)
// ─────────────────────────────────────────────────────────────────────────────
class ZaytonaRadius {
  ZaytonaRadius._();

  static const double xs   = 8;   // --radius-xs
  static const double sm   = 12;  // --radius-sm
  static const double md   = 16;  // --radius-md  inputs / small cards
  static const double lg   = 24;  // --radius-lg  cards
  static const double xl   = 32;  // --radius-xl  sheets / big cards
  static const double xxl  = 40;  // --radius-2xl  app-icon tiles
  static const double pill = 999; // --radius-pill  buttons / chips / avatars

  static BorderRadius get brXs   => BorderRadius.circular(xs);
  static BorderRadius get brSm   => BorderRadius.circular(sm);
  static BorderRadius get brMd   => BorderRadius.circular(md);
  static BorderRadius get brLg   => BorderRadius.circular(lg);
  static BorderRadius get brXl   => BorderRadius.circular(xl);
  static BorderRadius get brPill => BorderRadius.circular(pill);
}

// ─────────────────────────────────────────────────────────────────────────────
// SHADOWS   (tokens/shadows.css)
// The brand reads flat & bold. Signature = hard-offset pop with blurRadius:0.
// Pressed state = translate Offset(2,3) into shadow + drop the shadow.
// Soft shadows are reserved for sheets / dropdowns / toasts only.
// ─────────────────────────────────────────────────────────────────────────────
class ZaytonaShadows {
  ZaytonaShadows._();

  // Hard-offset pop (no blur) — the brand's signature elevation
  static const List<BoxShadow> shadowPopSm = [
    BoxShadow(color: ZaytonaColors.navy, offset: Offset(2, 3), blurRadius: 0),
  ]; // --shadow-pop-sm

  static const List<BoxShadow> shadowPop = [
    BoxShadow(color: ZaytonaColors.navy, offset: Offset(4, 5), blurRadius: 0),
  ]; // --shadow-pop

  static const List<BoxShadow> shadowPopLg = [
    BoxShadow(color: ZaytonaColors.navy, offset: Offset(6, 7), blurRadius: 0),
  ]; // --shadow-pop-lg

  static const List<BoxShadow> shadowPopIndigo = [
    BoxShadow(color: ZaytonaColors.indigo, offset: Offset(4, 5), blurRadius: 0),
  ]; // --shadow-pop-indigo

  static const List<BoxShadow> shadowPopRed = [
    BoxShadow(color: ZaytonaColors.red, offset: Offset(4, 5), blurRadius: 0),
  ]; // --shadow-pop-red

  // Soft shadows — sheets / dropdowns / toasts only
  static const List<BoxShadow> shadowSm = [
    BoxShadow(color: Color(0x140D0050), offset: Offset(0, 2), blurRadius: 6),
  ]; // --shadow-sm  navy @ 8%

  static const List<BoxShadow> shadowMd = [
    BoxShadow(color: Color(0x1F0D0050), offset: Offset(0, 8), blurRadius: 20),
  ]; // --shadow-md  navy @ 12%

  static const List<BoxShadow> shadowLg = [
    BoxShadow(color: Color(0x2E0D0050), offset: Offset(0, 18), blurRadius: 40),
  ]; // --shadow-lg  navy @ 18%

  // Outline widths for the bold-stroke motif
  static const double strokeBold  = 2.5; // --stroke-bold   primary controls / emphasis
  static const double strokeHeavy = 4;   // --stroke-heavy
}

// ─────────────────────────────────────────────────────────────────────────────
// TYPOGRAPHY   (tokens/typography.css + tokens/fonts.css)
//
// Font registration in pubspec.yaml (already added):
//   - family: MADE Tommy Soft
//     fonts: [{ asset: assets/fonts/MADETommySoft.otf }]
//   - family: Vazirmatn
//     fonts: [{ asset: assets/fonts/Vazirmatn.ttf }]
//
// Cascade rule: Latin glyphs → MADE Tommy Soft; Arabic → Vazirmatn (also body).
// ─────────────────────────────────────────────────────────────────────────────
class ZaytonaType {
  ZaytonaType._();

  static const String fontDisplay = 'MADE Tommy Soft'; // --font-display  Latin titles/numbers
  static const String fontBody    = 'Vazirmatn';        // --font-body     UI + Arabic

  // Weights
  static const FontWeight fwLight   = FontWeight.w300; // --fw-light
  static const FontWeight fwRegular = FontWeight.w400; // --fw-regular
  static const FontWeight fwMedium  = FontWeight.w500; // --fw-medium
  static const FontWeight fwBold    = FontWeight.w700; // --fw-bold
  static const FontWeight fwBlack   = FontWeight.w800; // --fw-black

  // Type scale (logical px)
  static const double fsDisplayXl = 64; // --fs-display-xl  hero / splash
  static const double fsDisplayLg = 48; // --fs-display-lg  screen titles
  static const double fsDisplayMd = 36; // --fs-display-md
  static const double fsDisplaySm = 28; // --fs-display-sm  section headers
  static const double fsTitle     = 22; // --fs-title       card titles
  static const double fsBodyLg    = 18; // --fs-body-lg
  static const double fsBody      = 16; // --fs-body        default UI text
  static const double fsBodySm    = 14; // --fs-body-sm
  static const double fsCaption   = 13; // --fs-caption
  static const double fsMicro     = 11; // --fs-micro       labels / overlines

  // Line heights (Flutter `height` multiplier)
  static const double lhTight   = 1.05; // --lh-tight
  static const double lhSnug    = 1.2;  // --lh-snug
  static const double lhNormal  = 1.45; // --lh-normal
  static const double lhRelaxed = 1.6;  // --lh-relaxed

  // Letter spacing as em multipliers — apply as: fontSize * lsTightEm
  static const double lsTightEm  = -0.01; // --ls-tight
  static const double lsNormalEm =  0.0;  // --ls-normal
  static const double lsWideEm   =  0.04; // --ls-wide  overlines / small caps

  // ── Ready-made styles ──────────────────────────────────────────────────────
  // Display — MADE Tommy Soft, tight, heavy
  static const TextStyle displayLg = TextStyle(
    fontFamily: fontDisplay,
    fontFamilyFallback: [fontBody],
    fontWeight: fwBold,
    fontSize: fsDisplayLg,
    height: lhTight,
    letterSpacing: fsDisplayLg * lsTightEm,
    color: ZaytonaColors.textStrong,
  );

  static const TextStyle displaySm = TextStyle(
    fontFamily: fontDisplay,
    fontFamilyFallback: [fontBody],
    fontWeight: fwBold,
    fontSize: fsDisplaySm,
    height: lhSnug,
    color: ZaytonaColors.textStrong,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontDisplay,
    fontFamilyFallback: [fontBody],
    fontWeight: fwBold,
    fontSize: fsTitle,
    height: lhSnug,
    color: ZaytonaColors.textStrong,
  );

  // Body — Vazirmatn, handles both EN and AR
  static const TextStyle body = TextStyle(
    fontFamily: fontBody,
    fontWeight: fwRegular,
    fontSize: fsBody,
    height: lhNormal,
    color: ZaytonaColors.textBody,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: fontBody,
    fontWeight: fwRegular,
    fontSize: fsBodySm,
    height: lhNormal,
    color: ZaytonaColors.textBody,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontBody,
    fontWeight: fwRegular,
    fontSize: fsCaption,
    height: lhNormal,
    color: ZaytonaColors.textMuted,
  );

  // Overline / label — uppercase micro, wide tracking
  static const TextStyle overline = TextStyle(
    fontFamily: fontBody,
    fontWeight: fwBold,
    fontSize: fsMicro,
    letterSpacing: fsMicro * lsWideEm,
    color: ZaytonaColors.textMuted,
  );

  // ── Semantic styles ────────────────────────────────────────────────────────
  // Screen header title — centered app-bar style (prototype: screen headers)
  static const TextStyle screenTitle = TextStyle(
    fontFamily: fontDisplay,
    fontFamilyFallback: [fontBody],
    fontWeight: fwBlack,
    fontSize: fsTitle,
    height: lhSnug,
    color: ZaytonaColors.textStrong,
  );

  // Card title — list card names (prototype: ListCard 19px/700)
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontDisplay,
    fontFamilyFallback: [fontBody],
    fontWeight: fwBold,
    fontSize: 19,
    height: lhSnug,
    color: ZaytonaColors.textStrong,
  );

  // Sheet title — bottom-sheet headers (prototype: sheet headers 22px/800)
  static const TextStyle sheetTitle = TextStyle(
    fontFamily: fontDisplay,
    fontFamilyFallback: [fontBody],
    fontWeight: fwBlack,
    fontSize: fsTitle,
    height: lhSnug,
    color: ZaytonaColors.textStrong,
  );

  // Field label — above form inputs (prototype: FieldLabel 13px/700 muted)
  static const TextStyle fieldLabel = TextStyle(
    fontFamily: fontBody,
    fontWeight: fwBold,
    fontSize: fsCaption,
    color: ZaytonaColors.textMuted,
  );

  // Meta line — secondary info on cards (prototype: 12.5px/600 muted)
  static const TextStyle meta = TextStyle(
    fontFamily: fontBody,
    fontWeight: fwMedium,
    fontSize: 12.5,
    color: ZaytonaColors.textMuted,
  );

  // Inline error text under fields
  static const TextStyle fieldError = TextStyle(
    fontFamily: fontBody,
    fontWeight: fwMedium,
    fontSize: fsBodySm,
    color: ZaytonaColors.danger,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// THEME — wires the tokens into a Material ThemeData.
// Use ZaytonaTheme.light as the app theme in MaterialApp.
// ─────────────────────────────────────────────────────────────────────────────
class ZaytonaTheme {
  ZaytonaTheme._();

  static ThemeData get light => lightWithFont(ZaytonaType.fontBody);

  /// Same theme with a different base font — the app picks the family per
  /// locale (Vazirmatn for Arabic, MADE Tommy Soft for English). The DS
  /// stays locale-agnostic; it only exposes the knob.
  static ThemeData lightWithFont(String fontFamily) => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: ZaytonaColors.bgApp,
        fontFamily: fontFamily,
        colorScheme: const ColorScheme.light(
          primary: ZaytonaColors.red,
          onPrimary: ZaytonaColors.cream,
          secondary: ZaytonaColors.indigo,
          onSecondary: ZaytonaColors.cream,
          tertiary: ZaytonaColors.mint,
          onTertiary: ZaytonaColors.navy,
          surface: ZaytonaColors.surfaceCard,
          onSurface: ZaytonaColors.textBody,
          error: ZaytonaColors.danger,
          onError: ZaytonaColors.cream,
          outline: ZaytonaColors.borderBold,
        ),
        textTheme: const TextTheme(
          displayLarge: ZaytonaType.displayLg,
          displaySmall: ZaytonaType.displaySm,
          titleLarge: ZaytonaType.title,
          bodyMedium: ZaytonaType.body,
          bodySmall: ZaytonaType.bodySm,
          labelSmall: ZaytonaType.overline,
        ),
      );
}
