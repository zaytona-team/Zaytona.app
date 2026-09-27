import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/notification_repository.dart';

class HeadingToStoreParams {
  const HeadingToStoreParams(this.listId);
  final String listId;
}

class HeadingToStoreUseCase implements UseCase<void, HeadingToStoreParams> {
  HeadingToStoreUseCase(this._repo);
  final NotificationRepository _repo;

  @override
  Future<Result<Failure, void>> call(HeadingToStoreParams params) {
    return _repo.headingToStore(listId: params.listId);
  }
}
