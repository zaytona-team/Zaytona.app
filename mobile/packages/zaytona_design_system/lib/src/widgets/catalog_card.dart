// catalog_card.dart — ZaytonaCatalogCard
//
// Source spec: Zaytona-Design-System-2/components/patterns/CatalogItemCard.jsx
// and its usage in ui_kits/zaytona-app/screens-flows.jsx (CatalogPicker,
// 2-up grid). The two-up product card used in the add-item catalog: a
// tinted image block (category seal), name, brand/unit line, a centred
// qty stepper slot, and a full-width add action slot.
//
// Presentation-only: the parent owns qty and the transient "added" flash
// (setTimeout(...,1200) in the prototype) and passes them in as props.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';
import 'pressable.dart';

enum ZaytonaCatalogTone { red, indigo, mint, lilac }

class ZaytonaCatalogCard extends StatelessWidget {
  const ZaytonaCatalogCard({
    super.key,
    required this.name,
    required this.seal,
    required this.quantity,
    required this.action,
    this.subtitleText,
    this.tone = ZaytonaCatalogTone.indigo,
    this.added = false,
    this.onTap,
  });

  /// Product name (bold, single-line, ellipsized).
  final String name;

  /// Brand-or-unit caption line under the name.
  final String? subtitleText;

  /// Visual for the tinted image block (e.g. the category seal art).
  final Widget seal;

  /// Tint of the image block.
  final ZaytonaCatalogTone tone;

  /// Highlights the card border in mint once the item has been added.
  final bool added;

  /// Centred qty stepper slot.
  final Widget quantity;

  /// Full-width add-action slot.
  final Widget action;

  /// Tap on the card body (image/name/subtitle) — e.g. open a prefilled
  /// manual-entry sheet. The quantity and action slots own their own taps.
  final VoidCallback? onTap;

  Color get _tint => switch (tone) {
        ZaytonaCatalogTone.red => ZaytonaColors.redTint,
        ZaytonaCatalogTone.indigo => ZaytonaColors.indigoTint,
        ZaytonaCatalogTone.mint => ZaytonaColors.mintTint,
        ZaytonaCatalogTone.lilac => ZaytonaColors.lilac,
      };

  @override
  Widget build(BuildContext context) {
    return ZaytonaPressable(
      mode: ZaytonaPressMode.scale,
      scaleAmount: 0.98,
      onTap: onTap,
      builder: (context, pressed) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: ZaytonaColors.surfaceCard,
          border: Border.all(
            color: added ? ZaytonaColors.mint : ZaytonaColors.borderSoft,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(ZaytonaRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 86,
              alignment: Alignment.center,
              color: _tint,
              child: seal,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: ZaytonaType.fontDisplay,
                      fontFamilyFallback: const [ZaytonaType.fontBody],
                      fontWeight: ZaytonaType.fwBlack,
                      fontSize: 14.5,
                      height: 1.35,
                      color: ZaytonaColors.navy,
                    ),
                  ),
                  if (subtitleText != null)
                    Text(
                      subtitleText!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: ZaytonaType.fontBody,
                        fontWeight: ZaytonaType.fwBold,
                        fontSize: 11.5,
                        height: 1.5,
                        color: ZaytonaColors.textMuted,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Center(child: quantity),
                  const SizedBox(height: 6),
                  action,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
