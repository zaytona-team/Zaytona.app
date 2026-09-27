// zaytona_theme.dart
//
// Zaytona (Zaytona) design system — Flutter theme.
// Generated from tokens/*.css and kept 1:1 with deliverables/zaytona-tokens.tokens.json
// (the Figma variable source). Every constant maps to a CSS custom property of the
// SAME name: --red -> ZaytonaColors.red, --shadow-pop -> ZaytonaShadows.shadowPop,
// --fs-body -> ZaytonaType.fsBody. Dart identifiers are the CSS names camelCased.
//
// Do not hand-edit values in isolation — change the CSS token + the .tokens.json,
// then regenerate this file so Figma and Flutter never drift.

import 'package:flutter/material.dart' as material;

// ─────────────────────────────────────────────────────────────
// COLOR   (tokens/colors.css)
// ─────────────────────────────────────────────────────────────
class ZaytonaColors {
  ZaytonaColors._();

  // Brand base
  static const Color red = Color(0xFFFC5E4F); // --red
  static const Color redPress = Color(0xFFE8463A); // --red-press
  static const Color redTint = Color(0xFFFFE4DF); // --red-tint

  static const Color mint = Color(0xFF5EEDB4); // --mint
  static const Color mintPress = Color(0xFF36D89A); // --mint-press
  static const Color mintTint = Color(0xFFDCFBEE); // --mint-tint

  static const Color indigo = Color(0xFF6A65EB); // --indigo
  static const Color indigoPress = Color(0xFF5751DB); // --indigo-press
  static const Color indigoTint = Color(0xFFE6E5FC); // --indigo-tint

  static const Color navy = Color(0xFF0D0050); // --navy
  static const Color navySoft = Color(0xFF2A2173); // --navy-soft

  static const Color lilac = Color(0xFFFDDEED); // --lilac
  static const Color lilacDeep = Color(0xFFF7B9DC); // --lilac-deep
  static const Color pink = lilac; // --pink -> var(--lilac)

  static const Color cream = Color(0xFFFFF8ED); // --cream

  // Ink scale
  static const Color ink900 = navy; // --ink-900 -> var(--navy)
  static const Color ink700 = Color(0xFF2E2566); // --ink-700
  static const Color ink500 = Color(0xFF5B5390); // --ink-500
  static const Color ink300 = Color(0xFF9C97BC); // --ink-300
  static const Color ink100 = Color(0xFFE0DCEC); // --ink-100

  // Semantic surfaces
  static const Color bgApp = cream; // --bg-app
  static const Color surfaceCard = Color(0xFFFEF1F8); // --surface-card
  static const Color surfaceSunken = Color(0xFFFBE3F1); // --surface-sunken
  static const Color surfaceInverse = navy; // --surface-inverse
  static const Color surfaceBrand = red; // --surface-brand

  // Semantic text
  static const Color textStrong = navy; // --text-strong
  static const Color textBody = Color(0xFF241B5C); // --text-body
  static const Color textMuted = ink500; // --text-muted
  static const Color textHint = ink300; // --text-hint
  static const Color textOnColor = cream; // --text-on-color
  static const Color textOnMint = navy; // --text-on-mint
  static const Color link = indigo; // --link

  // Borders
  static const Color borderHair = ink100; // --border-hair
  static const Color borderSoft = Color(0xFFF6D2E6); // --border-soft
  static const Color borderBold = navy; // --border-bold

  // Semantic states
  static const Color success = mint; // --success
  static const Color successTint = mintTint; // --success-tint
  static const Color danger = red; // --danger
  static const Color dangerTint = redTint; // --danger-tint
  static const Color info = indigo; // --info
  static const Color infoTint = indigoTint; // --info-tint

  // Focus
  static const Color focusRing = indigo; // --focus-ring

  // Readable green ink for text/icons on mint & mint-tint surfaces.
  static const Color successInk = Color(0xFF0D8A5E); // --success-ink
}

// ─────────────────────────────────────────────────────────────
// SPACING   (tokens/spacing.css) — logical px, 4px base grid
// ─────────────────────────────────────────────────────────────
class ZaytonaSpacing {
  ZaytonaSpacing._();

