// trip_card_header.dart — the buyer/date/count-pill header row used inside
// ZaytonaTripCard. Split out of trip_card.dart to stay under the 180-line
// file cap.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';

class TripCardHeader extends StatelessWidget {
  const TripCardHeader({
    super.key,
    this.buyer,
    this.buyerName,
    this.date,
    this.count,
    this.countLabel = 'items',
  });

  final Widget? buyer;
  final String? buyerName;
  final String? date;
  final int? count;
  final String countLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (buyer != null) ...[buyer!, const SizedBox(width: 12)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (buyerName != null)
                Text(
                  buyerName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: ZaytonaType.fontDisplay,
                    fontFamilyFallback: [ZaytonaType.fontBody],
                    fontWeight: ZaytonaType.fwBlack,
                    fontSize: 16.5,
                    height: 1.3,
                    color: ZaytonaColors.navy,
                  ),
                ),
              if (date != null)
                Text(
                  date!,
                  style: const TextStyle(
                    fontFamily: ZaytonaType.fontBody,
                    fontWeight: ZaytonaType.fwMedium,
                    fontSize: 12.5,
                    color: ZaytonaColors.textMuted,
                  ),
                ),
            ],
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            height: 24,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ZaytonaColors.mint,
              borderRadius: ZaytonaRadius.brPill,
            ),
            child: Text(
              '$count $countLabel',
              style: const TextStyle(
                fontFamily: ZaytonaType.fontDisplay,
                fontFamilyFallback: [ZaytonaType.fontBody],
                fontWeight: ZaytonaType.fwBold,
                fontSize: 12.5,
                color: ZaytonaColors.navy,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
