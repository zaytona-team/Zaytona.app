import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/list_item.dart';
import '../repositories/item_repository.dart';

class UpdateItemParams {
  const UpdateItemParams({required this.listId, required this.item});
  final String listId;
  final ListItem item;
}

class UpdateItemUseCase implements UseCase<ListItem, UpdateItemParams> {
  UpdateItemUseCase(this._repo);
  final ItemRepository _repo;

  @override
  Future<Result<Failure, ListItem>> call(UpdateItemParams params) {
    return _repo.updateItem(listId: params.listId, item: params.item);
  }
}
