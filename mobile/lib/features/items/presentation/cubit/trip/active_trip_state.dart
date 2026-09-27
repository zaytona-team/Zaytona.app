part of 'active_trip_cubit.dart';

sealed class ActiveTripState {}

final class ActiveTripInitial extends ActiveTripState {}

final class ActiveTripLoading extends ActiveTripState {}

/// [trip] is null when nobody has started a trip on this list yet.
/// [isMine] is only meaningful when [trip] isn't null.
final class ActiveTripLoaded extends ActiveTripState {
  ActiveTripLoaded({required this.trip, required this.isMine});
  final ActiveTrip? trip;
  final bool isMine;
}

final class ActiveTripError extends ActiveTripState {
  ActiveTripError(this.message);
  final String message;
}
