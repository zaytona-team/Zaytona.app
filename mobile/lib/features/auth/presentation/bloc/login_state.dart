part of 'login_cubit.dart';

sealed class LoginState {}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

final class LoginOtpRequired extends LoginState {
  LoginOtpRequired(this.phone);
  final String phone;
}

final class LoginError extends LoginState {
  LoginError(this.message);
  final String message;
}