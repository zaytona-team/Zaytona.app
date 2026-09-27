import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../domain/entities/catalog_entry.dart';
import '../../../domain/entities/item_unit.dart';
import '../../../domain/entities/list_item.dart';
import '../../../domain/repositories/item_repository.dart';
import '../../../domain/repositories/personal_catalog_repository.dart';
import '../../../domain/usecases/add_item_usecase.dart';
import 'catalog_state.dart';

/// Drives [CatalogPage]: the personal catalog grid (search/filter/quick-add),
/// and the duplicate-name list for the add sheet. Owns all of the page's
/// interactive state — search text, category filter, quick-add feedback —
/// so the page itself can stay a StatelessWidget.
class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(this._itemRepo, this._catalogRepo, this._addItemUseCase)
    : super(const CatalogState());

  final ItemRepository _itemRepo;
  final PersonalCatalogRepository _catalogRepo;
  final AddItemUseCase _addItemUseCase;

  Future<void> loadMyItems() async {
    final cached = await _catalogRepo.getMyItems();
    cached.fold(
      (failure) => null,
      (items) => emit(state.copyWith(myItems: items)),
    );

    final fresh = await _catalogRepo.refreshMyItems();
    fresh.fold(
      (failure) => null,
      (items) => emit(state.copyWith(myItems: items)),
    );
  }

  // US-25: items already on this list — both for AddItemSheet's non-blocking
  // "might be a duplicate" name warning, and to detect a quick-add merge
  // target (exact name+brand match).
  Future<void> loadExistingItems(String listId) async {
    final result = await _itemRepo.getListItems(listId: listId);
    result.fold(
      (failure) => null,
      (items) => emit(state.copyWith(existingItems: items)),
    );
  }

  Future<void> reload(String listId) =>
      Future.wait([loadMyItems(), loadExistingItems(listId)]);

  void setSearchQuery(String query) =>
      emit(state.copyWith(searchQuery: query.trim().toLowerCase()));

  void setCategoryFilter(CategoryId? category) =>
      emit(state.copyWith(categoryFilter: category));

  /// Same list item as [entry] iff name matches case-insensitively and
  /// brand matches exactly (empty treated as no brand). A branded entry
  /// never merges into an unbranded one or vice versa.
  ListItem? _findMergeTarget(CatalogEntry entry) {
    String? normalizedBrand(String? brand) {
      final trimmed = brand?.trim();
      return trimmed == null || trimmed.isEmpty ? null : trimmed;
    }

    final name = entry.name.trim().toLowerCase();
    final brand = normalizedBrand(entry.brand);
    for (final item in state.existingItems) {
      if (item.name.trim().toLowerCase() == name &&
          normalizedBrand(item.brand) == brand) {
        return item;
      }
    }
    return null;
  }

  /// One-tap re-add from the catalog grid: sensible defaults, no sheet —
  /// lets the user add several items in a row without leaving the page. A
  /// tap on an item already on the list (same name + brand) increases its
  /// quantity instead of creating a duplicate card — the user is pointing
  /// at a known item, not typing a guess, so this merges where manual entry
  /// (and its non-blocking duplicate warning) does not.
  Future<void> quickAdd(
    String listId,
    CatalogEntry entry, {
    double quantity = 1,
  }) async {
    final mergeTarget = _findMergeTarget(entry);

    if (mergeTarget != null) {
      final result = await _itemRepo.updateItem(
        listId: listId,
        item: mergeTarget.copyWith(quantity: mergeTarget.quantity + quantity),
      );
      result.fold(
        (failure) => null,
        (item) => emit(
          state.copyWith(
            feedback: item.name,
            mergedQuantity: item.quantity,
            existingItems: [
              for (final i in state.existingItems)
                if (i.listItemId == item.listItemId) item else i,
            ],
            hasQuickAdded: true,
          ),
        ),
      );
      return;
    }

    final result = await _addItemUseCase(
      AddItemParams(
        listId: listId,
        name: entry.name,
        quantity: quantity,
        unit: ItemUnit.pcs.name,
        categoryId: entry.categoryId,
        brand: entry.brand,
      ),
    );
    // Consistent with the rest of this cubit's failure handling (loadMyItems
    // / loadExistingItems both swallow failures silently) — only success
    // surfaces feedback, as the item's name for the page's snackbar.
    //
    // _findMergeTarget above only catches a duplicate this cubit already
    // knows about (existingItems, snapshotted once on page open) — the
    // backend also merges same-name-and-unit adds it finds that this
    // client doesn't know about yet (e.g. added by another device since).
    // Upsert by id here too, so that still lands as one row, not a second
    // copy of an item this cache already has.
    result.fold(
      (failure) => null,
      (item) {
        final alreadyPresent =
            state.existingItems.any((i) => i.listItemId == item.listItemId);
        emit(
          state.copyWith(
            feedback: item.name,
            mergedQuantity: alreadyPresent ? item.quantity : null,
            existingItems: alreadyPresent
                ? [
                    for (final i in state.existingItems)
                      if (i.listItemId == item.listItemId) item else i,
                  ]
                : [...state.existingItems, item],
            hasQuickAdded: true,
          ),
        );
      },
    );
  }
}
