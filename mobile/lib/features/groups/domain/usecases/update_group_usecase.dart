import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/group.dart';
import '../repositories/group_repository.dart';

class UpdateGroupParams {
  const UpdateGroupParams({required this.groupId, this.name, this.icon});
  final String groupId;
  final String? name;
  final String? icon;
}

class UpdateGroupUseCase implements UseCase<Group, UpdateGroupParams> {
  UpdateGroupUseCase(this._repo);
  final GroupRepository _repo;

  @override
  Future<Result<Failure, Group>> call(UpdateGroupParams params) {
    return _repo.updateGroup(
      groupId: params.groupId,
      name: params.name,
      icon: params.icon,
    );
  }
}
