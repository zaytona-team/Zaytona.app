// button.dart — ZaytonaButton
//
// Source spec: design_source/.../components/core/Button.jsx
//
// Variants:
//   primary   coral fill, cream text, navy border, pop shadow
//   secondary indigo fill, cream text, navy border, pop shadow
//   mint      mint fill, navy text, navy border, pop shadow
//   outline   transparent, navy text, navy border, NO shadow
//   ghost     transparent, indigo text, transparent border, NO shadow
//   danger    red-tint fill, red-press text, red border, NO shadow
//
// Press behaviour: solid variants (primary/secondary/mint) depress into their
// shadow (translate + shadow off). outline/ghost/danger have no shadow — no
// press transform (matches `if (V.sh === 'none') return` in the source).

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';
import 'pressable.dart';

enum ZaytonaButtonVariant { primary, secondary, mint, outline, ghost, danger }

enum ZaytonaButtonSize { sm, md, lg }

class _VariantStyle {
  const _VariantStyle({
    required this.fill,
    required this.textColor,
    required this.borderColor,
    required this.hasShadow,
  });
  final Color fill;
  final Color textColor;
  final Color borderColor;
  final bool hasShadow;
}

class ZaytonaButton extends StatelessWidget {
  const ZaytonaButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = ZaytonaButtonVariant.primary,
    this.size = ZaytonaButtonSize.md,
    this.iconLeft,
    this.iconRight,
    this.block = false,
    this.disabled = false,
  });

  final String label;
  final VoidCallback? onTap;
  final ZaytonaButtonVariant variant;
  final ZaytonaButtonSize size;
  final Widget? iconLeft;
  final Widget? iconRight;

  /// Stretch to full width.
  final bool block;
  final bool disabled;

  static const _variants = {
    ZaytonaButtonVariant.primary: _VariantStyle(
      fill: ZaytonaColors.red,
      textColor: ZaytonaColors.cream,
      borderColor: ZaytonaColors.navy,
      hasShadow: true,
    ),
    ZaytonaButtonVariant.secondary: _VariantStyle(
      fill: ZaytonaColors.indigo,
      textColor: ZaytonaColors.cream,
      borderColor: ZaytonaColors.navy,
      hasShadow: true,
    ),
    ZaytonaButtonVariant.mint: _VariantStyle(
      fill: ZaytonaColors.mint,
      textColor: ZaytonaColors.navy,
      borderColor: ZaytonaColors.navy,
      hasShadow: true,
    ),
    ZaytonaButtonVariant.outline: _VariantStyle(
      fill: Colors.transparent,
      textColor: ZaytonaColors.navy,
      borderColor: ZaytonaColors.navy,
      hasShadow: false,
    ),
    ZaytonaButtonVariant.ghost: _VariantStyle(
      fill: Colors.transparent,
      textColor: ZaytonaColors.indigo,
      borderColor: Colors.transparent,
      hasShadow: false,
    ),
    ZaytonaButtonVariant.danger: _VariantStyle(
      fill: ZaytonaColors.redTint,
      textColor: ZaytonaColors.redPress,
      borderColor: ZaytonaColors.red,
      hasShadow: false,
    ),
  };

  // h, hPad, fontSize, gap
  static const _sizes = {
    ZaytonaButtonSize.sm: (38.0, 16.0, 14.0, 6.0),
    ZaytonaButtonSize.md: (48.0, 22.0, 16.0, 8.0),
    ZaytonaButtonSize.lg: (56.0, 28.0, 18.0, 10.0),
  };

  @override
  Widget build(BuildContext context) {
    final v = _variants[variant]!;
    final (h, hPad, fontSize, gap) = _sizes[size]!;
    final effectiveOnTap = (disabled || onTap == null) ? null : onTap;

    return Opacity(
      opacity: disabled ? 0.45 : 1.0,
      child: ZaytonaPressable(
        onTap: effectiveOnTap,
        mode: ZaytonaPressMode.pop,
        disabled: disabled,
        // Shadowless variants keep taps but skip the depress movement,
        // matching the source's `if (V.sh === 'none') return`.
        pressEffect: v.hasShadow,
        builder: (context, pressed) {
          final shadow = (v.hasShadow && !pressed)
              ? ZaytonaShadows.shadowPop
              : <BoxShadow>[];

          Widget content = Row(
            mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconLeft != null) ...[
                IconTheme(
                  data: IconThemeData(color: v.textColor, size: fontSize + 2),
                  child: iconLeft!,
                ),
                SizedBox(width: gap),
              ],
              // Flexible (not a bare Text) — this Row has no overflow
              // guard otherwise: a narrow `block: true` button (small
              // card, small device) plus an icon plus a long enough
              // label overflows horizontally with no warning until it's
              // actually hit on a real narrow layout.
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: ZaytonaType.fontDisplay,
                    fontFamilyFallback: const [ZaytonaType.fontBody],
                    fontWeight: ZaytonaType.fwBold,
                    fontSize: fontSize,
                    height: 1.0,
                    color: v.textColor,
                  ),
                ),
              ),
              if (iconRight != null) ...[
                SizedBox(width: gap),
                IconTheme(
                  data: IconThemeData(color: v.textColor, size: fontSize + 2),
                  child: iconRight!,
                ),
              ],
            ],
          );

          return DecoratedBox(
            decoration: BoxDecoration(
              color: v.fill,
              borderRadius: ZaytonaRadius.brPill,
              border: Border.all(
                color: v.borderColor,
                width: ZaytonaShadows.strokeBold,
              ),
              boxShadow: shadow,
            ),
            child: SizedBox(
              height: h,
              width: block ? double.infinity : null,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: content,
              ),
            ),
          );
        },
      ),
    );
  }
}
