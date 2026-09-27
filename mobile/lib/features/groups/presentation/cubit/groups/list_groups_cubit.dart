import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/realtime/socket_service.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../domain/entities/group.dart';
import '../../../domain/usecases/list_groups_usecase.dart';

part 'list_groups_state.dart';

/// Shared app singleton from injection. Subscribes to group.* events once,
/// for the whole process lifetime — every group screen reads from this one
/// cubit, so there's nothing page-scoped to unsubscribe.
class ListGroupsCubit extends Cubit<ListGroupsState> {
  ListGroupsCubit(this._listGroupsUseCase, this._socketService)
      : super(ListGroupsInitial()) {
    _subscribeToRealtime();
  }
  final ListGroupsUseCase _listGroupsUseCase;
  final SocketService _socketService;

  bool _isFetching = false;

  /// Fetches only if there's no  data yet.
  Future<void> load() => _fetch(force: false);

  /// Always fetches fresh data, even if groups are already loaded.
  Future<void> refresh() => _fetch(force: true);

  Future<void> _fetch({required bool force}) async {
    if (_isFetching) return;
    final current = state;
    if (!force && current is ListGroupsLoaded) return;

    final existingGroups = switch (current) {
      ListGroupsLoaded(:final groups) => groups,
      ListGroupsRefreshing(:final groups) => groups,
      _ => null,
    };

    _isFetching = true;
    emit(existingGroups != null
        ? ListGroupsRefreshing(existingGroups)
        : ListGroupsLoading());

    final result = await _listGroupsUseCase(const NoParams());
    _isFetching = false;
    if (isClosed) return;

    result.fold(
      (failure) {
        if (existingGroups != null) {
          emit(ListGroupsLoaded(existingGroups, refreshError: failure.message));
        } else {
          emit(ListGroupsError(failure.message));
        }
      },
      (groups) => emit(ListGroupsLoaded(groups)),
    );
  }

  void clear() => emit(ListGroupsInitial());

  void upsertGroup(Group group) {
    final current = state;
    if (current is! ListGroupsLoaded) return;
    final groups = [...current.groups];
    final index = groups.indexWhere((g) => g.groupId == group.groupId);
    if (index == -1) {
      groups.add(group);
    } else {
      groups[index] = group;
    }
    emit(ListGroupsLoaded(groups));
  }

  void removeGroup(String groupId) {
    final current = state;
    if (current is! ListGroupsLoaded) return;
    emit(ListGroupsLoaded(
      current.groups.where((g) => g.groupId != groupId).toList(),
    ));
  }

  /// Merges a partial group update (e.g. from group.updated, whose payload
  /// doesn't carry member_count/role) into the existing entry rather than
  /// overwriting it — a blind [upsertGroup] here would blank those fields
  /// for every other member's view.
  void patchGroup(Group incoming) {
    final current = state;
    if (current is! ListGroupsLoaded) return;
    final groups = [...current.groups];
    final index = groups.indexWhere((g) => g.groupId == incoming.groupId);
    if (index == -1) return;
    final existing = groups[index];
    groups[index] = incoming.copyWith(
      memberCount: incoming.memberCount ?? existing.memberCount,
      role: incoming.role ?? existing.role,
    );
    emit(ListGroupsLoaded(groups));
  }

  void _subscribeToRealtime() {
    _socketService.on('group.updated').listen((data) {
      final group = data['group'];
      if (group is Map<String, dynamic>) patchGroup(Group.fromJson(group));
    });
    _socketService.on('group.deleted').listen((data) {
      final groupId = data['group_id'] as String?;
      if (groupId != null) removeGroup(groupId);
    });
    // Personal channel: this user's own membership just changed (join,
    // removal, leave, or their solo-leave deleting the group). See
    // GroupFacadeMixin — every branch that fires this also fires a
    // group-room event, but that room is exactly the one this user's
    // membership just changed for, so only the personal channel is
    // reliable here.
    _socketService.on('group.membership_changed').listen((data) {
      final reason = data['reason'] as String?;
      if (reason == 'joined') {
        final group = data['group'];
        if (group is Map<String, dynamic>) upsertGroup(Group.fromJson(group));
      } else {
        final groupId = data['group_id'] as String?;
        if (groupId != null) removeGroup(groupId);
      }
    });
  }
}
