part of 'group_settings_cubit.dart';

sealed class GroupSettingsState {}

final class GroupSettingsInitial extends GroupSettingsState {}

final class GroupSettingsLoading extends GroupSettingsState {}

final class GroupSettingsLoaded extends GroupSettingsState {
  GroupSettingsLoaded({
    required this.group,
    required this.members,
    this.actionInFlight = false,
    this.actionError,
  });

  final Group group;
  final List<GroupMember> members;

  /// True while a mutation (rename, remove, transfer…) is running so the
  /// page can disable actions without losing the loaded content.
  final bool actionInFlight;

  /// Message of the last failed mutation, cleared on the next action.
  final String? actionError;

  GroupSettingsLoaded copyWith({
    Group? group,
    List<GroupMember>? members,
    bool? actionInFlight,
    String? actionError,
  }) {
    return GroupSettingsLoaded(
      group: group ?? this.group,
      members: members ?? this.members,
      actionInFlight: actionInFlight ?? this.actionInFlight,
      actionError: actionError,
    );
  }
}

final class GroupSettingsError extends GroupSettingsState {
  GroupSettingsError(this.message);
  final String message;
}

/// The group is gone for this user (left or deleted) — navigate away.
final class GroupSettingsClosed extends GroupSettingsState {}
