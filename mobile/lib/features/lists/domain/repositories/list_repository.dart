import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/shopping_list.dart';

abstract class ListRepository {
  /// Creates a list inside a group.
  Future<Result<Failure, ShoppingList>> createList({
    required String groupId,
    required String name,
  });

  /// All lists belonging to a group.
  Future<Result<Failure, List<ShoppingList>>> getGroupLists({
    required String groupId,
  });

  /// Full list detail.
  Future<Result<Failure, ShoppingList>> getList({required String listId});

  /// Deletes the whole list. Endpoint is undocumented in STAGE3 — see
  /// Documentation/backend-needs.md.
Future<Result<Failure, void>> deleteList({
  required String groupId,
  required String listId,
});

  /// Updates a list's name and/or accent color. `PATCH /lists/{listId}` —
  /// admin-only, same rule as `DELETE /lists/{listId}`.
  Future<Result<Failure, ShoppingList>> updateList({
    required String listId,
    required String name,
    String? color,
  });
}
