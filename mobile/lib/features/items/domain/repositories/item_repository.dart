import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/list_item.dart';

abstract class ItemRepository {
  /// Items of one list (US-13 list detail).
  Future<Result<Failure, List<ListItem>>> getListItems({required String listId});

  /// Adds an item (US-16). Duplicate names are allowed — the "possible
  /// duplicate" warning is a non-blocking frontend hint only.
  Future<Result<Failure, ListItem>> addItem({
    required String listId,
    required String name,
    required double quantity,
    required String unit,
    String? categoryId,
    String? notes,
    String? brand,
    bool isUrgent = false,
  });

  /// Edits quantity/unit/notes/urgency/name (US-16).
  Future<Result<Failure, ListItem>> updateItem({
    required String listId,
    required ListItem item,
  });

  /// Removes one item (US-16).
  Future<Result<Failure, void>> deleteItem({
    required String listId,
    required String listItemId,
  });

  /// Removes every item on the list in one atomic call (US-23).
  Future<Result<Failure, void>> deleteAllItems({required String listId});

  /// Check/uncheck during buying (US-26). The only mutation Buying View allows.
  Future<Result<Failure, ListItem>> setPurchased({
    required String listId,
    required String listItemId,
    required bool isBought,
  });

  /// Attaches a photo to an already-created item (US-21). Returns the
  /// resulting public image URL, rendered directly by the caller.
  Future<Result<Failure, String>> uploadItemImage({
    required String listId,
    required String listItemId,
    required String filePath,
  });
}
