import 'package:equatable/equatable.dart';

/// A minimal Either-style result type: either a [Failure] ([F]) or a
/// success value ([T]). Used as the repository return contract instead of
/// raw throws, without pulling in a heavier dependency like dartz.
sealed class Result<F, T> extends Equatable {
  const Result();

  bool get isSuccess => this is Success<F, T>;
  bool get isFailure => this is ResultError<F, T>;

  /// Runs [onSuccess] or [onFailure] depending on the variant and returns
  /// the resulting value.
  R fold<R>(R Function(F failure) onFailure, R Function(T value) onSuccess) {
    final self = this;
    if (self is Success<F, T>) return onSuccess(self.value);
    if (self is ResultError<F, T>) return onFailure(self.failure);
    throw StateError('Unreachable Result variant');
  }
}

class Success<F, T> extends Result<F, T> {
  const Success(this.value);
  final T value;

  @override
  List<Object?> get props => [value];
}

class ResultError<F, T> extends Result<F, T> {
  const ResultError(this.failure);
  final F failure;

  @override
  List<Object?> get props => [failure];
}
