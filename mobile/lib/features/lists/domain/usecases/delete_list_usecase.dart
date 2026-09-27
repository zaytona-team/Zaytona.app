import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/list_repository.dart';

class DeleteListParams {
  const DeleteListParams({
    required this.groupId,
    required this.listId,
  });

  final String groupId;
  final String listId;
}

class DeleteListUseCase implements UseCase<void, DeleteListParams> {
  DeleteListUseCase(this._repo);

  final ListRepository _repo;

  @override
  Future<Result<Failure, void>> call(DeleteListParams params) {
    return _repo.deleteList(
      groupId: params.groupId,
      listId: params.listId,
    );
  }
}