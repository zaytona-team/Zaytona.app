import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/history_model.dart';
import '../entities/trip_history_entry.dart';

abstract class HistoryRepository {
  /// Activity log for a list (Story 8). [resolveName] maps a member's
  /// user_id to a display name — the caller supplies it from the group's
  /// already-fetched member list.
  Future<Result<Failure, List<HistoryModel>>> getListHistory({
    required String listId,
    required String Function(String userId) resolveName,
    String? Function(String userId)? resolveAvatar,
  });

  /// Completed trips for this list, newest first.
  Future<Result<Failure, List<TripHistoryEntry>>> getListTrips({
    required String listId,
  });
}
