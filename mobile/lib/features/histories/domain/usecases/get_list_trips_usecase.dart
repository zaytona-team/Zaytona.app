import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/trip_history_entry.dart';
import '../repositories/history_repository.dart';

class GetListTripsParams {
  const GetListTripsParams(this.listId);
  final String listId;
}

class GetListTripsUseCase {
  GetListTripsUseCase(this._repo);
  final HistoryRepository _repo;

  Future<Result<Failure, List<TripHistoryEntry>>> call(
    GetListTripsParams params,
  ) {
    return _repo.getListTrips(listId: params.listId);
  }
}
