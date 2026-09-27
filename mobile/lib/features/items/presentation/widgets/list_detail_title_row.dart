import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../l10n/app_localizations.dart';

/// Title + item count + urgent badge, plus the category filter chip row
/// below it. Split out of [ListDetailHeader] to keep that file within the
/// house line-count limit.
class ListDetailTitleRow extends StatelessWidget {
  final String listName;
  final int itemCount;
  final int urgentCount;
  final List<CategoryId> presentCategories;
  final CategoryId? selectedCategory;
  final ValueChanged<CategoryId?> onCategorySelected;

  const ListDetailTitleRow({
    super.key,
    required this.listName,
    required this.itemCount,
    required this.urgentCount,
    required this.presentCategories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            ZaytonaSpacing.space5,
            ZaytonaSpacing.space0,
            ZaytonaSpacing.space5,
            ZaytonaSpacing.space3,
          ),
          child: Row(
            children: [
              Expanded(child: Text(listName, style: ZaytonaType.sheetTitle)),
              Text(l10n.listItemCount(itemCount), style: ZaytonaType.meta),
              if (urgentCount > 0) ...[
                const SizedBox(width: ZaytonaSpacing.space2),
                ZaytonaBadge(
                  label: l10n.urgentCount(urgentCount),
                  tone: ZaytonaBadgeTone.red,
                  variant: ZaytonaBadgeVariant.solid,
                  size: ZaytonaBadgeSize.sm,
                ),
              ],
            ],
          ),
        ),
        if (itemCount > 0)
          SizedBox(
            height: ZaytonaSpacing.tapMin,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: ZaytonaSpacing.space5),
              children: [
                ZaytonaCategoryChip(
                  label: l10n.allCategories,
                  selected: selectedCategory == null,
                  onTap: () => onCategorySelected(null),
                ),
                for (final cat in presentCategories) ...[
                  const SizedBox(width: ZaytonaSpacing.space2),
                  ZaytonaCategoryChip(
                    label: cat.label(locale),
                    icon: Image.asset(cat.assetPath, width: 20, height: 20),
                    selected: selectedCategory == cat,
                    onTap: () => onCategorySelected(cat),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
