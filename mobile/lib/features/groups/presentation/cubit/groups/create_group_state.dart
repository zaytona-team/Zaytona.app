part of 'create_group_cubit.dart';

sealed class CreateGroupState {}

final class CreateGroupInitial extends CreateGroupState {}

final class CreateGroupLoading extends CreateGroupState {}

final class CreateGroupSuccess extends CreateGroupState {
  CreateGroupSuccess(this.group);
  final Group group;
}

final class CreateGroupError extends CreateGroupState {
  CreateGroupError(this.message);
  final String message;
}
