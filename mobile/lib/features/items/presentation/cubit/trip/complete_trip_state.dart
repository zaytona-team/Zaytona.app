part of 'complete_trip_cubit.dart';

sealed class CompleteTripState {}

final class CompleteTripInitial extends CompleteTripState {}

final class CompleteTripLoading extends CompleteTripState {}

final class CompleteTripSuccess extends CompleteTripState {}

final class CompleteTripError extends CompleteTripState {
  CompleteTripError(this.message);
  final String message;
}
