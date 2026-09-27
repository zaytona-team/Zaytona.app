import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/group_repository.dart';

class TransferAdminParams {
  const TransferAdminParams({required this.groupId, required this.userId});
  final String groupId;
  final String userId;
}

/// Atomic per business rule: the backend assigns the new admin and removes
/// the current admin's role in the same operation.
class TransferAdminUseCase implements UseCase<void, TransferAdminParams> {
  TransferAdminUseCase(this._repo);
  final GroupRepository _repo;

  @override
  Future<Result<Failure, void>> call(TransferAdminParams params) {
    return _repo.transferAdmin(groupId: params.groupId, userId: params.userId);
  }
}
