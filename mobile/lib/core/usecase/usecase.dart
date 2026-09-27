import 'package:equatable/equatable.dart';

import '../error/failure.dart';
import '../error/result.dart';

/// Base contract for a single-purpose use case: takes [Params], returns a
/// [Result] wrapping either a [Failure] or a success value [T].
abstract class UseCase<T, Params> {
  Future<Result<Failure, T>> call(Params params);
}

/// Marker params object for use cases that take no arguments.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
