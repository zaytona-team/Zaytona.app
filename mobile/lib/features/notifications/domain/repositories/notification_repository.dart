import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/active_trip.dart';

/// Trip-alert pushes (Story 7: US-30..US-32, US-43) plus the trip lifecycle
/// calls (start/active/complete) that live under the same `/trips` backend
/// namespace.
abstract class NotificationRepository {
  /// Buyer announces the trip; every group member gets a push (US-30).
  Future<Result<Failure, void>> headingToStore({required String listId});

  /// The list's active trip, or null if nobody has started one.
  Future<Result<Failure, ActiveTrip?>> getActiveTrip({required String listId});

  /// Ends the trip: bought items become history, unbought items stay on
  /// the list (US-38/US-15).
  Future<Result<Failure, void>> completeTrip({required String tripId});

  /// Push the chosen member that they're this trip's buyer (US-31).
  Future<Result<Failure, void>> assignBuyer({
    required String listId,
    required String memberId,
  });

  /// Remind one member to add their items (US-32).
  Future<Result<Failure, void>> remindMember({
    required String listId,
    required String memberId,
  });

  /// Schedule a shopping reminder to the caller's own device (US-43).
  Future<Result<Failure, void>> remindMe({required String listId});

  /// Registers (or refreshes) this device's FCM token (POST /devices).
  Future<Result<Failure, void>> registerDevice({
    required String fcmToken,
    required String platform,
  });

  /// Unregisters this device's token, e.g. on logout (DELETE /devices/id).
  Future<Result<Failure, void>> unregisterDevice({required String fcmToken});
}
