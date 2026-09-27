import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/notification_repository.dart';

class RemindMeParams {
  const RemindMeParams(this.listId);
  final String listId;
}

class RemindMeUseCase implements UseCase<void, RemindMeParams> {
  RemindMeUseCase(this._repo);
  final NotificationRepository _repo;

  @override
  Future<Result<Failure, void>> call(RemindMeParams params) {
    return _repo.remindMe(listId: params.listId);
  }
}
