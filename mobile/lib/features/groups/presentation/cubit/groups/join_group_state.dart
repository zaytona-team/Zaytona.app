part of 'join_group_cubit.dart';

sealed class JoinGroupState {}

final class JoinGroupInitial extends JoinGroupState {}

final class JoinGroupLoading extends JoinGroupState {}

final class JoinGroupSuccess extends JoinGroupState {
  JoinGroupSuccess(this.group);
  final Group group;
}

final class JoinGroupError extends JoinGroupState {
  JoinGroupError(this.message);
  final String message;
}
