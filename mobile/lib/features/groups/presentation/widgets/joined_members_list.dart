import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/invited_person.dart';

/// The "who already joined via this code" section of InviteToGroupPage.
class JoinedMembersList extends StatelessWidget {
  const JoinedMembersList({super.key, required this.members, required this.onShareLink});

  final List<InvitedPerson> members;
  final VoidCallback onShareLink;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (members.isEmpty) {
      return ZaytonaEmptyState(
        icon: const Icon(Icons.group_outlined, size: 32),
        title: l10n.nobodyJoinedYet,
        body: l10n.nobodyJoinedYetBody,
        tone: ZaytonaStarTone.lilac,
        ctaLabel: l10n.shareInviteLink,
        onCta: onShareLink,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            l10n.joinedMembersSection(members.length),
            style: ZaytonaType.fieldLabel,
          ),
        ),
        const SizedBox(height: ZaytonaSpacing.space3),
        ...members.map(_memberCard),
      ],
    );
  }

  Widget _memberCard(InvitedPerson person) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ZaytonaSpacing.space3),
      child: ZaytonaCard(
        variant: ZaytonaCardVariant.plain,
        child: Row(
          children: [
            ZaytonaAvatar(name: person.name ?? person.phoneNumber, size: 40),
            const SizedBox(width: ZaytonaSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (person.name != null)
                    Text(person.name!, style: ZaytonaType.fieldLabel),
                  Text(person.phoneNumber, style: ZaytonaType.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
