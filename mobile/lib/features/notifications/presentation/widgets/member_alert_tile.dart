import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../groups/domain/entities/group_member.dart';
import 'member_picker_sheet.dart';

/// Shared shape for the assign-buyer / remind-member rows — both are a
/// tinted [ZaytonaAlertTile] whose action opens a member picker, showing
/// the chosen member inline once picked.
class MemberAlertTile extends StatelessWidget {
  final ZaytonaAlertTone tone;
  final IconData icon;
  final String title;
  final String body;
  final ZaytonaButtonVariant chooseVariant;
  final GroupMember? chosen;
  final bool disabled;
  final VoidCallback onChoose;

  const MemberAlertTile({
    super.key,
    required this.tone,
    required this.icon,
    required this.title,
    required this.body,
    required this.chooseVariant,
    required this.chosen,
    required this.disabled,
    required this.onChoose,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ZaytonaAlertTile(
      tone: tone,
      leading: Icon(icon, color: tone.ink, size: 19),
      title: title,
      body: body,
      selected: chosen == null ? null : ChosenMember(member: chosen!),
      action: ZaytonaButton(
        label: chosen == null ? l10n.chooseMemberAction : l10n.changeMemberAction,
        variant: chosen == null ? chooseVariant : ZaytonaButtonVariant.outline,
        size: ZaytonaButtonSize.sm,
        disabled: disabled,
        onTap: onChoose,
      ),
    );
  }
}
