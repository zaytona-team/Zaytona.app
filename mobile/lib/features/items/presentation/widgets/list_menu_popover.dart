import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import '../cubit/items/list_items_cubit.dart';
import 'edit_list_sheet.dart';
import 'list_menu_row.dart';

/// Opens the anchored list-menu popover under [anchorKey]'s render box, and
/// wires its 4 rows: list settings (rename sheet), history, delete-all
/// (confirm dialog + cubit call) and delete-list (page-owned callback).
void showListMenu(
  BuildContext context, {
  required GlobalKey anchorKey,
  required String listId,
  required String listName,
  required ZaytonaListAccent listColor,
  required int itemCount,
  required VoidCallback onHistory,
  required VoidCallback onDeleteList,
  required Future<bool> Function(String newName, ZaytonaListAccent color) onRenameList,
}) {
  final l10n = AppLocalizations.of(context)!;
  final cubit = context.read<ListItemsCubit>();

  Future<void> confirmDeleteAll() async {
    final confirmed = await ZaytonaDialog.show<bool>(
      context,
      title: l10n.deleteAllItemsConfirmTitle,
      body: l10n.deleteAllItemsConfirmBody(itemCount),
      cancelLabel: l10n.cancelAction,
      confirmLabel: l10n.deleteAllAction,
      danger: true,
      onConfirm: () {},
    );
    if (confirmed == true) cubit.deleteAllItems(listId);
  }

  showZaytonaAnchoredMenu(
    context,
    anchorKey: anchorKey,
    width: 236,
    cardBuilder: (menuContext) {
      final close = ZaytonaMenuCloseScope.of(menuContext);
      return ListMenuCard(
        itemCount: itemCount,
        onListSettings: () {
          close();
          ZaytonaSheet.show<void>(
            context,
            child: EditListSheet(
              initialName: listName,
              initialColor: listColor,
              onSave: onRenameList,
            ),
          );
        },
        onHistory: () {
          close();
          onHistory();
        },
        onDeleteAllItems: () {
          close();
          confirmDeleteAll();
        },
        onDeleteList: () {
          close();
          onDeleteList();
        },
      );
    },
  );
}

/// The anchored popover card opened from [ListDetailHeader]'s "⋯" button —
/// 4 rows matching the prototype's listMenu (CompactRow icon+label, red
/// tone for the destructive pair). Prototype: ListDetail's `listMenu`,
/// screens-main.jsx.
class ListMenuCard extends StatelessWidget {
  final int itemCount;
  final VoidCallback onListSettings;
  final VoidCallback onHistory;
  final VoidCallback onDeleteAllItems;
  final VoidCallback onDeleteList;

  const ListMenuCard({
    super.key,
    required this.itemCount,
    required this.onListSettings,
    required this.onHistory,
    required this.onDeleteAllItems,
    required this.onDeleteList,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ZaytonaMenuCard(
      children: [
        ListMenuRow(
          icon: Icons.edit_outlined,
          label: l10n.listSettingsTitle,
          onTap: onListSettings,
        ),
        ListMenuRow(
          icon: Icons.history,
          label: l10n.historyAction,
          onTap: onHistory,
        ),
        const Divider(
          height: 1.5,
          thickness: 1.5,
          color: ZaytonaColors.borderSoft,
        ),
        ListMenuRow(
          icon: Icons.remove_shopping_cart_outlined,
          label: l10n.deleteAllItemsAction,
          tone: ListMenuRowTone.red,
          disabled: itemCount == 0,
          onTap: onDeleteAllItems,
        ),
        ListMenuRow(
          icon: Icons.delete_outline,
          label: l10n.deleteListConfirmTitle,
          tone: ListMenuRowTone.red,
          onTap: onDeleteList,
        ),
      ],
    );
  }
}
