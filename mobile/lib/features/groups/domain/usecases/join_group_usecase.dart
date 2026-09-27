import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/group.dart';
import '../repositories/group_repository.dart';

class JoinGroupParams {
  const JoinGroupParams(this.inviteCode);
  final String inviteCode;
}

class JoinGroupUseCase implements UseCase<Group, JoinGroupParams> {
  JoinGroupUseCase(this._repo);
  final GroupRepository _repo;

  @override
  Future<Result<Failure, Group>> call(JoinGroupParams params) {
    return _repo.joinGroup(inviteCode: params.inviteCode);
  }
}
