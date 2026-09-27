// card.dart — ZaytonaCard
//
// Source spec: design_source/.../components/core/Card.jsx
//
// The brand's pink-surface container. Never pure white.
//
// Variants:
//   plain   surface-card fill + soft pink hairline (default)
//   pop     navy border + hard-offset pop shadow
//   sunken  surface-sunken fill (insets, nested sections)
//   brand   coral fill + navy border + pop shadow + cream text
//
// Tone overrides the fill color (red/mint/indigo/lilac tints) while keeping
// the variant's border/shadow rules.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';

enum ZaytonaCardVariant { plain, pop, sunken, brand }

enum ZaytonaCardTone { red, mint, indigo, lilac }

enum ZaytonaCardPadding { none, sm, md, lg }

enum ZaytonaCardRadius { md, lg, xl }

class ZaytonaCard extends StatelessWidget {
  const ZaytonaCard({
    super.key,
    required this.child,
    this.variant = ZaytonaCardVariant.plain,
    this.tone,
    this.padding = ZaytonaCardPadding.md,
    this.radius = ZaytonaCardRadius.lg,
    this.onTap,
  });

  final Widget child;
  final ZaytonaCardVariant variant;

  /// Overrides the fill with a tinted color while keeping border/shadow rules.
  final ZaytonaCardTone? tone;

  final ZaytonaCardPadding padding;
  final ZaytonaCardRadius radius;

  /// If provided, wraps the card in an InkWell.
  final VoidCallback? onTap;

  static const _toneFills = {
    ZaytonaCardTone.red:    ZaytonaColors.redTint,
    ZaytonaCardTone.mint:   ZaytonaColors.mintTint,
    ZaytonaCardTone.indigo: ZaytonaColors.indigoTint,
    ZaytonaCardTone.lilac:  ZaytonaColors.lilac,
  };

  static const _pads = {
    ZaytonaCardPadding.none: 0.0,
    ZaytonaCardPadding.sm:   12.0,
    ZaytonaCardPadding.md:   18.0,
    ZaytonaCardPadding.lg:   26.0,
  };

  static const _radii = {
    ZaytonaCardRadius.md: ZaytonaRadius.md,
    ZaytonaCardRadius.lg: ZaytonaRadius.lg,
    ZaytonaCardRadius.xl: ZaytonaRadius.xl,
  };

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(_radii[radius]!);
    final pad = _pads[padding]!;

    // Fill
    Color fill = tone != null
        ? _toneFills[tone]!
        : switch (variant) {
            ZaytonaCardVariant.plain   => ZaytonaColors.surfaceCard,
            ZaytonaCardVariant.pop     => ZaytonaColors.surfaceCard,
            ZaytonaCardVariant.sunken  => ZaytonaColors.surfaceSunken,
            ZaytonaCardVariant.brand   => ZaytonaColors.red,
          };

    // Border
    Border border = switch (variant) {
      ZaytonaCardVariant.plain  => Border.all(color: ZaytonaColors.borderSoft, width: 1.5),
      ZaytonaCardVariant.pop    => Border.all(color: ZaytonaColors.navy, width: ZaytonaShadows.strokeBold),
      ZaytonaCardVariant.sunken => Border.all(color: Colors.transparent, width: 1.5),
      ZaytonaCardVariant.brand  => Border.all(color: ZaytonaColors.navy, width: ZaytonaShadows.strokeBold),
    };

    // Shadow
    List<BoxShadow> shadow = switch (variant) {
      ZaytonaCardVariant.pop   => ZaytonaShadows.shadowPop,
      ZaytonaCardVariant.brand => ZaytonaShadows.shadowPop,
      _                        => const [],
    };

    // Text color
    Color textColor = variant == ZaytonaCardVariant.brand
        ? ZaytonaColors.cream
        : ZaytonaColors.textBody;

    Widget content = DefaultTextStyle.merge(
      style: TextStyle(color: textColor),
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: child,
      ),
    );

    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: br,
        border: border,
        boxShadow: shadow,
      ),
      child: content,
    );

    return Material(
      color: Colors.transparent,
      borderRadius: br,
      child: onTap != null
          ? InkWell(
              borderRadius: br,
              onTap: onTap,
              child: decorated,
            )
          : decorated,
    );
  }
}
