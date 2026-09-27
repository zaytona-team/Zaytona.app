import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import 'list_detail_title_row.dart';
import 'list_menu_popover.dart';

/// Top bar (back/notify/list-menu) + title row + category filter chips for
/// the list detail screen. The list menu ("⋯") opens an anchored popover
/// (prototype: ListDetail's `listMenu`, screens-main.jsx) with list
/// settings (rename), history, delete-all-items and delete-list — see
/// [showListMenu] in list_menu_popover.dart.
class ListDetailHeader extends StatefulWidget {
  final String listId;
  final String listName;
  final ZaytonaListAccent listColor;
  final int itemCount;
  final int urgentCount;
  final bool isPrivateGroup;
  final VoidCallback onBack;
  final VoidCallback onNotify;
  final VoidCallback onDelete;
  final VoidCallback onHistory;
  final Future<bool> Function(String newName, ZaytonaListAccent color) onRenameList;
  final List<CategoryId> presentCategories;
  final CategoryId? selectedCategory;
  final ValueChanged<CategoryId?> onCategorySelected;

  const ListDetailHeader({
    super.key,
    required this.listId,
    required this.listName,
    required this.listColor,
    required this.itemCount,
    required this.urgentCount,
    required this.isPrivateGroup,
    required this.onBack,
    required this.onNotify,
    required this.onDelete,
    required this.onHistory,
    required this.onRenameList,
    required this.presentCategories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<ListDetailHeader> createState() => _ListDetailHeaderState();
}

class _ListDetailHeaderState extends State<ListDetailHeader> {
  final _menuButtonKey = GlobalKey();

  void _openMenu(BuildContext context) {
    showListMenu(
      context,
      anchorKey: _menuButtonKey,
      listId: widget.listId,
      listName: widget.listName,
      listColor: widget.listColor,
      itemCount: widget.itemCount,
      onHistory: widget.onHistory,
      onDeleteList: widget.onDelete,
      onRenameList: widget.onRenameList,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            ZaytonaSpacing.space5,
            ZaytonaSpacing.space1,
            ZaytonaSpacing.space5,
            ZaytonaSpacing.space3,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ZaytonaIconButton(
                icon: const Icon(Icons.chevron_left),
                tone: ZaytonaIconButtonTone.navy,
                variant: ZaytonaIconButtonVariant.soft,
                size: ZaytonaIconButtonSize.sm,
                semanticLabel: l10n.backAction,
                onTap: widget.onBack,
              ),
              Row(
                children: [
                  if (!widget.isPrivateGroup) ...[
                    ZaytonaIconButton(
                      icon: const Icon(Icons.notifications_none, size: 19),
                      tone: ZaytonaIconButtonTone.navy,
                      variant: ZaytonaIconButtonVariant.soft,
                      size: ZaytonaIconButtonSize.sm,
                      semanticLabel: l10n.notifyAction,
                      onTap: widget.onNotify,
                    ),
                    const SizedBox(width: ZaytonaSpacing.space2),
                  ],
                  ZaytonaIconButton(
                    key: _menuButtonKey,
                    icon: const Icon(Icons.more_horiz, size: 19),
                    tone: ZaytonaIconButtonTone.navy,
                    variant: ZaytonaIconButtonVariant.soft,
                    size: ZaytonaIconButtonSize.sm,
                    semanticLabel: l10n.listMenuAction,
                    onTap: () => _openMenu(context),
                  ),
                ],
              ),
            ],
          ),
        ),
        ListDetailTitleRow(
          listName: widget.listName,
          itemCount: widget.itemCount,
          urgentCount: widget.urgentCount,
          presentCategories: widget.presentCategories,
          selectedCategory: widget.selectedCategory,
          onCategorySelected: widget.onCategorySelected,
        ),
      ],
    );
  }
}
