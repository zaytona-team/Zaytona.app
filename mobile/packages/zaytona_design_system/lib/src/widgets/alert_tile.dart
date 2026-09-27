// alert_tile.dart — ZaytonaAlertTile
//
// Source spec: Zaytona-Design-System-2/components/patterns/AlertWidget.jsx —
// the compact tinted action row used by the trip-alerts popup: seal, title,
// a supporting line (or the chosen member once picked), and one small action.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';

enum ZaytonaAlertTone { red, indigo, mint, lilac }

extension ZaytonaAlertToneInk on ZaytonaAlertTone {
  /// Icon/leading ink color — navy on every tint, so the leading icon
  /// reads the same across all alert cards regardless of tone.
  Color get ink => ZaytonaColors.navy;
}

class ZaytonaAlertTile extends StatelessWidget {
  const ZaytonaAlertTile({
    super.key,
    this.title,
    this.body,
    this.leading,
    this.tone = ZaytonaAlertTone.red,
    this.selected,
    this.action,
  });

  final String? title;

  /// Supporting line, shown when nothing is selected yet.
  final String? body;

  /// Leading seal (e.g. a ZaytonaStar holding an icon).
  final Widget? leading;

  final ZaytonaAlertTone tone;

  /// Replaces [body] once a member is picked — e.g. avatar + name.
  final Widget? selected;

  /// Trailing control (a small ZaytonaButton or a status ZaytonaBadge).
  final Widget? action;

  Color get _tint => switch (tone) {
        ZaytonaAlertTone.red => ZaytonaColors.redTint,
        ZaytonaAlertTone.indigo => ZaytonaColors.indigoTint,
        ZaytonaAlertTone.mint => ZaytonaColors.mintTint,
        ZaytonaAlertTone.lilac => ZaytonaColors.lilac,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _tint,
        border: Border.all(color: ZaytonaColors.navy, width: ZaytonaShadows.strokeBold),
        borderRadius: ZaytonaRadius.brLg,
        boxShadow: ZaytonaShadows.shadowPop,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: const TextStyle(
                      fontFamily: ZaytonaType.fontDisplay,
                      fontFamilyFallback: [ZaytonaType.fontBody],
                      fontWeight: ZaytonaType.fwBlack,
                      fontSize: 15.5,
                      height: 1.3,
                      color: ZaytonaColors.navy,
                    ),
                  ),
                if (selected != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 4),
                    child: selected,
                  )
                else if (body != null)
                  Text(
                    body!,
                    style: const TextStyle(
                      fontFamily: ZaytonaType.fontBody,
                      fontWeight: ZaytonaType.fwMedium,
                      fontSize: 12,
                      color: ZaytonaColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          if (action != null) ...[const SizedBox(width: 8), action!],
        ],
      ),
    );
  }
}
