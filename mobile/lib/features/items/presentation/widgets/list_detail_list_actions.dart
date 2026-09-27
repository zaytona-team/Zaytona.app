import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../core/di/injection_container.dart';
import '../../../lists/domain/entities/shopping_list.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../cubit/items/list_items_cubit.dart';
import 'delete_list_dialog.dart';

/// List-level actions for the list-detail page (rename, delete whole list,
/// open trip alerts) — split out of ListDetailPage to keep it within the
/// house line-count limit.

/// Renames/recolors the list via the cubit; returns the updated list on
/// success so the caller can mirror it into its own display state.
Future<ShoppingList?> renameList(
  BuildContext context,
  String listId,
  String newName,
  ZaytonaListAccent color,
) {
  return context
      .read<ListItemsCubit>()
      .renameList(listId, newName, color: color.name);
}

/// Confirms then deletes the whole list. Returns whether it succeeded.
Future<bool> confirmDeleteList(
  BuildContext context, {
  required String groupId,
  required String listId,
  required String listName,
}) async {
  final confirmed = await showDeleteListDialog(context, listName);
  if (confirmed != true) return false;

  return context.read<ListItemsCubit>().deleteList(
        groupId: groupId,
        listId: listId,
      );
  // On failure the cubit already emitted an error state; the page's
  // BlocListener surfaces it via a SnackBar.
}

/// Opens Trip Alerts as a bottom sheet (prototype: Notifications,
/// screens-more.jsx) instead of a pushed route.
void openNotificationsSheet(
  BuildContext context, {
  required String groupId,
  required String listId,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => BlocProvider(
      create: (_) => sl<NotificationsCubit>()..load(groupId),
      child: NotificationsSheet(groupId: groupId, listId: listId),
    ),
  );
}
