import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/item_repository.dart';

class DeleteItemParams {
  const DeleteItemParams({required this.listId, required this.listItemId});
  final String listId;
  final String listItemId;
}

class DeleteItemUseCase implements UseCase<void, DeleteItemParams> {
  DeleteItemUseCase(this._repo);
  final ItemRepository _repo;

  @override
  Future<Result<Failure, void>> call(DeleteItemParams params) {
    return _repo.deleteItem(
      listId: params.listId,
      listItemId: params.listItemId,
    );
  }
}
