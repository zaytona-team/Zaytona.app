// fab.dart — ZaytonaFab
//
// Source spec: Zaytona-Design-System-2/components/patterns/FAB.jsx + .d.ts
//
// Physically pinned bottom-right in BOTH directions (not RTL-mirrored) — the
// primary "add" action for the app chrome. Optional label makes it extended
// (pill); icon-only otherwise. Presses translate into the pop shadow, same
// motion as ZaytonaButton's solid variants.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';
import 'pressable.dart';

enum ZaytonaFabTone { red, indigo }

class ZaytonaFab extends StatelessWidget {
  const ZaytonaFab({
    super.key,
    required this.icon,
    this.label,
    this.onTap,
    this.tone = ZaytonaFabTone.red,
  });

  final Widget icon;

  /// When present the FAB becomes extended (pill with label).
  final String? label;

  final VoidCallback? onTap;
  final ZaytonaFabTone tone;

  @override
  Widget build(BuildContext context) {
    final fill = tone == ZaytonaFabTone.red
        ? ZaytonaColors.red
        : ZaytonaColors.indigo;
    final extended = label != null;

    // Physically pinned: wrap in Directionality.ltr so the pill/icon layout
    // never mirrors in RTL, per the FAB exception in the handoff table.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ZaytonaPressable(
        onTap: onTap,
        mode: ZaytonaPressMode.pop,
        builder: (context, pressed) {
          final shadow =
              pressed ? const <BoxShadow>[] : ZaytonaShadows.shadowPop;
          return DecoratedBox(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: ZaytonaRadius.brPill,
              border: Border.all(
                color: ZaytonaColors.navy,
                width: ZaytonaShadows.strokeBold,
              ),
              boxShadow: shadow,
            ),
            child: SizedBox(
              height: 54,
              width: extended ? null : 54,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: extended ? 22 : 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconTheme(
                      data: const IconThemeData(
                        color: ZaytonaColors.cream,
                        size: ZaytonaSpacing.iconMd,
                      ),
                      child: icon,
                    ),
                    if (extended) ...[
                      const SizedBox(width: 8),
                      Text(
                        label!,
                        style: const TextStyle(
                          fontFamily: ZaytonaType.fontDisplay,
                          fontFamilyFallback: [ZaytonaType.fontBody],
                          fontWeight: ZaytonaType.fwBold,
                          fontSize: ZaytonaType.fsBody,
                          color: ZaytonaColors.cream,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
