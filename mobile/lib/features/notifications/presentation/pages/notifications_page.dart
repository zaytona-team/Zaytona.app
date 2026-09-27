import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../groups/domain/entities/group_member.dart';
import '../cubit/notifications_cubit.dart';
import '../widgets/member_alert_tile.dart';
import '../widgets/notifications_actions.dart';
import '../widgets/notifications_sheet_states.dart';

/// Trip alerts — Story 7 (US-30..US-32), opened as a sheet from the list
/// detail bell (prototype: Notifications, screens-more.jsx). Three push
/// actions: heading-to-store (confirm dialog → notify all), assign buyer
/// and remind member (member picker sheets). Each row shows the picked
/// member inline once chosen — that "chosen" state is local to this sheet,
/// same as the prototype's local `chosen` state; the cubit only tracks the
/// in-flight/error state of the request itself.
class NotificationsSheet extends StatefulWidget {
  final String groupId;
  final String listId;

  const NotificationsSheet({
    super.key,
    required this.groupId,
    required this.listId,
  });

  @override
  State<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<NotificationsSheet> {
  GroupMember? _assignedTo;
  GroupMember? _remindedMember;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ZaytonaSheet(
      onClose: () => Navigator.of(context).maybePop(),
      child: BlocConsumer<NotificationsCubit, NotificationsState>(
        listener: (context, state) {
          if (state is NotificationsSendError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) => switch (state) {
          NotificationsLoading() => const NotificationsSheetLoading(),
          NotificationsLoadError(:final message) => NotificationsSheetError(
              message: message,
              onRetry: () => context.read<NotificationsCubit>().load(widget.groupId),
            ),
          NotificationsReady() => _body(context, l10n, state),
        },
      ),
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations l10n,
    NotificationsReady state,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(ZaytonaSpacing.gutter, ZaytonaSpacing.space1, ZaytonaSpacing.gutter, ZaytonaSpacing.space3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.tripAlertsTitle, style: ZaytonaType.sheetTitle),
              ZaytonaIconButton(
                icon: const Icon(Icons.close),
                tone: ZaytonaIconButtonTone.navy,
                variant: ZaytonaIconButtonVariant.soft,
                size: ZaytonaIconButtonSize.sm,
                semanticLabel: l10n.cancelAction,
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(ZaytonaSpacing.gutter, 0, ZaytonaSpacing.gutter, ZaytonaSpacing.space6),
            child: Column(
              children: [
                ZaytonaAlertTile(
                  tone: ZaytonaAlertTone.red,
                  leading: const Icon(Icons.storefront, color: ZaytonaColors.navy, size: 19),
                  title: l10n.headingToStoreTitle,
                  body: l10n.headingToStoreBody,
                  action: ZaytonaButton(
                    label: l10n.notifyGroupAction,
                    variant: ZaytonaButtonVariant.primary,
                    size: ZaytonaButtonSize.sm,
                    disabled: state.sending,
                    onTap: () => confirmHeadingToStore(context, widget.listId),
                  ),
                ),
                const SizedBox(height: ZaytonaSpacing.space3),
                MemberAlertTile(
                  tone: ZaytonaAlertTone.indigo,
                  icon: Icons.person_add_alt,
                  title: l10n.assignBuyerTitle,
                  body: l10n.assignBuyerBody,
                  chooseVariant: ZaytonaButtonVariant.secondary,
                  chosen: _assignedTo,
                  disabled: state.sending,
                  onChoose: () => pickMember(
                    context,
                    groupId: widget.groupId,
                    sheetTitle: l10n.assignBuyerTitle,
                    members: state.members,
                    onPicked: (m) {
                      setState(() => _assignedTo = m);
                      context.read<NotificationsCubit>().assignBuyer(widget.listId, m.userId);
                    },
                  ),
                ),
                const SizedBox(height: ZaytonaSpacing.space3),
                MemberAlertTile(
                  tone: ZaytonaAlertTone.mint,
                  icon: Icons.notifications_active,
                  title: l10n.remindMemberTitle,
                  body: l10n.remindMemberBody,
                  chooseVariant: ZaytonaButtonVariant.mint,
                  chosen: _remindedMember,
                  disabled: state.sending,
                  onChoose: () => pickMember(
                    context,
                    groupId: widget.groupId,
                    sheetTitle: l10n.remindMemberSheetTitle,
                    members: state.members,
                    onPicked: (m) {
                      setState(() => _remindedMember = m);
                      context.read<NotificationsCubit>().remindMember(widget.listId, m.userId);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
