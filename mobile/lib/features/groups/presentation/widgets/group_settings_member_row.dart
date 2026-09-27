import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../items/presentation/widgets/list_menu_row.dart';
import '../../domain/entities/group_member.dart';

class GroupMemberRow extends StatelessWidget {
  final GroupMember member;
  final bool isAdmin;
  final bool isSelf;
  final bool actionInFlight;
  final VoidCallback onMakeAdmin;
  final VoidCallback onRemove;

  GroupMemberRow({
    super.key,
    required this.member,
    required this.isAdmin,
    required this.isSelf,
    required this.actionInFlight,
    required this.onMakeAdmin,
    required this.onRemove,
  });

  final _menuButtonKey = GlobalKey();

  void _showMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showZaytonaAnchoredMenu(
      context,
      anchorKey: _menuButtonKey,
      width: 200,
      cardBuilder: (menuContext) {
        final close = ZaytonaMenuCloseScope.of(menuContext);
        return ZaytonaMenuCard(
          children: [
            ListMenuRow(
              icon: Icons.admin_panel_settings_outlined,
              label: l10n.makeAdminAction,
              disabled: actionInFlight,
              onTap: () {
                close();
                onMakeAdmin();
              },
            ),
            ListMenuRow(
              icon: Icons.person_remove_outlined,
              label: l10n.removeMemberAction,
              tone: ListMenuRowTone.red,
              disabled: actionInFlight,
              onTap: () {
                close();
                onRemove();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: ZaytonaSpacing.space2),
      padding: const EdgeInsets.symmetric(horizontal: ZaytonaSpacing.space4, vertical: ZaytonaSpacing.space3),
      decoration: BoxDecoration(
        color: ZaytonaColors.surfaceCard,
        border: Border.all(color: ZaytonaColors.borderSoft, width: 1.5),
        borderRadius: BorderRadius.circular(ZaytonaRadius.md),
      ),
      child: Row(
        children: [
          ZaytonaAvatar(name: member.name, src: member.avatar, size: 40),
          const SizedBox(width: ZaytonaSpacing.space3),
          Expanded(
            child: Text(
              isSelf ? '${member.name} · ${l10n.youSuffix}' : member.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ZaytonaType.cardTitle,
            ),
          ),
          ZaytonaBadge(
            label: member.isAdmin ? l10n.adminBadge : l10n.memberBadge,
            tone: member.isAdmin
                ? ZaytonaBadgeTone.mint
                : ZaytonaBadgeTone.neutral,
            variant: member.isAdmin
                ? ZaytonaBadgeVariant.solid
                : ZaytonaBadgeVariant.soft,
            size: ZaytonaBadgeSize.sm,
          ),
          if (isAdmin && !member.isAdmin)
            ZaytonaIconButton(
              key: _menuButtonKey,
              icon: const Icon(Icons.more_horiz),
              tone: ZaytonaIconButtonTone.navy,
              variant: ZaytonaIconButtonVariant.soft,
              size: ZaytonaIconButtonSize.sm,
              semanticLabel: l10n.memberActionsLabel,
              disabled: actionInFlight,
              onTap: () => _showMenu(context),
            ),
        ],
      ),
    );
  }
}
