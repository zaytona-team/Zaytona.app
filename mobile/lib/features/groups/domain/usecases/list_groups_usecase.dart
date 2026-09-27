import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/group.dart';
import '../repositories/group_repository.dart';

class ListGroupsUseCase implements UseCase<List<Group>, NoParams> {
  ListGroupsUseCase(this._repo);
  final GroupRepository _repo;

  @override
  Future<Result<Failure, List<Group>>> call(NoParams params) {
    return _repo.listMyGroups();
  }
}
