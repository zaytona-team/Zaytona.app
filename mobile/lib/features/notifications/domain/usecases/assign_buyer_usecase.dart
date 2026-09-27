import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/notification_repository.dart';

class AssignBuyerParams {
  const AssignBuyerParams({required this.listId, required this.memberId});
  final String listId;
  final String memberId;
}

class AssignBuyerUseCase implements UseCase<void, AssignBuyerParams> {
  AssignBuyerUseCase(this._repo);
  final NotificationRepository _repo;

  @override
  Future<Result<Failure, void>> call(AssignBuyerParams params) {
    return _repo.assignBuyer(
      listId: params.listId,
      memberId: params.memberId,
    );
  }
}
