// category_chip.dart — ZaytonaCategoryChip
//
// Source spec: Zaytona-Design-System-2/components/patterns/CategoryChip.jsx.
// Pill chip with optional leading category art; selected state fills the
// tone color + navy outline + shadow-pop-sm.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';
import 'pressable.dart';

enum ZaytonaCategoryChipTone { indigo, red, mint, lilac }

class ZaytonaCategoryChip extends StatelessWidget {
  const ZaytonaCategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.tone = ZaytonaCategoryChipTone.indigo,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Optional leading art (e.g. an emoji category glyph or the category star).
  final Widget? icon;

  /// Selected fill color.
  final ZaytonaCategoryChipTone tone;

  Color get _fill => switch (tone) {
        ZaytonaCategoryChipTone.indigo => ZaytonaColors.indigo,
        ZaytonaCategoryChipTone.red => ZaytonaColors.red,
        ZaytonaCategoryChipTone.mint => ZaytonaColors.mint,
        ZaytonaCategoryChipTone.lilac => ZaytonaColors.lilacDeep,
      };

  Color get _selectedInk => switch (tone) {
        ZaytonaCategoryChipTone.mint || ZaytonaCategoryChipTone.lilac =>
          ZaytonaColors.navy,
        _ => ZaytonaColors.cream,
      };

  @override
  Widget build(BuildContext context) {
    return ZaytonaPressable(
      mode: ZaytonaPressMode.scale,
      scaleAmount: 0.96,
      onTap: onTap,
      builder: (context, pressed) => Container(
        height: 38,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: selected ? _fill : ZaytonaColors.surfaceCard,
          border: Border.all(
            color: selected ? ZaytonaColors.borderBold : ZaytonaColors.borderSoft,
            width: 2,
          ),
          borderRadius: ZaytonaRadius.brPill,
          boxShadow: selected ? ZaytonaShadows.shadowPopSm : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 7)],
            Text(
              label,
              style: TextStyle(
                fontFamily: ZaytonaType.fontBody,
                fontWeight: ZaytonaType.fwBold,
                fontSize: 14,
                color: selected ? _selectedInk : ZaytonaColors.textBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
