import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/shopping_list.dart';
import '../repositories/list_repository.dart';

class CreateListParams {
  const CreateListParams({required this.groupId, required this.name});
  final String groupId;
  final String name;
}

class CreateListUseCase implements UseCase<ShoppingList, CreateListParams> {
  CreateListUseCase(this._repo);
  final ListRepository _repo;

  @override
  Future<Result<Failure, ShoppingList>> call(CreateListParams params) {
    return _repo.createList(groupId: params.groupId, name: params.name);
  }
}
