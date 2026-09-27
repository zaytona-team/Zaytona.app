part of 'get_group_cubit.dart';

sealed class GetGroupState {}

final class GetGroupInitial extends GetGroupState {}

final class GetGroupLoading extends GetGroupState {}

final class GetGroupLoaded extends GetGroupState {
  GetGroupLoaded(this.group, {this.members = const []});
  final Group group;
  final List<GroupMember> members;
}

final class GetGroupError extends GetGroupState {
  GetGroupError(this.message);
  final String message;
}
