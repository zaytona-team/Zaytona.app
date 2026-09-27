part of 'signup_cubit.dart';

sealed class SignupState {}

final class SignupInitial extends SignupState {}

final class SignupLoading extends SignupState {}

final class SignupSuccess extends SignupState {
  SignupSuccess({required this.phone, this.email});
  final String phone;
  final String? email;
}

final class SignupError extends SignupState {
  SignupError(this.message);
  final String message;
}