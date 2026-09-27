import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/token_storage.dart';
import '../../../../../core/realtime/socket_service.dart';
import '../../../../notifications/domain/entities/active_trip.dart';
import '../../../../notifications/domain/usecases/assign_buyer_usecase.dart';
import '../../../../notifications/domain/usecases/get_active_trip_usecase.dart';

part 'active_trip_state.dart';

/// Resolves whether a list currently has a locked-in buyer, and lets the
/// caller claim the buyer spot for themselves. Backed by the same
/// `/trips` endpoints used for trip alerts (US-38: one buyer per trip).
///
/// Also stays live via Socket.IO: once [load] is called for a list, this
/// cubit keeps listening for trip.assigned/.completed/.cancelled on that
/// list so every group member's screen reflects the same trip state
/// without polling. `trip.heading_out`/`trip.asked` have no slot here (no
/// "trip" object changes) — a page that wants those banners subscribes to
/// `SocketService.on(...)` directly.
class ActiveTripCubit extends Cubit<ActiveTripState> {
  ActiveTripCubit(this._getActiveTrip, this._assignBuyer, this._socketService)
      : super(ActiveTripInitial());

  final GetActiveTripUseCase _getActiveTrip;
  final AssignBuyerUseCase _assignBuyer;
  final SocketService _socketService;

  final List<StreamSubscription<Map<String, dynamic>>> _socketSubs = [];

  Future<void> load(String listId) async {
    emit(ActiveTripLoading());
    final result = await _getActiveTrip(GetActiveTripParams(listId));
    final myId = await TokenStorage.readUserId();
    result.fold(
      (failure) => emit(ActiveTripError(failure.message)),
      (trip) => emit(ActiveTripLoaded(trip: trip, isMine: trip?.buyerId == myId)),
    );
    await _subscribeToRealtime(listId, myId);
  }

  Future<void> _subscribeToRealtime(String listId, String? myId) async {
    for (final sub in _socketSubs) {
      await sub.cancel();
    }
    _socketSubs.clear();

    void listen(String event, void Function(Map<String, dynamic>) handler) {
      _socketSubs.add(_socketService.on(event).listen((data) {
        if (data['list_id'] != listId) return;
        handler(data);
      }));
    }

    listen('trip.assigned', (data) {
      final trip = ActiveTrip.fromJson(data['trip'] as Map<String, dynamic>);
      emit(ActiveTripLoaded(trip: trip, isMine: trip.buyerId == myId));
    });
    listen('trip.completed', (_) => emit(ActiveTripLoaded(trip: null, isMine: false)));
    listen('trip.cancelled', (_) => emit(ActiveTripLoaded(trip: null, isMine: false)));
  }

  /// Locks the caller in as buyer and starts the trip. On a 409 (someone
  /// else already started one — a race with another member) this just
  /// re-loads the real active trip instead of surfacing a raw error.
  Future<bool> startAsSelf(String listId) async {
    final myId = await TokenStorage.readUserId();
    if (myId == null) {
      emit(ActiveTripError('تعذر تحديد هويتك، حاول تسجيل الدخول مجدداً'));
      return false;
    }
    final result =
        await _assignBuyer(AssignBuyerParams(listId: listId, memberId: myId));
    final succeeded = result.isSuccess;
    await load(listId);
    return succeeded;
  }

  @override
  Future<void> close() async {
    for (final sub in _socketSubs) {
      await sub.cancel();
    }
    return super.close();
  }
}
