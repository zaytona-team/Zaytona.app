import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/group_repository.dart';

class LeaveGroupParams {
  const LeaveGroupParams(this.groupId);
  final String groupId;
}

class LeaveGroupUseCase implements UseCase<void, LeaveGroupParams> {
  LeaveGroupUseCase(this._repo);
  final GroupRepository _repo;

  @override
  Future<Result<Failure, void>> call(LeaveGroupParams params) {
    return _repo.leaveGroup(groupId: params.groupId);
  }
}
