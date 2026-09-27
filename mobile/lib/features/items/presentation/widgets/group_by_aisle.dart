import '../../../../core/di/injection_container.dart';
import '../../data/category_registry.dart';
import '../../domain/entities/list_item.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

/// Groups items by category in the fixed aisle order (prototype
/// groupByAisle) — uncategorized items fall into pantry via fromSlug.
/// Bought items sink to the bottom of their aisle, matching Buying View.
List<(CategoryId, List<ListItem>)> groupByAisle(List<ListItem> pool) {
  final ordered = [...pool]
    ..sort((a, b) => (a.isBought ? 1 : 0) - (b.isBought ? 1 : 0));
  return [
    for (final cat in CategoryId.values)
      if (ordered.any((i) => sl<CategoryRegistry>().slugFor(i.categoryId) == cat))
        (
          cat,
          ordered
              .where((i) => sl<CategoryRegistry>().slugFor(i.categoryId) == cat)
              .toList(),
        ),
  ];
}
