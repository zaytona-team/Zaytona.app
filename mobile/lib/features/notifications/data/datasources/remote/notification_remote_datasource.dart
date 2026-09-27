import 'package:dio/dio.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/network_client.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../../core/network/remote_data_source_base.dart';
import '../../../../../core/network/token_storage.dart';

/// NotificationRemoteDataSource handles trip-alert push calls (Story 7).
///
/// These were originally written against the planning doc's flat
/// `/lists/{id}/notifications/*` scheme, but the backend actually
/// implements the same three actions under a trip-based scheme instead
/// (`/lists/{id}/trip`, `/trips/{id}/heading-out`, `/trips/{id}/ask`),
/// with buyer-lock semantics the flat scheme didn't have. This class
/// hides that behind the same method signatures the cubit already uses.
class NotificationRemoteDataSource with RemoteDataSourceBase {
  NotificationRemoteDataSource(this._client);

  final NetworkClient _client;

  /// Active trip for a list, including buyer_id — null if none started.
  Future<Map<String, dynamic>?> getActiveTrip(String listId) async {
    final res = await run(() => _client.get<Response>(
          request: NetworkRequest(endpoint: '/lists/$listId/trips/active'),
          converter: (response) => response,
        ));
    final trip = res.data;
    if (trip is Map && trip['trip_id'] is String) {
      return trip.cast<String, dynamic>();
    }
    return null;
  }

  Future<String?> _activeTripIdOrNull(String listId) async {
    return (await getActiveTrip(listId))?['trip_id'] as String?;
  }

  /// Claims bought items into trip history; unbought items stay on the
  /// list. The list itself is never marked completed.
  Future<Response> completeTrip({required String tripId}) {
    return run(() => _client.patch<Response>(
          request: NetworkRequest(endpoint: '/trips/$tripId/complete'),
          converter: (response) => response,
        ));
  }

  /// Same as [_activeTripIdOrNull] but throws when there's no trip —
  /// remind-member has no "start one" fallback of its own, unlike
  /// heading-out below.
  Future<String> _activeTripId(String listId) async {
    return await _activeTripIdOrNull(listId) ??
        (throw const ServerException('لا توجد رحلة تسوق نشطة لهذه القائمة بعد'));
  }

  /// Assign a buyer for this list — starts the trip (US-31 / US-38).
  Future<Response> assignBuyer({
    required String listId,
    required String memberId,
  }) {
    return run(() => _client.post<Response>(
          request: NetworkRequest(
            endpoint: '/lists/$listId/trip',
            body: {'buyer_id': memberId},
          ),
          converter: (response) => response,
        ));
  }

  /// Push all group members: buyer is heading to the store (US-30). If no
  /// trip is active yet, the tapper becomes the buyer for a new one —
  /// heading to the store IS the buyer's role, so there's no separate
  /// "assign a buyer" step to force first.
  Future<Response> headingToStore({required String listId}) async {
    final tripId =
        await _activeTripIdOrNull(listId) ?? await _startOwnTrip(listId);
    return run(() => _client.post<Response>(
          request: NetworkRequest(endpoint: '/trips/$tripId/heading-out'),
          converter: (response) => response,
        ));
  }

  Future<String> _startOwnTrip(String listId) async {
    final userId = await TokenStorage.readUserId();
    if (userId == null) {
      throw const ServerException('لا توجد رحلة تسوق نشطة لهذه القائمة بعد');
    }
    await assignBuyer(listId: listId, memberId: userId);
    return _activeTripId(listId);
  }

  /// Push one member a reminder to add their items (US-32).
  Future<Response> remindMember({
    required String listId,
    required String memberId,
  }) async {
    final tripId = await _activeTripId(listId);
    return run(() => _client.post<Response>(
          request: NetworkRequest(
            endpoint: '/trips/$tripId/ask',
            body: {
              'recipient_ids': [memberId],
            },
          ),
          converter: (response) => response,
        ));
  }

  /// Registers (or refreshes) this device's FCM token for pushes.
  /// `platform` must be one of the backend's ALLOWED_PLATFORMS
  /// ('ios' | 'android' | 'web') — see PushNotificationService for how
  /// it's derived.
  Future<Response> registerDevice({
    required String fcmToken,
    required String platform,
  }) {
    return run(() => _client.post<Response>(
          request: NetworkRequest(
            endpoint: '/devices',
            body: {'fcm_token': fcmToken, 'platform': platform},
          ),
          converter: (response) => response,
        ));
  }

  /// Unregisters this device's token — called on logout so a signed-out
  /// device stops receiving pushes meant for the account that just left.
  Future<Response> unregisterDevice({required String fcmToken}) {
    return run(() => _client.delete<Response>(
          request: NetworkRequest(
            endpoint: '/devices/${Uri.encodeComponent(fcmToken)}',
          ),
          converter: (response) => response,
        ));
  }

}
