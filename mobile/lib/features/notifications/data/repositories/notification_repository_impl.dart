import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/active_trip.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/remote/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._ds);
  final NotificationRemoteDataSource _ds;

  @override
  Future<Result<Failure, void>> headingToStore({required String listId}) {
    return _map(() => _ds.headingToStore(listId: listId));
  }

  @override
  Future<Result<Failure, ActiveTrip?>> getActiveTrip({
    required String listId,
  }) async {
    try {
      final trip = await _ds.getActiveTrip(listId);
      return Success(trip == null ? null : ActiveTrip.fromJson(trip));
    } on NetworkException catch (e) {
      return ResultError(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return ResultError(ServerFailure(e.message));
    } catch (_) {
      return const ResultError(ServerFailure());
    }
  }

  @override
  Future<Result<Failure, void>> completeTrip({required String tripId}) {
    return _map(() => _ds.completeTrip(tripId: tripId));
  }

  @override
  Future<Result<Failure, void>> assignBuyer({
    required String listId,
    required String memberId,
  }) {
    return _map(() => _ds.assignBuyer(listId: listId, memberId: memberId));
  }

  @override
  Future<Result<Failure, void>> remindMember({
    required String listId,
    required String memberId,
  }) {
    return _map(() => _ds.remindMember(listId: listId, memberId: memberId));
  }

  @override
  Future<Result<Failure, void>> remindMe({required String listId}) async {
    // US-43 (Could Have): no backend endpoint exists for a user-triggered
    // personal shopping reminder — the only server-side reminder is a
    // generic 12h "list still has items" sweep to the whole group.
    return const ResultError(
      ServerFailure('تذكير الشراء الشخصي غير متاح حالياً'),
    );
  }

  @override
  Future<Result<Failure, void>> registerDevice({
    required String fcmToken,
    required String platform,
  }) {
    return _map(
        () => _ds.registerDevice(fcmToken: fcmToken, platform: platform));
  }

  @override
  Future<Result<Failure, void>> unregisterDevice({required String fcmToken}) {
    return _map(() => _ds.unregisterDevice(fcmToken: fcmToken));
  }

  /// All endpoints return only an ack message — success carries no value.
  Future<Result<Failure, void>> _map(
    Future<dynamic> Function() request,
  ) async {
    try {
      await request();
      return const Success(null);
    } on NetworkException catch (e) {
      return ResultError(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return ResultError(ServerFailure(e.message));
    } catch (_) {
      return const ResultError(ServerFailure());
    }
  }
}
