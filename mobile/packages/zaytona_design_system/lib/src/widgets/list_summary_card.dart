// list_summary_card.dart — ZaytonaListSummaryCard
//
// Source spec: Zaytona-Design-System-2/components/patterns/ListSummaryCard.jsx
// — an outlined "sticker" card: leading brand seal at the text start, name,
// an "N items · updated" meta line, and an urgent pill at the top end.
// Lists are never "done" — no progress bar, no bought count (that lives in
// trip history). Presentation-only; labels are supplied by the caller.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';
import 'star.dart';

enum ZaytonaListAccent { red, indigo, mint, navy, lilac }

class ZaytonaListSummaryCard extends StatelessWidget {
  const ZaytonaListSummaryCard({
    super.key,
    required this.name,
    this.total = 0,
    this.urgent = 0,
    this.updated,
    this.accent = ZaytonaListAccent.indigo,
    this.leading,
    this.itemsLabel,
    this.urgentLabel,
    this.onTap,
  });

  final String name;
  final int total;
  final int urgent;

  /// Pre-formatted relative-time / updated-date text.
  final String? updated;

  final ZaytonaListAccent accent;

  /// Custom leading visual; defaults to a ZaytonaStar in [accent]'s tone.
  final Widget? leading;

  /// Fully-composed items text (e.g. "5 items" / "٥ عناصر"); the widget
  /// never splices [total] into a caller-supplied word — count/plural/word
  /// order vary per locale, so the caller must pre-format it.
  final String? itemsLabel;

  /// Fully-composed urgent-pill text (e.g. "3 urgent" / "٣ عاجل").
  final String? urgentLabel;

  final VoidCallback? onTap;

  ZaytonaStarTone get _sealTone => switch (accent) {
        ZaytonaListAccent.red => ZaytonaStarTone.red,
        ZaytonaListAccent.indigo => ZaytonaStarTone.indigo,
        ZaytonaListAccent.mint => ZaytonaStarTone.mint,
        ZaytonaListAccent.navy => ZaytonaStarTone.navy,
        ZaytonaListAccent.lilac => ZaytonaStarTone.lilac,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: ZaytonaColors.surfaceCard,
          border: Border.all(color: ZaytonaColors.borderBold, width: ZaytonaShadows.strokeBold),
          borderRadius: ZaytonaRadius.brLg,
          boxShadow: ZaytonaShadows.shadowPop,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            leading ?? ZaytonaStar(size: 44, tone: _sealTone),
            const SizedBox(width: 13),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ZaytonaType.cardTitle,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              itemsLabel ?? '$total items',
                              style: const TextStyle(
                                fontFamily: ZaytonaType.fontBody,
                                fontWeight: ZaytonaType.fwBold,
                                fontSize: 12.5,
                                color: ZaytonaColors.textBody,
                              ),
                            ),
                            if (updated != null) ...[
                              const SizedBox(width: 7),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: ZaytonaColors.ink300,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Flexible(
                                child: Text(
                                  updated!,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: ZaytonaType.fontBody,
                                    fontWeight: ZaytonaType.fwMedium,
                                    fontSize: 12.5,
                                    color: ZaytonaColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (urgent > 0) ...[
                    const SizedBox(width: 9),
                    Container(
                      height: 24,
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ZaytonaColors.red,
                        borderRadius: ZaytonaRadius.brPill,
                      ),
                      child: Text(
                        urgentLabel ?? '$urgent urgent',
                        style: const TextStyle(
                          fontFamily: ZaytonaType.fontDisplay,
                          fontFamilyFallback: [ZaytonaType.fontBody],
                          fontWeight: ZaytonaType.fwBold,
                          fontSize: 12.5,
                          color: ZaytonaColors.cream,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
