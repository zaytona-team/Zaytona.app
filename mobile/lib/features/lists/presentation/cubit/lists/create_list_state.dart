part of 'create_list_cubit.dart';

sealed class CreateListState {}

final class CreateListInitial extends CreateListState {}

final class CreateListLoading extends CreateListState {}

final class CreateListSuccess extends CreateListState {
  CreateListSuccess(this.list);
  final ShoppingList list;
}

final class CreateListError extends CreateListState {
  CreateListError(this.message);
  final String message;
}
