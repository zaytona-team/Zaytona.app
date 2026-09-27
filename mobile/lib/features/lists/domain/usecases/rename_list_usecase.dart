import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/shopping_list.dart';
import '../repositories/list_repository.dart';

class RenameListParams {
  const RenameListParams({required this.listId, required this.name, this.color});

  final String listId;
  final String name;
  final String? color;
}

class RenameListUseCase implements UseCase<ShoppingList, RenameListParams> {
  RenameListUseCase(this._repo);

  final ListRepository _repo;

  @override
  Future<Result<Failure, ShoppingList>> call(RenameListParams params) {
    return _repo.updateList(
      listId: params.listId,
      name: params.name,
      color: params.color,
    );
  }
}
