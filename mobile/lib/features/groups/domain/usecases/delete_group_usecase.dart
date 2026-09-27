import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/group_repository.dart';

class DeleteGroupParams {
  const DeleteGroupParams(this.groupId);
  final String groupId;
}

class DeleteGroupUseCase implements UseCase<void, DeleteGroupParams> {
  DeleteGroupUseCase(this._repo);
  final GroupRepository _repo;

  @override
  Future<Result<Failure, void>> call(DeleteGroupParams params) {
    return _repo.deleteGroup(groupId: params.groupId);
  }
}
