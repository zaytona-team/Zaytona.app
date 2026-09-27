part of 'list_groups_cubit.dart';

sealed class ListGroupsState {}

final class ListGroupsInitial extends ListGroupsState {}

final class ListGroupsLoading extends ListGroupsState {}

final class ListGroupsLoaded extends ListGroupsState {
  ListGroupsLoaded(this.groups, {this.refreshError});
  final List<Group> groups;

  ///for team: Set when a refresh() failed after this list was already loaded. 
  final String? refreshError;
}


final class ListGroupsRefreshing extends ListGroupsState {
  ListGroupsRefreshing(this.groups);
  final List<Group> groups;
}

final class ListGroupsError extends ListGroupsState {
  ListGroupsError(this.message);
  final String message;
}