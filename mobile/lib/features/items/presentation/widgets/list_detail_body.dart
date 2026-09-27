import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/category_registry.dart';
import '../../domain/entities/list_item.dart';
import '../cubit/items/list_items_cubit.dart';
import 'aisle_header.dart';
import 'group_by_aisle.dart';
import 'list_detail_header.dart';
import 'list_empty_state.dart';
import 'list_item_row.dart';
import 'start_trip_bar.dart';

/// Category chips → aisle-grouped rows → Start Trip/Add Item bottom bar,
/// assembled over the list-detail scaffold.
class ListDetailBody extends StatelessWidget {
  final String groupId;
  final String listId;
  final String listName;
  final ZaytonaListAccent listColor;
  final bool isPrivateGroup;
  final List<ListItem> items;
  final Set<String> pendingIds;
  final CategoryId? filter;
  final ValueChanged<CategoryId?> onFilterChanged;
  final VoidCallback onBack;
  final VoidCallback onNotify;
  final VoidCallback onDelete;
  final VoidCallback onHistory;
  final Future<bool> Function(String newName, ZaytonaListAccent color) onRenameList;
  final ValueChanged<ListItem> onEditItem;
  final VoidCallback onAddItem;

  const ListDetailBody({
    super.key,
    required this.groupId,
    required this.listId,
    required this.listName,
    required this.listColor,
    required this.isPrivateGroup,
    required this.items,
    required this.pendingIds,
    required this.filter,
    required this.onFilterChanged,
    required this.onBack,
    required this.onNotify,
    required this.onDelete,
    required this.onHistory,
    required this.onRenameList,
    required this.onEditItem,
    required this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final urgentCount = items.where((i) => i.isUrgent && !i.isBought).length;
    final pool = items
        .where(
          (i) =>
              filter == null ||
              sl<CategoryRegistry>().slugFor(i.categoryId) == filter,
        )
        .toList();
    final presentCats = CategoryId.values
        .where(
          (c) => items.any(
            (i) => sl<CategoryRegistry>().slugFor(i.categoryId) == c,
          ),
        )
        .toList();
    final grouped = groupByAisle(pool);
    final locale = Localizations.localeOf(context).languageCode;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListDetailHeader(
              listId: listId,
              listName: listName,
              listColor: listColor,
              itemCount: items.length,
              urgentCount: urgentCount,
              isPrivateGroup: isPrivateGroup,
              onBack: onBack,
              onNotify: onNotify,
              onDelete: onDelete,
              onHistory: onHistory,
              onRenameList: onRenameList,
              presentCategories: presentCats,
              selectedCategory: filter,
              onCategorySelected: onFilterChanged,
            ),
            Expanded(
              child: items.isEmpty
                  ? ListEmptyState(onAdd: onAddItem)
                  : pool.isEmpty
                  ? ZaytonaEmptyState(
                      icon: const Icon(Icons.search_off),
                      title: l10n.noResultsTitle,
                      body: l10n.nothingInCategory,
                      ctaLabel: l10n.clearFilterAction,
                      ctaIcon: const Icon(Icons.close, size: ZaytonaSpacing.iconSm),
                      onCta: () => onFilterChanged(null),
                    )
                  : ZaytonaRefreshIndicator(
                      onRefresh: () =>
                          context.read<ListItemsCubit>().load(listId),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                          ZaytonaSpacing.space5,
                          ZaytonaSpacing.space3,
                          ZaytonaSpacing.space5,
                          ZaytonaSpacing.space12,
                        ),
                        children: [
                          for (final entry in grouped) ...[
                            AisleHeader(
                              category: entry.$1,
                              count: entry.$2.length,
                              locale: locale,
                            ),
                            for (final item in entry.$2) ...[
                              ListItemRow(
                                item: item,
                                pending: pendingIds.contains(item.listItemId),
                                onTap: () => onEditItem(item),
                              ),
                              const SizedBox(height: ZaytonaSpacing.space2),
                            ],
                            const SizedBox(height: ZaytonaSpacing.space2),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
        // Bottom action bar over a cream fade, per the prototype.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              ZaytonaSpacing.space5,
              ZaytonaSpacing.space3,
              ZaytonaSpacing.space5,
              ZaytonaSpacing.space5,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [ZaytonaColors.cream, Color(0x00FFF8ED)],
                stops: [0.72, 1],
              ),
            ),
            child: StartTripBar(
              groupId: groupId,
              listId: listId,
              listName: listName,
              itemsEmpty: items.isEmpty,
              onAddItem: onAddItem,
            ),
          ),
        ),
      ],
    );
  }
}
