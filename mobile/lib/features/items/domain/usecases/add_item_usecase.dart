import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/list_item.dart';
import '../repositories/item_repository.dart';

class AddItemParams {
  const AddItemParams({
    required this.listId,
    required this.name,
    required this.quantity,
    required this.unit,
    this.categoryId,
    this.notes,
    this.brand,
    this.isUrgent = false,
  });

  final String listId;
  final String name;
  final double quantity;
  final String unit;
  final String? categoryId;
  final String? notes;
  final String? brand;
  final bool isUrgent;
}

class AddItemUseCase implements UseCase<ListItem, AddItemParams> {
  AddItemUseCase(this._repo);
  final ItemRepository _repo;

  @override
  Future<Result<Failure, ListItem>> call(AddItemParams params) {
    return _repo.addItem(
      listId: params.listId,
      name: params.name,
      quantity: params.quantity,
      unit: params.unit,
      categoryId: params.categoryId,
      notes: params.notes,
      brand: params.brand,
      isUrgent: params.isUrgent,
    );
  }
}
