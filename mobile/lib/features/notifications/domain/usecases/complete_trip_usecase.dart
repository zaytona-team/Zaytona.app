import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/notification_repository.dart';

class CompleteTripParams {
  const CompleteTripParams(this.tripId);
  final String tripId;
}

class CompleteTripUseCase implements UseCase<void, CompleteTripParams> {
  CompleteTripUseCase(this._repo);
  final NotificationRepository _repo;

  @override
  Future<Result<Failure, void>> call(CompleteTripParams params) {
    return _repo.completeTrip(tripId: params.tripId);
  }
}
