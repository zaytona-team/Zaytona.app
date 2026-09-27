import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/shopping_list.dart';
import '../repositories/list_repository.dart';

class GetListParams {
  const GetListParams(this.listId);
  final String listId;
}

class GetListUseCase implements UseCase<ShoppingList, GetListParams> {
  GetListUseCase(this._repo);
  final ListRepository _repo;

  @override
  Future<Result<Failure, ShoppingList>> call(GetListParams params) {
    return _repo.getList(listId: params.listId);
  }
}
