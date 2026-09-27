part of 'group_lists_cubit.dart';

sealed class GroupListsState {}

final class GroupListsInitial extends GroupListsState {}

final class GroupListsLoading extends GroupListsState {}

final class GroupListsLoaded extends GroupListsState {
  GroupListsLoaded(this.lists);
  final List<ShoppingList> lists;
}

final class GroupListsError extends GroupListsState {
  GroupListsError(this.message);
  final String message;
}
