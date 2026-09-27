import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/history_model.dart';
import '../repositories/history_repository.dart';

class GetListHistoryParams {
  const GetListHistoryParams({
    required this.listId,
    required this.resolveName,
    this.resolveAvatar,
  });
  final String listId;
  final String Function(String userId) resolveName;
  final String? Function(String userId)? resolveAvatar;
}

class GetListHistoryUseCase {
  GetListHistoryUseCase(this._repo);
  final HistoryRepository _repo;

  Future<Result<Failure, List<HistoryModel>>> call(GetListHistoryParams params) {
    return _repo.getListHistory(
      listId: params.listId,
      resolveName: params.resolveName,
      resolveAvatar: params.resolveAvatar,
    );
  }
}
