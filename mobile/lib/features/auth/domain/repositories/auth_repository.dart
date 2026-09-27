import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/auth_session.dart';
import '../entities/otp_channel.dart';

abstract class AuthRepository {
  Future<Result<Failure, String>> login(String identifier);

  Future<Result<Failure, void>> register({
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
  });

  Future<Result<Failure, AuthSession>> verifyOtp({
    required String phone,
    required String token,
    String? email,
  });

  Future<Result<Failure, void>> resendOtp(
    String phone, {
    OtpChannel channel = OtpChannel.whatsapp,
  });
}