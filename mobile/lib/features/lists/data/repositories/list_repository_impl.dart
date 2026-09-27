import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/shopping_list.dart';
import '../../domain/repositories/list_repository.dart';
import '../datasources/remote/list_remote_datasource.dart';

class ListRepositoryImpl implements ListRepository {
  ListRepositoryImpl(this._ds);
  final ListRemoteDataSource _ds;

  @override
  Future<Result<Failure, ShoppingList>> createList({
    required String groupId,
    required String name,
  }) {
    return _mapOne(() => _ds.createList(groupId: groupId, name: name));
  }

  @override
  Future<Result<Failure, List<ShoppingList>>> getGroupLists({
    required String groupId,
  }) async {
    try {
      final res = await _ds.getGroupLists(groupId: groupId);
      final data = res.data;
      if (data is! List) {
        return const ResultError(ValidationFailure('استجابة غير متوقعة من الخادم'));
      }
      final lists = data
          .map((l) => ShoppingList.fromJson(l as Map<String, dynamic>))
          .toList();
      return Success(lists);
    } on NetworkException catch (e) {
      return ResultError(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return ResultError(ServerFailure(e.message));
    } catch (_) {
      return const ResultError(ServerFailure());
    }
  }

  @override
  Future<Result<Failure, ShoppingList>> getList({required String listId}) {
    return _mapOne(() => _ds.getList(listId: listId));
  }

  @override
  Future<Result<Failure, void>> deleteList({
    required String groupId,
    required String listId,
  }) async {
    try {
      await _ds.deleteList(
        groupId: groupId,
        listId: listId,
      );

      return const Success(null);
    } on NetworkException catch (e) {
      return ResultError(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return ResultError(ServerFailure(e.message));
    } catch (_) {
      return const ResultError(ServerFailure());
    }
}

  @override
  Future<Result<Failure, ShoppingList>> updateList({
    required String listId,
    required String name,
    String? color,
  }) {
    return _mapOne(() => _ds.updateList(listId: listId, name: name, color: color));
  }

  /// Shared decode path for endpoints returning a single list object.
  Future<Result<Failure, ShoppingList>> _mapOne(
    Future<dynamic> Function() request,
  ) async {
    try {
      final res = await request();
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        return const ResultError(ValidationFailure('استجابة غير متوقعة من الخادم'));
      }
      return Success(ShoppingList.fromJson(data));
    } on NetworkException catch (e) {
      return ResultError(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return ResultError(ServerFailure(e.message));
    } catch (_) {
      return const ResultError(ServerFailure());
    }
  }
}
