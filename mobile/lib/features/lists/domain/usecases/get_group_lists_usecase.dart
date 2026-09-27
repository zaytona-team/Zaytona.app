import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/shopping_list.dart';
import '../repositories/list_repository.dart';

class GetGroupListsParams {
  const GetGroupListsParams(this.groupId);
  final String groupId;
}

class GetGroupListsUseCase
    implements UseCase<List<ShoppingList>, GetGroupListsParams> {
  GetGroupListsUseCase(this._repo);
  final ListRepository _repo;

  @override
  Future<Result<Failure, List<ShoppingList>>> call(GetGroupListsParams params) {
    return _repo.getGroupLists(groupId: params.groupId);
  }
}
