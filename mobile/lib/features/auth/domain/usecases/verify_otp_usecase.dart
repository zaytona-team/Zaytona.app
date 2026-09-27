import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  VerifyOtpUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<Failure, AuthSession>> call({
    required String phone,
    required String token,
    String? email,
  }) {
    return _repository.verifyOtp(phone: phone, token: token, email: email);
  }
}