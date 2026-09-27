import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/realtime/socket_service.dart';
import '../../../groups/domain/entities/group_member.dart';
import '../../../groups/domain/usecases/get_group_members_usecase.dart';
import '../../domain/entities/history_model.dart';
import '../../domain/entities/trip_history_entry.dart';
import '../../domain/usecases/get_list_trips_usecase.dart';
import '../../domain/usecases/get_list_history_usecase.dart';

part 'history_state.dart';

/// Activity log (Story 8) + previous trips. Loads the group's members
/// first (to resolve each entry's user_id to a display name — the
/// history endpoint doesn't return names itself), then the list's
/// history and the list's completed trips together.
///
/// Also stays live via Socket.IO: every history entry is written as a
/// side effect of an item mutation (see ItemFacadeMixin) — there's no
/// dedicated history.* event on the backend, so this just reloads on the
/// same item.* events ListItemsCubit already reacts to, plus
/// trip.completed/.cancelled for the trips tab.
class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit(
    this._getListHistory,
    this._getMembers,
    this._getListTrips,
    this._socketService,
  ) : super(HistoryInitial());

  final GetListHistoryUseCase _getListHistory;
  final GetGroupMembersUseCase _getMembers;
  final GetListTripsUseCase _getListTrips;
  final SocketService _socketService;

  final List<StreamSubscription<Map<String, dynamic>>> _socketSubs = [];

  String? _groupId;
  String? _listId;

  Future<void> reload() {
    final groupId = _groupId;
    final listId = _listId;
    if (groupId == null || listId == null) return Future.value();
    return load(groupId, listId);
  }

  Future<void> load(String groupId, String listId) async {
    _groupId = groupId;
    _listId = listId;
    emit(HistoryLoading());
    final members = await _members(groupId);
    final historyResult = await _getListHistory(GetListHistoryParams(
      listId: listId,
      resolveName: (userId) =>
          members[userId]?.name.isNotEmpty == true
              ? members[userId]!.name
              : 'عضو محذوف',
      resolveAvatar: (userId) => members[userId]?.avatar,
    ));
    // Trips are fetched (and shown) independently of the per-list activity
    // log — a failure on one must not hide data the other already has.
    final tripsResult = await _getListTrips(GetListTripsParams(listId));
    final trips = tripsResult.fold(
      (_) => const <TripHistoryEntry>[],
      (trips) => _resolveBuyers(trips, members),
    );
    historyResult.fold(
      (failure) => emit(HistoryLoaded(const [], trips: trips)),
      (entries) => emit(HistoryLoaded(entries, trips: trips)),
    );
    _subscribeToRealtime(groupId, listId);
  }

  void _subscribeToRealtime(String groupId, String listId) {
    for (final sub in _socketSubs) {
      sub.cancel();
    }
    _socketSubs.clear();

    void listenOnList(String event) {
      _socketSubs.add(_socketService.on(event).listen((data) {
        if (data['list_id'] != listId) return;
        reload();
      }));
    }

    void listenOnGroup(String event) {
      _socketSubs.add(_socketService.on(event).listen((data) {
        if (data['group_id'] != groupId) return;
        reload();
      }));
    }

    listenOnList('item.added');
    listenOnList('item.updated');
    listenOnList('item.deleted');
    listenOnList('item.bulk_deleted');
    listenOnList('item.purchased');
    listenOnList('item.unpurchased');
    listenOnGroup('trip.completed');
    listenOnGroup('trip.cancelled');
  }

  @override
  Future<void> close() async {
    for (final sub in _socketSubs) {
      await sub.cancel();
    }
    return super.close();
  }

  Future<Map<String, GroupMember>> _members(String groupId) async {
    final result = await _getMembers(GetGroupMembersParams(groupId));
    return result.fold(
      (_) => const <String, GroupMember>{},
      (members) => {for (final m in members) m.userId: m},
    );
  }

  /// The backend's `buyer_name` reflects whoever was last assigned via the
  /// notification flow, which isn't necessarily who actually ran the trip
  /// — completion is restricted server-side to the trip's buyer_id, so
  /// buyer_id is the trustworthy field. Resolve the display name from the
  /// group's current member list instead of trusting buyer_name directly.
  List<TripHistoryEntry> _resolveBuyers(
    List<TripHistoryEntry> trips,
    Map<String, GroupMember> members,
  ) {
    return [
      for (final trip in trips)
        members[trip.buyerId]?.name.isNotEmpty == true
            ? trip.withBuyer(
                members[trip.buyerId]!.name,
                members[trip.buyerId]!.avatar,
              )
            : trip,
    ];
  }
}
