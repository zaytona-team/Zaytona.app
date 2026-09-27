import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/token_storage.dart';
import '../../../../../core/realtime/socket_service.dart';
import '../../../domain/entities/group.dart';
import '../../../domain/entities/group_member.dart';
import '../../../domain/usecases/delete_group_usecase.dart';
import '../../../domain/usecases/get_group_members_usecase.dart';
import '../../../domain/usecases/get_group_usecase.dart';
import '../../../domain/usecases/leave_group_usecase.dart';
import '../../../domain/usecases/remove_member_usecase.dart';
import '../../../domain/usecases/transfer_admin_usecase.dart';
import '../../../domain/usecases/update_group_usecase.dart';
import 'list_groups_cubit.dart';

part 'group_settings_state.dart';

/// Group settings screen state: loads group + members together, runs
/// mutations with a per-action in-flight flag, reloads after each success.
///
/// Also stays live via Socket.IO: any relevant group.* event just reloads
/// (matching this cubit's existing reload-not-patch convention), except a
/// removal/deletion that affects the current user, which closes the
/// screen via [GroupSettingsClosed] instead of reloading a group they can
/// no longer see.
class GroupSettingsCubit extends Cubit<GroupSettingsState> {
  GroupSettingsCubit(
    this._getGroup,
    this._getMembers,
    this._updateGroup,
    this._removeMember,
    this._transferAdmin,
    this._leaveGroup,
    this._deleteGroup,
    this._listGroupsCubit,
    this._socketService,
  ) : super(GroupSettingsInitial());

  final GetGroupUseCase _getGroup;
  final GetGroupMembersUseCase _getMembers;
  final UpdateGroupUseCase _updateGroup;
  final RemoveMemberUseCase _removeMember;
  final TransferAdminUseCase _transferAdmin;
  final LeaveGroupUseCase _leaveGroup;
  final DeleteGroupUseCase _deleteGroup;
  final ListGroupsCubit _listGroupsCubit;
  final SocketService _socketService;

  final List<StreamSubscription<Map<String, dynamic>>> _socketSubs = [];

  Future<void> load(String groupId) async {
    emit(GroupSettingsLoading());
    final groupResult = await _getGroup(GetGroupParams(groupId));
    await groupResult.fold(
      (failure) async => emit(GroupSettingsError(failure.message)),
      (group) async {
        if (group.isPrivate) {
          emit(GroupSettingsLoaded(group: group, members: const []));
          return;
        }
        final membersResult = await _getMembers(GetGroupMembersParams(groupId));
        membersResult.fold(
          (failure) => emit(GroupSettingsError(failure.message)),
          (members) => emit(GroupSettingsLoaded(group: group, members: members)),
        );
      },
    );
    await _subscribeToRealtime(groupId);
  }

  Future<void> _subscribeToRealtime(String groupId) async {
    for (final sub in _socketSubs) {
      await sub.cancel();
    }
    _socketSubs.clear();
    final myId = await TokenStorage.readUserId();

    void listen(String event, void Function(Map<String, dynamic>) handler) {
      _socketSubs.add(_socketService.on(event).listen((data) {
        if (data['group_id'] != groupId) return;
        handler(data);
      }));
    }

    listen('group.member_joined', (_) => load(groupId));
    listen('group.member_removed', (data) {
      if (data['target_user_id'] == myId) {
        emit(GroupSettingsClosed());
      } else {
        load(groupId);
      }
    });
    listen('group.admin_transferred', (_) => load(groupId));
    listen('group.member_left', (_) => load(groupId));
    listen('group.updated', (_) => load(groupId));
    listen('group.deleted', (_) => emit(GroupSettingsClosed()));
  }

  @override
  Future<void> close() async {
    for (final sub in _socketSubs) {
      await sub.cancel();
    }
    return super.close();
  }

  Future<void> updateIdentity({String? name, String? icon}) async {
    final current = state;
    if (current is! GroupSettingsLoaded || current.actionInFlight) return;
    emit(current.copyWith(actionInFlight: true));
    final result = await _updateGroup(UpdateGroupParams(
      groupId: current.group.groupId,
      name: name,
      icon: icon,
    ));
    result.fold(
      (failure) => emit(
          current.copyWith(actionInFlight: false, actionError: failure.message)),
      (group) {
        _listGroupsCubit.upsertGroup(group);
        emit(current.copyWith(group: group, actionInFlight: false));
      },
    );
  }

  Future<void> removeMember(String userId) async {
    await _mutateAndReload(
      (groupId) => _removeMember(
        RemoveMemberParams(groupId: groupId, userId: userId),
      ),
    );
  }

  Future<void> transferAdmin(String userId) async {
    await _mutateAndReload(
      (groupId) => _transferAdmin(
        TransferAdminParams(groupId: groupId, userId: userId),
      ),
    );
  }

  Future<void> leave() async {
    await _closeGroup((groupId) => _leaveGroup(LeaveGroupParams(groupId)));
  }

  Future<void> deleteGroup() async {
    await _closeGroup((groupId) => _deleteGroup(DeleteGroupParams(groupId)));
  }

  Future<void> _mutateAndReload(Future<dynamic> Function(String) action) async {
    final current = state;
    if (current is! GroupSettingsLoaded || current.actionInFlight) return;
    emit(current.copyWith(actionInFlight: true));
    final result = await action(current.group.groupId);
    await result.fold(
      (failure) async => emit(
          current.copyWith(actionInFlight: false, actionError: failure.message)),
      (_) async => load(current.group.groupId),
    );
  }

  Future<void> _closeGroup(Future<dynamic> Function(String) action) async {
    final current = state;
    if (current is! GroupSettingsLoaded || current.actionInFlight) return;
    emit(current.copyWith(actionInFlight: true));
    final result = await action(current.group.groupId);
    result.fold(
      (failure) => emit(
          current.copyWith(actionInFlight: false, actionError: failure.message)),
      (_) {
        _listGroupsCubit.removeGroup(current.group.groupId);
        emit(GroupSettingsClosed());
      },
    );
  }
}