// trip_card.dart — ZaytonaTripCard
//
// Source spec: Zaytona-Design-System-2/components/patterns/TripCard.jsx —
// a completed shopping-trip history card: buyer, date, count pill, bought
// items (collapsed with a view-more toggle), and an action slot.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';
import 'trip_card_header.dart';
import 'trip_card_toggle.dart';

class ZaytonaTripCard extends StatefulWidget {
  const ZaytonaTripCard({
    super.key,
    this.buyer,
    this.buyerName,
    this.date,
    this.count,
    this.countLabel = 'items',
    this.items = const [],
    this.collapsedCount = 3,
    this.viewMoreLabel = 'View more',
    this.viewLessLabel = 'View less',
    this.action,
  });

  final Widget? buyer;
  final String? buyerName;
  final String? date;
  final int? count;
  final String countLabel;
  final List<String> items;
  final int collapsedCount;
  final String viewMoreLabel;
  final String viewLessLabel;
  final Widget? action;

  @override
  State<ZaytonaTripCard> createState() => _ZaytonaTripCardState();
}

class _ZaytonaTripCardState extends State<ZaytonaTripCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final shown =
        _open ? widget.items : widget.items.take(widget.collapsedCount).toList();
    final total = widget.count ?? widget.items.length;
    final rest = (total - shown.length).clamp(0, total);

    return Container(
      padding: const EdgeInsetsDirectional.all(15),
      decoration: BoxDecoration(
        color: ZaytonaColors.surfaceCard,
        border: Border.all(color: ZaytonaColors.navy, width: ZaytonaShadows.strokeBold),
        borderRadius: ZaytonaRadius.brLg,
        boxShadow: ZaytonaShadows.shadowPop,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TripCardHeader(
            buyer: widget.buyer,
            buyerName: widget.buyerName,
            date: widget.date,
            count: widget.count,
            countLabel: widget.countLabel,
          ),
          if (widget.items.isNotEmpty) ...[
            const SizedBox(height: 13),
            Container(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: ZaytonaColors.surfaceSunken,
                borderRadius: ZaytonaRadius.brMd,
              ),
              child: Column(
                children: [
                  for (var i = 0; i < shown.length; i++)
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        border: i < shown.length - 1
                            ? const Border(
                                bottom: BorderSide(color: ZaytonaColors.borderSoft, width: 1.5),
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check, size: 16, color: ZaytonaColors.successInk),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              shown[i],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: ZaytonaType.fontBody,
                                fontWeight: ZaytonaType.fwMedium,
                                fontSize: 14,
                                color: ZaytonaColors.textBody,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (rest > 0)
                    TripCardToggle(
                      label: '${widget.viewMoreLabel} +$rest',
                      flip: false,
                      onTap: () => setState(() => _open = true),
                    ),
                  if (_open && widget.items.length > widget.collapsedCount)
                    TripCardToggle(
                      label: widget.viewLessLabel,
                      flip: true,
                      onTap: () => setState(() => _open = false),
                    ),
                ],
              ),
            ),
          ],
          if (widget.action != null) ...[
            const SizedBox(height: 13),
            widget.action!,
          ],
        ],
      ),
    );
  }
}
