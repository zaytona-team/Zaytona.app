import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/group.dart';
import '../repositories/group_repository.dart';

class GetGroupParams {
  const GetGroupParams(this.groupId);
  final String groupId;
}

class GetGroupUseCase implements UseCase<Group, GetGroupParams> {
  GetGroupUseCase(this._repo);
  final GroupRepository _repo;

  @override
  Future<Result<Failure, Group>> call(GetGroupParams params) {
    return _repo.getGroup(groupId: params.groupId);
  }
}
