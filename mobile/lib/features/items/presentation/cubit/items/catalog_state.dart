import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../domain/entities/catalog_entry.dart';
import '../../../domain/entities/list_item.dart';

const _unset = Object();

class CatalogState {
  const CatalogState({
    this.myItems = const [],
    this.existingItems = const [],
    this.searchQuery = '',
    this.categoryFilter,
    this.feedback,
    this.mergedQuantity,
    this.hasQuickAdded = false,
  });

  final List<CatalogEntry> myItems;

  /// Full items already on this list — used both for the US-25 duplicate
  /// name hint and to detect a quick-add merge target (name + brand match).
  final List<ListItem> existingItems;

  final String searchQuery;
  final CategoryId? categoryFilter;

  /// One-shot message for the page's BlocListener (e.g. "Added «X»").
  final String? feedback;

  /// Set alongside [feedback] when a quick-add merged into an existing item
  /// instead of creating a new one — the resulting total quantity.
  final double? mergedQuantity;

  /// Set once a grid quick-add succeeds, so the back button can signal the
  /// list-detail screen to reload instead of silently dropping the change.
  final bool hasQuickAdded;

  CatalogState copyWith({
    List<CatalogEntry>? myItems,
    List<ListItem>? existingItems,
    String? searchQuery,
    Object? categoryFilter = _unset,
    Object? feedback = _unset,
    Object? mergedQuantity = _unset,
    bool? hasQuickAdded,
  }) {
    return CatalogState(
      myItems: myItems ?? this.myItems,
      existingItems: existingItems ?? this.existingItems,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: identical(categoryFilter, _unset)
          ? this.categoryFilter
          : categoryFilter as CategoryId?,
      feedback: identical(feedback, _unset)
          ? this.feedback
          : feedback as String?,
      mergedQuantity: identical(mergedQuantity, _unset)
          ? this.mergedQuantity
          : mergedQuantity as double?,
      hasQuickAdded: hasQuickAdded ?? this.hasQuickAdded,
    );
  }
}
