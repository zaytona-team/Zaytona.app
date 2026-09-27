import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../notifications/domain/usecases/complete_trip_usecase.dart';

part 'complete_trip_state.dart';

/// Ends a buying trip (US-15/US-38): bought items become trip history,
/// unbought items stay on the list. The list is never marked completed.
class CompleteTripCubit extends Cubit<CompleteTripState> {
  CompleteTripCubit(this._completeTripUseCase) : super(CompleteTripInitial());
  final CompleteTripUseCase _completeTripUseCase;

  Future<void> complete(String tripId) async {
    emit(CompleteTripLoading());
    final result = await _completeTripUseCase(CompleteTripParams(tripId));
    result.fold(
      (failure) => emit(CompleteTripError(failure.message)),
      (_) => emit(CompleteTripSuccess()),
    );
  }
}
