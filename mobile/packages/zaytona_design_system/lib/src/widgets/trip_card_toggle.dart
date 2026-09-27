// trip_card_toggle.dart — the "view more / view less" row used inside
// ZaytonaTripCard's bought-items list. Split out of trip_card.dart to stay
// under the 180-line file cap.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';

class TripCardToggle extends StatelessWidget {
  const TripCardToggle({
    super.key,
    required this.label,
    required this.flip,
    required this.onTap,
  });

  final String label;
  final bool flip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.only(top: 10, bottom: 9),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: ZaytonaColors.borderSoft, width: 1.5)),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: ZaytonaType.fontDisplay,
                fontFamilyFallback: [ZaytonaType.fontBody],
                fontWeight: ZaytonaType.fwBold,
                fontSize: 13,
                color: ZaytonaColors.indigo,
              ),
            ),
            const SizedBox(width: 6),
            AnimatedRotation(
              turns: flip ? 0.5 : 0,
              duration: const Duration(milliseconds: 150),
              child: const Icon(Icons.keyboard_arrow_down, size: 15, color: ZaytonaColors.indigo),
            ),
          ],
        ),
      ),
    );
  }
}
