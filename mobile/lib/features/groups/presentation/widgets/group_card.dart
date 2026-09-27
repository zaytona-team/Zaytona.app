import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/group_icon.dart';
import '../../domain/entities/group_member.dart';
import 'group_tone.dart';

// Group header card (prototype screens-main.jsx 30-50).
class GroupCard extends StatelessWidget {
  final Group group;
  final List<GroupMember> members;

  const GroupCard({super.key, required this.group, required this.members});

  Color get _toneTint => switch (group.tone) {
    ZaytonaStarTone.red => ZaytonaColors.redTint,
    ZaytonaStarTone.mint => ZaytonaColors.mintTint,
    ZaytonaStarTone.indigo => ZaytonaColors.indigoTint,
    _ => ZaytonaColors.lilac,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_toneTint, ZaytonaColors.surfaceCard],
          stops: const [0, 0.72],
        ),
        border: Border.all(
          color: ZaytonaColors.borderBold,
          width: ZaytonaShadows.strokeBold,
        ),
        borderRadius: BorderRadius.circular(ZaytonaRadius.lg),
        boxShadow: ZaytonaShadows.shadowPop,
      ),
      child: Stack(
        children: [
          // decorative oversized faded star (prototype: opacity .12)
          PositionedDirectional(
            end: -70,
            bottom: -96,
            child: Opacity(
              opacity: 0.12,
              child: ZaytonaStar(size: 230, tone: group.tone, halo: null),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: ZaytonaSpacing.space5, vertical: ZaytonaSpacing.space4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _roleBadge(l10n),
                      const SizedBox(height: ZaytonaSpacing.space2),
                      Text(
                        group.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: ZaytonaType.fontDisplay,
                          fontFamilyFallback: const [ZaytonaType.fontBody],
                          fontWeight: ZaytonaType.fwBlack,
                          fontSize: 25,
                          height: 1.05,
                          color: ZaytonaColors.navy,
                        ),
                      ),
                      const SizedBox(height: ZaytonaSpacing.space3),
                      _membersLine(l10n, members),
                    ],
                  ),
                ),
                const SizedBox(width: ZaytonaSpacing.space4),
                ZaytonaStar(
                  size: 74,
                  tone: group.tone,
                  rotate: -8,
                  child: Icon(
                    GroupIconX.fromApiValue(group.icon).iconData,
                    size: 34,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleBadge(AppLocalizations l10n) {
    if (group.isPrivate) {
      return ZaytonaBadge(
        label: l10n.privateBadge,
        tone: ZaytonaBadgeTone.lilac,
        variant: ZaytonaBadgeVariant.solid,
        size: ZaytonaBadgeSize.sm,
      );
    }
    return group.isAdmin
        ? ZaytonaBadge(
            label: l10n.adminBadge,
            tone: ZaytonaBadgeTone.mint,
            variant: ZaytonaBadgeVariant.solid,
            size: ZaytonaBadgeSize.sm,
          )
        : ZaytonaBadge(
            label: l10n.memberBadge,
            tone: ZaytonaBadgeTone.neutral,
            variant: ZaytonaBadgeVariant.soft,
            size: ZaytonaBadgeSize.sm,
          );
  }

  Widget _membersLine(AppLocalizations l10n, List<GroupMember> members) {
    if (group.isPrivate) {
      return Row(
        children: [
          const Icon(
            Icons.person_outline,
            size: 16,
            color: ZaytonaColors.textMuted,
          ),
          const SizedBox(width: ZaytonaSpacing.space2),
          Text(l10n.privateSpaceLine, style: ZaytonaType.meta),
        ],
      );
    }
    return ZaytonaAvatarGroup(
      names: members.map((m) => m.name).toList(),
      avatarUrls: members.map((m) => m.avatar).toList(),
      size: 32,
      max: 4,
    );
  }
}
