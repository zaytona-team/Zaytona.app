import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/list_item.dart';
import '../../domain/repositories/item_repository.dart';
import '../datasources/remote/item_remote_datasource.dart';

class ItemRepositoryImpl implements ItemRepository {
  ItemRepositoryImpl(this._ds);
  final ItemRemoteDataSource _ds;

 @override
Future<Result<Failure, List<ListItem>>> getListItems({
  required String listId,
}) async {
  return _guard(() async {
    final res = await _ds.getListItems(listId: listId);
    final data = res.data;

    if (data is! List) {
      return const ResultError(
        ValidationFailure('استجابة غير متوقعة من الخادم'),
      );
    }

    final items = data
        .whereType<Map<String, dynamic>>()
        .map(ListItem.fromJson)
        .toList();

    return Success(items);
  });
}

  @override
  Future<Result<Failure, ListItem>> addItem({
    required String listId,
    required String name,
    required double quantity,
    required String unit,
    String? categoryId,
    String? notes,
    String? brand,
    bool isUrgent = false,
  }) {
    return _guard(() async {
      final res = await _ds.addItem(listId: listId, body: {
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'category_id': ?categoryId,
        'notes': ?notes,
        'brand': ?brand,
        'is_urgent': isUrgent,
      });
      return _decodeItem(res.data);
    });
  }

  @override
  Future<Result<Failure, String>> uploadItemImage({
    required String listId,
    required String listItemId,
    required String filePath,
  }) {
    return _guard(() async {
      final res = await _ds.uploadItemImage(
        listId: listId,
        listItemId: listItemId,
        filePath: filePath,
      );
      final data = res.data;
      final imageUrl = data is Map ? data['image_url'] as String? : null;
      if (imageUrl == null) {
        return const ResultError(ValidationFailure());
      }
      return Success(imageUrl);
    });
  }

  @override
  Future<Result<Failure, ListItem>> updateItem({
    required String listId,
    required ListItem item,
  }) {
    return _guard(() async {
      final res = await _ds.updateItem(
        listId: listId,
        listItemId: item.listItemId,
        body: {
          'name': item.name,
          'quantity': item.quantity,
          'unit': item.unit,
          'category_id': ?item.categoryId,
          'notes': ?item.notes,
          'brand': ?item.brand,
          'is_urgent': item.isUrgent,
        },
      );
      return _decodeItem(res.data);
    });
  }

  @override
  Future<Result<Failure, void>> deleteItem({
    required String listId,
    required String listItemId,
  }) {
    return _guard(() async {
      await _ds.deleteItem(listId: listId, listItemId: listItemId);
      return const Success(null);
    });
  }

  @override
  Future<Result<Failure, void>> deleteAllItems({required String listId}) {
    return _guard(() async {
      await _ds.deleteAllItems(listId: listId);
      return const Success(null);
    });
  }

  @override
  Future<Result<Failure, ListItem>> setPurchased({
    required String listId,
    required String listItemId,
    required bool isBought,
  }) {
    return _guard(() async {
      final res = await _ds.setPurchased(
        listId: listId,
        listItemId: listItemId,
        isBought: isBought,
      );
      return _decodeItem(res.data);
    });
  }

  Result<Failure, ListItem> _decodeItem(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return const ResultError(ValidationFailure('استجابة غير متوقعة من الخادم'));
    }
    return Success(ListItem.fromJson(data));
  }

  /// Shared exception → Failure mapping.
  Future<Result<Failure, T>> _guard<T>(
    Future<Result<Failure, T>> Function() body,
  ) async {
    try {
      return await body();
    } on NetworkException catch (e) {
      return ResultError(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return ResultError(ServerFailure(e.message));
    } catch (_) {
      return const ResultError(ServerFailure());
    }
  }
}
