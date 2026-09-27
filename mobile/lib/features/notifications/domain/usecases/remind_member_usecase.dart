import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/notification_repository.dart';

class RemindMemberParams {
  const RemindMemberParams({required this.listId, required this.memberId});
  final String listId;
  final String memberId;
}

class RemindMemberUseCase implements UseCase<void, RemindMemberParams> {
  RemindMemberUseCase(this._repo);
  final NotificationRepository _repo;

  @override
  Future<Result<Failure, void>> call(RemindMemberParams params) {
    return _repo.remindMember(
      listId: params.listId,
      memberId: params.memberId,
    );
  }
}
