import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/realtime/socket_service.dart';
import '../../../domain/entities/shopping_list.dart';
import '../../../domain/usecases/delete_list_usecase.dart';
import '../../../domain/usecases/get_group_lists_usecase.dart';

part 'group_lists_state.dart';

/// Also stays live via Socket.IO: list.created/.updated/.deleted/.completed
/// and list.items_imported (recipe import) all just reload — the socket
/// payloads don't carry the per-list item/bought/urgent counts this screen
/// shows, which only [GetGroupListsUseCase] computes, so there's nothing
/// cheaper to patch in place with.
class GroupListsCubit extends Cubit<GroupListsState> {
  GroupListsCubit(this._getGroupListsUseCase, this._deleteListUseCase, this._socketService)
      : super(GroupListsInitial());
  final GetGroupListsUseCase _getGroupListsUseCase;
  final DeleteListUseCase _deleteListUseCase;
  final SocketService _socketService;

  final List<StreamSubscription<Map<String, dynamic>>> _socketSubs = [];

  Future<void> load(String groupId) async {
    emit(GroupListsLoading());
    final result = await _getGroupListsUseCase(GetGroupListsParams(groupId));
    result.fold(
      (failure) => emit(GroupListsError(failure.message)),
      (lists) => emit(GroupListsLoaded(lists)),
    );
    _subscribeToRealtime(groupId);
  }

  void _subscribeToRealtime(String groupId) {
    for (final sub in _socketSubs) {
      sub.cancel();
    }
    _socketSubs.clear();

    void listen(String event) {
      _socketSubs.add(_socketService.on(event).listen((data) {
        if (data['group_id'] != groupId) return;
        load(groupId);
      }));
    }

    listen('list.created');
    listen('list.updated');
    listen('list.deleted');
    listen('list.completed');
    listen('list.items_imported');
  }

  Future<bool> deleteList({
    required String groupId,
    required String listId,
  }) async {
    final currentState = state;

    final result = await _deleteListUseCase(
      DeleteListParams(
        groupId: groupId,
        listId: listId,
      ),
    );

    return result.fold(
      (failure) {
        emit(GroupListsError(failure.message));
        return false;
      },
      (_) {
        if (currentState is GroupListsLoaded) {
          emit(
            GroupListsLoaded(
              currentState.lists
                  .where((list) => list.listId != listId)
                  .toList(),
            ),
          );
        }

        return true;
      },
    );
  }

  @override
  Future<void> close() async {
    for (final sub in _socketSubs) {
      await sub.cancel();
    }
    return super.close();
  }
}
