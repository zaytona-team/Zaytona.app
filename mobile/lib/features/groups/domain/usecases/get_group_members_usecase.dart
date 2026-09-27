import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/group_member.dart';
import '../repositories/group_repository.dart';

class GetGroupMembersParams {
  const GetGroupMembersParams(this.groupId);
  final String groupId;
}

class GetGroupMembersUseCase
    implements UseCase<List<GroupMember>, GetGroupMembersParams> {
  GetGroupMembersUseCase(this._repo);
  final GroupRepository _repo;

  @override
  Future<Result<Failure, List<GroupMember>>> call(GetGroupMembersParams params) {
    return _repo.getMembers(groupId: params.groupId);
  }
}
