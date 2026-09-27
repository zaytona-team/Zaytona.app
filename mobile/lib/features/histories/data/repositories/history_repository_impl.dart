import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/history_model.dart';
import '../../domain/entities/trip_history_entry.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/remote/history_remote_datasource.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl(this._ds);
  final HistoryRemoteDataSource _ds;

  @override
  Future<Result<Failure, List<HistoryModel>>> getListHistory({
    required String listId,
    required String Function(String userId) resolveName,
    String? Function(String userId)? resolveAvatar,
  }) async {
    try {
      final res = await _ds.getListHistory(listId: listId);
      final data = res.data;
      if (data is! List) {
        return const ResultError(ValidationFailure('استجابة غير متوقعة من الخادم'));
      }
      return Success(data
          .map((e) => HistoryModel.fromApi(
                e as Map<String, dynamic>,
                resolveName: resolveName,
                resolveAvatar: resolveAvatar,
              ))
          .toList());
    } on NetworkException catch (e) {
      return ResultError(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return ResultError(ServerFailure(e.message));
    } catch (_) {
      return const ResultError(ServerFailure());
    }
  }

  @override
  Future<Result<Failure, List<TripHistoryEntry>>> getListTrips({
    required String listId,
  }) async {
    try {
      final res = await _ds.getListTrips(listId: listId);
      final data = res.data;
      if (data is! List) {
        return const ResultError(ValidationFailure('استجابة غير متوقعة من الخادم'));
      }
      return Success(data
          .map((e) => TripHistoryEntry.fromApi(e as Map<String, dynamic>))
          .toList());
    } on NetworkException catch (e) {
      return ResultError(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return ResultError(ServerFailure(e.message));
    } catch (_) {
      return const ResultError(ServerFailure());
    }
  }
}
