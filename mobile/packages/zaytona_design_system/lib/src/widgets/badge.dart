// badge.dart — ZaytonaBadge
//
// Source spec: design_source/.../components/core/Badge.jsx
//
// Small status/count pill. Not a notification badge — use for labels and
// state indicators (urgent, in-stock, role chips, etc.).

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';

enum ZaytonaBadgeTone { neutral, red, mint, indigo, lilac }

enum ZaytonaBadgeVariant { soft, solid, outline }

enum ZaytonaBadgeSize { sm, md }

class ZaytonaBadge extends StatelessWidget {
  const ZaytonaBadge({
    super.key,
    required this.label,
    this.tone = ZaytonaBadgeTone.neutral,
    this.variant = ZaytonaBadgeVariant.soft,
    this.size = ZaytonaBadgeSize.md,
    this.dot = false,
  });

  final String label;
  final ZaytonaBadgeTone tone;
  final ZaytonaBadgeVariant variant;
  final ZaytonaBadgeSize size;

  /// Prepends a 6 px filled circle in the current text color.
  final bool dot;

  // Returns (softFill, softText, solidFill, solidText) per tone.
  static (Color, Color, Color, Color) _palette(ZaytonaBadgeTone tone) {
    return switch (tone) {
      ZaytonaBadgeTone.neutral => (
          const Color(0x0F0D0050), ZaytonaColors.ink700,
          ZaytonaColors.navy,      ZaytonaColors.cream,
        ),
      ZaytonaBadgeTone.red => (
          ZaytonaColors.redTint,   ZaytonaColors.redPress,
          ZaytonaColors.red,       ZaytonaColors.cream,
        ),
      ZaytonaBadgeTone.mint => (
          ZaytonaColors.mintTint,  ZaytonaColors.successInk,
          ZaytonaColors.mint,      ZaytonaColors.navy,
        ),
      ZaytonaBadgeTone.indigo => (
          ZaytonaColors.indigoTint, ZaytonaColors.indigoPress,
          ZaytonaColors.indigo,     ZaytonaColors.cream,
        ),
      ZaytonaBadgeTone.lilac => (
          ZaytonaColors.lilac,      ZaytonaColors.navy,
          ZaytonaColors.lilacDeep,  ZaytonaColors.navy,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (softFill, softText, solidFill, solidText) = _palette(tone);

    final Color fill;
    final Color textColor;
    final Color borderColor;

    switch (variant) {
      case ZaytonaBadgeVariant.soft:
        fill = softFill;
        textColor = softText;
        borderColor = Colors.transparent;
      case ZaytonaBadgeVariant.solid:
        fill = solidFill;
        textColor = solidText;
        borderColor = Colors.transparent;
      case ZaytonaBadgeVariant.outline:
        fill = Colors.transparent;
        textColor = softText;
        borderColor = softText;
    }

    final double fontSize;
    final double height;
    final EdgeInsets padding;

    if (size == ZaytonaBadgeSize.sm) {
      fontSize = ZaytonaType.fsMicro;  // 11
      height = 20;
      padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 2);
    } else {
      fontSize = ZaytonaType.fsCaption; // 13
      height = 24;
      padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 3);
    }

    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: ZaytonaRadius.brPill,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: ZaytonaType.fontBody,
              fontWeight: ZaytonaType.fwBold,
              fontSize: fontSize,
              height: 1.0,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