  static const double space0 = 0; // --space-0
  static const double space1 = 4; // --space-1
  static const double space2 = 8; // --space-2
  static const double space3 = 12; // --space-3
  static const double space4 = 16; // --space-4
  static const double space5 = 20; // --space-5
  static const double space6 = 24; // --space-6
  static const double space7 = 32; // --space-7
  static const double space8 = 40; // --space-8
  static const double space9 = 48; // --space-9
  static const double space10 = 64; // --space-10
  static const double space12 = 80; // --space-12

  static const double gutter = 20; // --gutter
  static const double containerMax = 480; // --container-max

  static const double controlHSm = 36; // --control-h-sm
  static const double controlHMd = 48; // --control-h-md
  static const double controlHLg = 56; // --control-h-lg
  static const double tapMin = 44; // --tap-min

  static const double iconSm = 18; // --icon-sm
  static const double iconMd = 24; // --icon-md
  static const double iconLg = 28; // --icon-lg
}

// ─────────────────────────────────────────────────────────────
// RADIUS   (tokens/radii.css)
// ─────────────────────────────────────────────────────────────
class ZaytonaRadius {
  ZaytonaRadius._();

  static const double xs = 8; // --radius-xs
  static const double sm = 12; // --radius-sm
  static const double md = 16; // --radius-md
  static const double lg = 24; // --radius-lg
  static const double xl = 32; // --radius-xl
  static const double xxl = 40; // --radius-2xl
  static const double pill = 999; // --radius-pill

  // BorderRadius conveniences
  static BorderRadius get brMd => BorderRadius.circular(md);
  static BorderRadius get brLg => BorderRadius.circular(lg);
  static BorderRadius get brXl => BorderRadius.circular(xl);
  static BorderRadius get brPill => BorderRadius.circular(pill);
}

// ─────────────────────────────────────────────────────────────
// SHADOW   (tokens/shadows.css)
// The signature "hard pop" is a blur-less navy offset. Flutter BoxShadow
// with blurRadius:0 reproduces it.
// ─────────────────────────────────────────────────────────────
class ZaytonaShadows {
  ZaytonaShadows._();

  static const List<BoxShadow> shadowPopSm = [
    BoxShadow(color: ZaytonaColors.navy, offset: Offset(2, 3), blurRadius: 0), // --shadow-pop-sm
  ];
  static const List<BoxShadow> shadowPop = [
    BoxShadow(color: ZaytonaColors.navy, offset: Offset(4, 5), blurRadius: 0), // --shadow-pop
  ];
  static const List<BoxShadow> shadowPopLg = [
    BoxShadow(color: ZaytonaColors.navy, offset: Offset(6, 7), blurRadius: 0), // --shadow-pop-lg
  ];
  static const List<BoxShadow> shadowPopIndigo = [
    BoxShadow(color: ZaytonaColors.indigo, offset: Offset(4, 5), blurRadius: 0), // --shadow-pop-indigo
  ];
  static const List<BoxShadow> shadowPopRed = [
    BoxShadow(color: ZaytonaColors.red, offset: Offset(4, 5), blurRadius: 0), // --shadow-pop-red
  ];

  static const List<BoxShadow> shadowSm = [
    BoxShadow(color: Color(0x140D0050), offset: Offset(0, 2), blurRadius: 6), // --shadow-sm (navy @ .08)
  ];
  static const List<BoxShadow> shadowMd = [
    BoxShadow(color: Color(0x1F0D0050), offset: Offset(0, 8), blurRadius: 20), // --shadow-md (navy @ .12)
  ];
  static const List<BoxShadow> shadowLg = [
    BoxShadow(color: Color(0x2E0D0050), offset: Offset(0, 18), blurRadius: 40), // --shadow-lg (navy @ .18)
  ];

  // Outline widths
  static const double strokeBold = 2.5; // --stroke-bold
  static const double strokeHeavy = 4; // --stroke-heavy
}

