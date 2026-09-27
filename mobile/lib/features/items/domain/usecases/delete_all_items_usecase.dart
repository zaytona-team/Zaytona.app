import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/item_repository.dart';

class DeleteAllItemsParams {
  const DeleteAllItemsParams({required this.listId});
  final String listId;
}

class DeleteAllItemsUseCase implements UseCase<void, DeleteAllItemsParams> {
  DeleteAllItemsUseCase(this._repo);
  final ItemRepository _repo;

  @override
  Future<Result<Failure, void>> call(DeleteAllItemsParams params) {
    return _repo.deleteAllItems(listId: params.listId);
  }
}
