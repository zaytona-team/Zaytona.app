// icon_button.dart — ZaytonaIconButton
//
// Source spec: design_source/.../components/core/IconButton.jsx
//
// Press behaviour: scale(0.9) for all variants.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';
import 'pressable.dart';

enum ZaytonaIconButtonVariant { soft, solid, outline, ghost }

enum ZaytonaIconButtonTone { indigo, red, mint, navy }

enum ZaytonaIconButtonSize { sm, md, lg }

enum ZaytonaIconButtonShape { circle, square }

class ZaytonaIconButton extends StatelessWidget {
  const ZaytonaIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.variant = ZaytonaIconButtonVariant.soft,
    this.tone = ZaytonaIconButtonTone.indigo,
    this.size = ZaytonaIconButtonSize.md,
    this.shape = ZaytonaIconButtonShape.circle,
    this.semanticLabel,
    this.disabled = false,
  });

  final Widget icon;
  final VoidCallback? onTap;
  final ZaytonaIconButtonVariant variant;
  final ZaytonaIconButtonTone tone;
  final ZaytonaIconButtonSize size;
  final ZaytonaIconButtonShape shape;
  final String? semanticLabel;
  final bool disabled;

  static const _dims = {
    ZaytonaIconButtonSize.sm: 38.0,
    ZaytonaIconButtonSize.md: 44.0,
    ZaytonaIconButtonSize.lg: 52.0,
  };

  // Returns (softFill, softIcon, solidFill, solidIcon) per tone.
  static (Color, Color, Color, Color) _tonePalette(ZaytonaIconButtonTone tone) {
    return switch (tone) {
      ZaytonaIconButtonTone.indigo => (
          ZaytonaColors.indigoTint, ZaytonaColors.indigo,
          ZaytonaColors.indigo,    ZaytonaColors.cream,
        ),
      ZaytonaIconButtonTone.red => (
          ZaytonaColors.redTint,   ZaytonaColors.redPress,
          ZaytonaColors.red,       ZaytonaColors.cream,
        ),
      ZaytonaIconButtonTone.mint => (
          ZaytonaColors.mintTint,  ZaytonaColors.successInk,
          ZaytonaColors.mint,      ZaytonaColors.navy,
        ),
      ZaytonaIconButtonTone.navy => (
          const Color(0x0F0D0050),  ZaytonaColors.navy,  // navy @ 6%
          ZaytonaColors.navy,        ZaytonaColors.cream,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final dim = _dims[size]!;
    final (softFill, softIcon, solidFill, solidIcon) = _tonePalette(tone);
    final radius = shape == ZaytonaIconButtonShape.circle
        ? ZaytonaRadius.brPill
        : ZaytonaRadius.brMd;

    Color fill;
    Color iconColor;
    Color borderColor;

    switch (variant) {
      case ZaytonaIconButtonVariant.soft:
        fill = softFill;
        iconColor = softIcon;
        borderColor = Colors.transparent;
      case ZaytonaIconButtonVariant.solid:
        fill = solidFill;
        iconColor = solidIcon;
        borderColor = ZaytonaColors.navy;
      case ZaytonaIconButtonVariant.outline:
        fill = Colors.transparent;
        iconColor = softIcon;
        borderColor = ZaytonaColors.navy;
      case ZaytonaIconButtonVariant.ghost:
        fill = Colors.transparent;
        iconColor = softIcon;
        borderColor = Colors.transparent;
    }

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Opacity(
        opacity: disabled ? 0.45 : 1.0,
        child: ZaytonaPressable(
          onTap: disabled ? null : onTap,
          mode: ZaytonaPressMode.scale,
          scaleAmount: 0.9,
          disabled: disabled,
          builder: (context, _) => DecoratedBox(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: radius,
              border: Border.all(color: borderColor, width: 2.0),
            ),
            child: SizedBox(
              width: dim,
              height: dim,
              child: Center(
                child: IconTheme(
                  data: IconThemeData(
                    color: iconColor,
                    size: ZaytonaSpacing.iconMd,
                  ),
                  child: icon,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