// ─────────────────────────────────────────────────────────────
// TYPOGRAPHY   (tokens/typography.css, tokens/fonts.css)
// Register the fonts in pubspec.yaml:
//   fonts:
//     - family: MADE Tommy Soft
//       fonts: [{ asset: assets/fonts/MADETommySoft.otf }]
//     - family: Vazirmatn
//       fonts: [{ asset: assets/fonts/Vazirmatn.ttf }]
// ─────────────────────────────────────────────────────────────
class ZaytonaType {
  ZaytonaType._();

  // Families (first family + fallbacks via fontFamilyFallback)
  static const String fontDisplay = 'MADE Tommy Soft'; // --font-display
  static const String fontBody = 'Vazirmatn'; // --font-body
  static const String fontMono = 'Vazirmatn'; // --font-mono
  static const List<String> displayFallback = ['Vazirmatn'];

  // Weights
  static const FontWeight fwLight = FontWeight.w300; // --fw-light
  static const FontWeight fwRegular = FontWeight.w400; // --fw-regular
  static const FontWeight fwMedium = FontWeight.w500; // --fw-medium
  static const FontWeight fwBold = FontWeight.w700; // --fw-bold
  static const FontWeight fwBlack = FontWeight.w800; // --fw-black

  // Sizes (px == logical px)
  static const double fsDisplayXl = 64; // --fs-display-xl
  static const double fsDisplayLg = 48; // --fs-display-lg
  static const double fsDisplayMd = 36; // --fs-display-md
  static const double fsDisplaySm = 28; // --fs-display-sm
  static const double fsTitle = 22; // --fs-title
  static const double fsBodyLg = 18; // --fs-body-lg
  static const double fsBody = 16; // --fs-body
  static const double fsBodySm = 14; // --fs-body-sm
  static const double fsCaption = 13; // --fs-caption
  static const double fsMicro = 11; // --fs-micro

  // Line heights (multipliers -> Flutter `height`)
  static const double lhTight = 1.05; // --lh-tight
  static const double lhSnug = 1.2; // --lh-snug
  static const double lhNormal = 1.45; // --lh-normal
  static const double lhRelaxed = 1.6; // --lh-relaxed

  // Letter spacing (em -> logical px is size-relative; use with fontSize)
  // ls-tight = -0.01em, ls-wide = 0.04em. Multiply by fontSize at use site.
  static const double lsTightEm = -0.01; // --ls-tight
  static const double lsNormalEm = 0.0; // --ls-normal
  static const double lsWideEm = 0.04; // --ls-wide

  // Ready-made display / body styles
  static const TextStyle displayLg = TextStyle(
    fontFamily: fontDisplay, fontFamilyFallback: displayFallback,
    fontWeight: fwBold, fontSize: fsDisplayLg, height: lhTight,
    letterSpacing: fsDisplayLg * lsTightEm, color: ZaytonaColors.textStrong,
  );
  static const TextStyle title = TextStyle(
    fontFamily: fontDisplay, fontFamilyFallback: displayFallback,
    fontWeight: fwBold, fontSize: fsTitle, height: lhSnug,
    color: ZaytonaColors.textStrong,
  );
  static const TextStyle body = TextStyle(
    fontFamily: fontBody, fontWeight: fwRegular, fontSize: fsBody,
    height: lhNormal, color: ZaytonaColors.textBody,
  );
  static const TextStyle overline = TextStyle(
    fontFamily: fontBody, fontWeight: fwBold, fontSize: fsMicro,
    letterSpacing: fsMicro * lsWideEm, color: ZaytonaColors.textMuted,
  );
}

// ─────────────────────────────────────────────────────────────
// THEME  — wires the tokens into a Material ThemeData.
// ─────────────────────────────────────────────────────────────
class ZaytonaTheme {
  ZaytonaTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: ZaytonaColors.bgApp,
        fontFamily: ZaytonaType.fontBody,
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
          titleLarge: ZaytonaType.title,
          bodyMedium: ZaytonaType.body,
          labelSmall: ZaytonaType.overline,
        ),
      );
}
