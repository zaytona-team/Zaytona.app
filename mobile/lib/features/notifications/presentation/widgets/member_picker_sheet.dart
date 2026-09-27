import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../groups/domain/entities/group_member.dart';

/// Avatar + name inline, shown by [ZaytonaAlertTile.selected] once a
/// member has been picked for assign/remind.
class ChosenMember extends StatelessWidget {
  final GroupMember member;

  const ChosenMember({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ZaytonaAvatar(name: member.name, src: member.avatar, size: 22),
        const SizedBox(width: ZaytonaSpacing.space2),
        Text(
          member.name,
          style: const TextStyle(
            fontFamily: ZaytonaType.fontBody,
            fontWeight: ZaytonaType.fwBold,
            fontSize: 12,
            color: ZaytonaColors.successInk,
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet listing the group's members; tap returns the pick.
class MemberPickerSheet extends StatelessWidget {
  final String title;
  final List<GroupMember> members;
  final String groupId;

  const MemberPickerSheet({
    super.key,
    required this.title,
    required this.members,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(ZaytonaSpacing.space4, ZaytonaSpacing.space1, ZaytonaSpacing.space4, ZaytonaSpacing.space6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: ZaytonaType.sheetTitle),
          const SizedBox(height: ZaytonaSpacing.space4),
          if (members.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: ZaytonaSpacing.space2),
              child: ZaytonaEmptyState(
                icon: const Icon(Icons.person_add_alt, size: 32),
                title: l10n.noMembersToNotifyTitle,
                body: l10n.noMembersToNotifyBody,
                ctaLabel: l10n.inviteMembersTitle,
                onCta: () {
                  Navigator.of(context).pop();
                  context.push('/groups/$groupId/invite');
                },
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: members.length,
                separatorBuilder: (_, _) => const SizedBox(height: ZaytonaSpacing.space2),
                itemBuilder: (context, index) {
                  final member = members[index];
                  return ZaytonaCard(
                    padding: ZaytonaCardPadding.sm,
                    onTap: () => Navigator.of(context).pop(member),
                    child: Row(
                      children: [
                        ZaytonaAvatar(
                          name: member.name,
                          src: member.avatar,
                          size: 40,
                        ),
                        const SizedBox(width: ZaytonaSpacing.space3),
                        Expanded(
                          child: Text(
                            member.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ZaytonaType.cardTitle,
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: ZaytonaColors.ink300),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
