import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/list_item.dart';
import '../repositories/item_repository.dart';

class SetPurchasedParams {
  const SetPurchasedParams({
    required this.listId,
    required this.listItemId,
    required this.isBought,
  });

  final String listId;
  final String listItemId;
  final bool isBought;
}

/// Check/uncheck an item while buying — the only mutation Buying View allows.
class SetPurchasedUseCase implements UseCase<ListItem, SetPurchasedParams> {
  SetPurchasedUseCase(this._repo);
  final ItemRepository _repo;

  @override
  Future<Result<Failure, ListItem>> call(SetPurchasedParams params) {
    return _repo.setPurchased(
      listId: params.listId,
      listItemId: params.listItemId,
      isBought: params.isBought,
    );
  }
}
