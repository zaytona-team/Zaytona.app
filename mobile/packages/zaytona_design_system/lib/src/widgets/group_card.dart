// group_card.dart — ZaytonaGroupCard
//
// Source spec: Zaytona-Design-System-2/components/patterns/FamilyCard.jsx + .d.ts
//
// Group identity card on the group-home screen. Flat tinted surface, navy
// outline + hard pop shadow, a seal watermark on the end side, role badge,
// group name, and a members slot (typically a ZaytonaAvatarGroup). Purely
// presentational — badge/members/leading are caller-supplied slots so this
// stays state- and i18n-agnostic.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';
import 'star.dart';

enum ZaytonaGroupCardTone { red, indigo, mint, lilac }

class ZaytonaGroupCard extends StatelessWidget {
  const ZaytonaGroupCard({
    super.key,
    required this.name,
    this.badge,
    this.meta,
    this.members,
    this.leading,
    this.tone = ZaytonaGroupCardTone.lilac,
    this.footer,
    this.onTitleTap,
  });

  final String name;

  /// Role/privacy pill rendered above the name (e.g. a ZaytonaBadge).
  final Widget? badge;

  /// Fallback meta line, shown only when [members] is null.
  final String? meta;

  /// Member avatars row (e.g. a ZaytonaAvatarGroup).
  final Widget? members;

  /// Group seal shown at the end of the card.
  final Widget? leading;

  final ZaytonaGroupCardTone tone;

  /// Rendered under the card — typically the Lists/Recipes segmented control.
  final Widget? footer;

  final VoidCallback? onTitleTap;

  static const _tints = {
    ZaytonaGroupCardTone.red: ZaytonaColors.redTint,
    ZaytonaGroupCardTone.indigo: ZaytonaColors.indigoTint,
    ZaytonaGroupCardTone.mint: ZaytonaColors.mintTint,
    ZaytonaGroupCardTone.lilac: ZaytonaColors.lilac,
  };

  static const _sealTones = {
    ZaytonaGroupCardTone.red: ZaytonaStarTone.red,
    ZaytonaGroupCardTone.indigo: ZaytonaStarTone.indigo,
    ZaytonaGroupCardTone.mint: ZaytonaStarTone.mint,
    ZaytonaGroupCardTone.lilac: ZaytonaStarTone.lilac,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
          decoration: BoxDecoration(
            color: _tints[tone],
            border: Border.all(
              color: ZaytonaColors.navy,
              width: ZaytonaShadows.strokeBold,
            ),
            borderRadius: ZaytonaRadius.brLg,
            boxShadow: ZaytonaShadows.shadowPop,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (badge != null) ...[
                      badge!,
                      const SizedBox(height: 7),
                    ],
                    GestureDetector(
                      onTap: onTitleTap,
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: ZaytonaType.fontDisplay,
                          fontFamilyFallback: [ZaytonaType.fontBody],
                          fontWeight: ZaytonaType.fwBlack,
                          fontSize: 25,
                          height: ZaytonaType.lhSnug,
                          color: ZaytonaColors.navy,
                        ),
                      ),
                    ),
                    if (members != null) ...[
                      const SizedBox(height: 12),
                      members!,
                    ] else if (meta != null) ...[
                      const SizedBox(height: 10),
                      Text(meta!, style: ZaytonaType.meta),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 14),
              leading ?? ZaytonaStar(size: 68, tone: _sealTones[tone]!, rotate: -8),
            ],
          ),
        ),
        if (footer != null) ...[
          const SizedBox(height: 14),
          footer!,
        ],
      ],
    );
  }
}
