import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/otp_channel.dart';
import '../repositories/auth_repository.dart';

class ResendOtpUseCase {
  ResendOtpUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<Failure, void>> call(String phone, {OtpChannel channel = OtpChannel.whatsapp}) {
    return _repository.resendOtp(phone, channel: channel);
  }
}