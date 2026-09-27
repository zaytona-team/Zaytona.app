import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../core/di/injection_container.dart';
import '../../data/category_registry.dart';
import '../../domain/entities/list_item.dart';
import '../cubit/items/list_items_cubit.dart';
import 'aisle_header.dart';
import 'buying_done_bar.dart';
import 'buying_row.dart';
import 'buying_view_header.dart';

/// Cream sheet + navy header for the buying view: filter pills, aisle-
/// grouped rows, Done bar pinned to the bottom.
class BuyingViewBody extends StatelessWidget {
  final String listId;
  final String listName;
  final List<ListItem> items;
  final Set<String> pendingIds;
  final bool urgentOnly;
  final ValueChanged<bool> onFilterChanged;

  const BuyingViewBody({
    super.key,
    required this.listId,
    required this.listName,
    required this.items,
    required this.pendingIds,
    required this.urgentOnly,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final checkedCount = items.where((i) => i.isBought).length;
    final filtered = items.where((i) => !urgentOnly || i.isUrgent).toList()
      ..sort((a, b) => (a.isBought ? 1 : 0) - (b.isBought ? 1 : 0));
    final grouped = [
      for (final cat in CategoryId.values)
        if (filtered.any((i) => sl<CategoryRegistry>().slugFor(i.categoryId) == cat))
          (
            cat,
            filtered
                .where((i) => sl<CategoryRegistry>().slugFor(i.categoryId) == cat)
                .toList(),
          ),
    ];
    final locale = Localizations.localeOf(context).languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BuyingViewHeader(
          listName: listName,
          checkedCount: checkedCount,
          totalCount: items.length,
          urgentOnly: urgentOnly,
          onFilterChanged: onFilterChanged,
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: ZaytonaColors.cream,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Stack(
              children: [
                ZaytonaRefreshIndicator(
                  onRefresh: () => context.read<ListItemsCubit>().load(listId),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      ZaytonaSpacing.space4,
                      ZaytonaSpacing.space4,
                      ZaytonaSpacing.space4,
                      ZaytonaSpacing.space12,
                    ),
                    children: [
                      for (final entry in grouped) ...[
                        AisleHeader(category: entry.$1, count: entry.$2.length, locale: locale),
                        for (final item in entry.$2) ...[
                          BuyingRow(item: item, pending: pendingIds.contains(item.listItemId)),
                          const SizedBox(height: ZaytonaSpacing.space2),
                        ],
                        const SizedBox(height: ZaytonaSpacing.space2),
                      ],
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: BuyingDoneBar(checkedCount: checkedCount, totalCount: items.length),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
