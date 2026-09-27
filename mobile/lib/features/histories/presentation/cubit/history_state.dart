part of 'history_cubit.dart';

sealed class HistoryState {}

final class HistoryInitial extends HistoryState {}

final class HistoryLoading extends HistoryState {}

final class HistoryLoaded extends HistoryState {
  HistoryLoaded(this.entries, {this.trips = const []});
  final List<HistoryModel> entries;

  /// Completed trips for the "الرحلات" tab. Empty (rather than failing
  /// the whole screen) if that fetch fails — the activity log is the
  /// primary content here.
  final List<TripHistoryEntry> trips;
}

final class HistoryError extends HistoryState {
  HistoryError(this.message);
  final String message;
}
