// buying_header.dart — ZaytonaBuyingHeader + ZaytonaBuyingFilterChip
//
// Source spec: Zaytona-Design-System-2/components/patterns/BuyingHeader.jsx —
// the navy header band of the shopping-trip screen; the cream item sheet
// rounds over it. Cream ink on navy, mint mode label, done/total meta (always
// LTR digits), and a row of filter chips.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';

class ZaytonaBuyingHeader extends StatelessWidget {
  const ZaytonaBuyingHeader({
    super.key,
    this.name,
    this.modeLabel = 'Buying mode',
    this.done = 0,
    this.total = 0,
    this.leading,
    this.chips,
  });

  final String? name;
  final String modeLabel;
  final int done;
  final int total;

  /// Leading seal (e.g. a mint ZaytonaStar holding a store icon).
  final Widget? leading;

  /// Filter chips row — typically ZaytonaBuyingFilterChip widgets.
  final List<Widget>? chips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(18, 18, 18, 20),
      color: ZaytonaColors.navy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 13)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (name != null)
                      Text(
                        name!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: ZaytonaType.fontDisplay,
                          fontFamilyFallback: [ZaytonaType.fontBody],
                          fontWeight: ZaytonaType.fwBlack,
                          fontSize: 23,
                          height: 1.4,
                          color: ZaytonaColors.cream,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          modeLabel,
                          style: const TextStyle(
                            fontFamily: ZaytonaType.fontBody,
                            fontWeight: ZaytonaType.fwBold,
                            fontSize: 12.5,
                            color: ZaytonaColors.mint,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: ZaytonaColors.cream.withValues(alpha: 0.45),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            '$done/$total',
                            style: TextStyle(
                              fontFamily: ZaytonaType.fontBody,
                              fontWeight: ZaytonaType.fwMedium,
                              fontSize: 12.5,
                              color: ZaytonaColors.cream.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (chips != null && chips!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(children: [
              for (var i = 0; i < chips!.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                chips![i],
              ],
            ]),
          ],
        ],
      ),
    );
  }
}

enum ZaytonaBuyingFilterTone { mint, red }

class ZaytonaBuyingFilterChip extends StatelessWidget {
  const ZaytonaBuyingFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.tone = ZaytonaBuyingFilterTone.mint,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? icon;
  final ZaytonaBuyingFilterTone tone;

  @override
  Widget build(BuildContext context) {
    final fill =
        tone == ZaytonaBuyingFilterTone.red ? ZaytonaColors.red : ZaytonaColors.mint;
    final selectedInk =
        tone == ZaytonaBuyingFilterTone.red ? ZaytonaColors.cream : ZaytonaColors.navy;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? fill : ZaytonaColors.cream.withValues(alpha: 0.1),
          border: Border.all(
            color: selected ? fill : ZaytonaColors.cream.withValues(alpha: 0.22),
            width: 2,
          ),
          borderRadius: ZaytonaRadius.brPill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 7)],
            Text(
              label,
              style: TextStyle(
                fontFamily: ZaytonaType.fontDisplay,
                fontFamilyFallback: [ZaytonaType.fontBody],
                fontWeight: ZaytonaType.fwBold,
                fontSize: 13.5,
                color: selected ? selectedInk : ZaytonaColors.cream,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
