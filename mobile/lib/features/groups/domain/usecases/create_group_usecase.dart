import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/group.dart';
import '../repositories/group_repository.dart';

class CreateGroupParams {
  const CreateGroupParams({required this.name, this.icon, this.type = 'household'});
  final String name;
  final String? icon;
  final String type;
}

class CreateGroupUseCase implements UseCase<Group, CreateGroupParams> {
  CreateGroupUseCase(this._repo);
  final GroupRepository _repo;

  @override
  Future<Result<Failure, Group>> call(CreateGroupParams params) {
    return _repo.createGroup(name: params.name, icon: params.icon, type: params.type);
  }
}
