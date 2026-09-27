import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/active_trip.dart';
import '../repositories/notification_repository.dart';

class GetActiveTripParams {
  const GetActiveTripParams(this.listId);
  final String listId;
}

class GetActiveTripUseCase implements UseCase<ActiveTrip?, GetActiveTripParams> {
  GetActiveTripUseCase(this._repo);
  final NotificationRepository _repo;

  @override
  Future<Result<Failure, ActiveTrip?>> call(GetActiveTripParams params) {
    return _repo.getActiveTrip(listId: params.listId);
  }
}
