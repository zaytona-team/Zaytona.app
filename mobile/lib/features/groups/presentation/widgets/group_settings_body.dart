import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/groups/group_settings_cubit.dart';
import 'confirm_danger_dialog.dart';
import 'group_settings_danger_card.dart';
import 'group_settings_identity_section.dart';
import 'group_settings_invite_code_card.dart';
import 'group_settings_member_row.dart';

class GroupSettingsBody extends StatelessWidget {
  final GroupSettingsLoaded state;
  final String? currentUserId;

  const GroupSettingsBody({
    super.key,
    required this.state,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final group = state.group;
    final isAdmin = group.isAdmin;
    return ListView(
      padding: const EdgeInsets.fromLTRB(ZaytonaSpacing.space5, ZaytonaSpacing.space2, ZaytonaSpacing.space5, ZaytonaSpacing.space6),
      children: [
        Row(
          children: [
            ZaytonaIconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              tone: ZaytonaIconButtonTone.navy,
              variant: ZaytonaIconButtonVariant.soft,
              size: ZaytonaIconButtonSize.sm,
              semanticLabel: 'Back',
              onTap: () => context.pop(),
            ),
            const SizedBox(width: ZaytonaSpacing.space3),
            Text(l10n.groupSettingsTitle, style: ZaytonaType.screenTitle),
          ],
        ),
        const SizedBox(height: ZaytonaSpacing.space6),
        _sectionLabel(l10n.groupIdentitySection),
        GroupIdentitySection(
          group: group,
          isAdmin: isAdmin,
          actionInFlight: state.actionInFlight,
          onSave: (name) => _saveName(context, l10n, name),
          onIconSelected: (icon) =>
              context.read<GroupSettingsCubit>().updateIdentity(icon: icon),
        ),
        if (group.isPrivate) ...[
          const SizedBox(height: ZaytonaSpacing.space4),
          ZaytonaBanner(
            title: l10n.privateGroupBannerTitle,
            body: l10n.privateGroupBannerBody,
            icon: const Icon(Icons.lock_outline),
          ),
        ] else ...[
          const SizedBox(height: ZaytonaSpacing.space6),
          _sectionLabel(l10n.membersSection),
          for (final member in state.members)
            GroupMemberRow(
              member: member,
              isAdmin: isAdmin,
              isSelf: currentUserId != null && member.userId == currentUserId,
              actionInFlight: state.actionInFlight,
              onMakeAdmin: () => confirmDangerDialog(
                context,
                l10n,
                title: l10n.transferAdminConfirmTitle,
                body: l10n.transferAdminConfirmBody(member.name),
                confirmLabel: l10n.confirmAction,
                onConfirm: () => context
                    .read<GroupSettingsCubit>()
                    .transferAdmin(member.userId),
              ),
              onRemove: () => confirmDangerDialog(
                context,
                l10n,
                title: l10n.removeMemberConfirmTitle(member.name),
                body: l10n.removeMemberConfirmBody,
                confirmLabel: l10n.deleteAction,
                onConfirm: () => context
                    .read<GroupSettingsCubit>()
                    .removeMember(member.userId),
              ),
            ),
          const SizedBox(height: ZaytonaSpacing.space6),
          _sectionLabel(l10n.inviteCodeLabel),
          GroupInviteCodeCard(inviteCode: group.inviteCode ?? ''),
          const SizedBox(height: ZaytonaSpacing.space6),
          _sectionLabel(l10n.dangerZoneSection, danger: true),
          if (isAdmin)
            GroupDangerCard(
              title: l10n.deleteGroupTitle,
              body: l10n.deleteGroupBody,
              buttonLabel: l10n.deleteGroupTitle,
              buttonIcon: Icons.delete_outline,
              disabled: state.actionInFlight,
              onPressed: () => confirmDangerDialog(
                context,
                l10n,
                title: l10n.deleteGroupConfirmTitle,
                body: l10n.deleteGroupConfirmBody,
                confirmLabel: l10n.deleteAction,
                onConfirm: () =>
                    context.read<GroupSettingsCubit>().deleteGroup(),
              ),
            )
          else
            GroupDangerCard(
              title: l10n.leaveGroupTitle,
              body: l10n.leaveGroupBody,
              buttonLabel: l10n.leaveGroupTitle,
              buttonIcon: Icons.logout,
              disabled: state.actionInFlight,
              onPressed: () => confirmDangerDialog(
                context,
                l10n,
                title: l10n.leaveGroupConfirmTitle,
                body: l10n.leaveGroupConfirmBody,
                confirmLabel: l10n.leaveAction,
                onConfirm: () => context.read<GroupSettingsCubit>().leave(),
              ),
            ),
        ],
      ],
    );
  }

  Widget _sectionLabel(String text, {bool danger = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ZaytonaSpacing.space3),
      child: Text(
        text,
        style: ZaytonaType.overline.copyWith(
          color: danger ? ZaytonaColors.redPress : null,
        ),
      ),
    );
  }

  Future<void> _saveName(
    BuildContext context,
    AppLocalizations l10n,
    String name,
  ) async {
    final cubit = context.read<GroupSettingsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    await cubit.updateIdentity(name: name);
    final after = cubit.state;
    if (after is GroupSettingsLoaded && after.actionError == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.changesSaved)));
    }
  }
}
