import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/group_repository.dart';

class RemoveMemberParams {
  const RemoveMemberParams({required this.groupId, required this.userId});
  final String groupId;
  final String userId;
}

class RemoveMemberUseCase implements UseCase<void, RemoveMemberParams> {
  RemoveMemberUseCase(this._repo);
  final GroupRepository _repo;

  @override
  Future<Result<Failure, void>> call(RemoveMemberParams params) {
    return _repo.removeMember(groupId: params.groupId, userId: params.userId);
  }
}
