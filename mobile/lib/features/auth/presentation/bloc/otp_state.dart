part of 'otp_cubit.dart';

sealed class OtpState {}

final class OtpInitial extends OtpState {}

final class OtpVerifying extends OtpState {}

final class OtpVerified extends OtpState {
  OtpVerified(this.firstName);
  final String firstName;
}

final class OtpResending extends OtpState {}

final class OtpResent extends OtpState {}

final class OtpError extends OtpState {
  OtpError(this.message);
  final String message;
}