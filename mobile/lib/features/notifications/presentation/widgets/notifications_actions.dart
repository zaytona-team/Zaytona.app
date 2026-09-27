import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../groups/domain/entities/group_member.dart';
import '../cubit/notifications_cubit.dart';
import 'member_picker_sheet.dart';

/// Confirms then fires the "heading to store" push to every member.
Future<void> confirmHeadingToStore(BuildContext context, String listId) async {
  final l10n = AppLocalizations.of(context)!;
  final cubit = context.read<NotificationsCubit>();
  final confirmed = await ZaytonaDialog.show<bool>(
    context,
    title: l10n.notifyAllConfirmTitle,
    body: l10n.notifyAllConfirmBody,
    cancelLabel: l10n.cancelAction,
    confirmLabel: l10n.confirmAction,
    onConfirm: () {},
  );
  if (confirmed == true) cubit.headingToStore(listId);
}

/// Opens the member picker sheet and invokes [onPicked] with the pick.
Future<void> pickMember(
  BuildContext context, {
  required String groupId,
  required String sheetTitle,
  required List<GroupMember> members,
  required void Function(GroupMember member) onPicked,
}) async {
  final picked = await ZaytonaSheet.show<GroupMember>(
    context,
    child: MemberPickerSheet(title: sheetTitle, members: members, groupId: groupId),
  );
  if (picked != null) onPicked(picked);
}
