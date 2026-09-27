import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/list_item.dart';
import '../repositories/item_repository.dart';

class GetListItemsParams {
  const GetListItemsParams(this.listId);
  final String listId;
}

class GetListItemsUseCase
    implements UseCase<List<ListItem>, GetListItemsParams> {
  GetListItemsUseCase(this._repo);
  final ItemRepository _repo;

  @override
  Future<Result<Failure, List<ListItem>>> call(GetListItemsParams params) {
    return _repo.getListItems(listId: params.listId);
  }
}
