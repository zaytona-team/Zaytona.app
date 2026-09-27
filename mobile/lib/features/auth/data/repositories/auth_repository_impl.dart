import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/token_storage.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/otp_channel.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._ds);
  final AuthRemoteDataSource _ds;

  @override
  Future<Result<Failure, String>> login(String identifier) async {
    try {
      final res = await _ds.login(identifier: identifier);
      final data = res.data;
      final phone = data is Map ? data['phone'] as String? : null;
      return Success(phone ?? identifier);
    } on NetworkException catch (e) {
      return ResultError(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return ResultError(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<Failure, void>> register({
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
  }) async {
    try {
      final res = await _ds.register(firstName: firstName, lastName: lastName, phone: phone, email: email);
      final data = res.data;
      final otpSent = data is Map ? data['otp_sent'] == true : false;
      if (!otpSent) {
        return const ResultError(ValidationFailure('تعذر إرسال رمز التحقق. حاول مرة أخرى'));
      }
      return const Success(null);
    } on NetworkException catch (e) {
      return ResultError(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return ResultError(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<Failure, AuthSession>> verifyOtp({
    required String phone,
    required String token,
    String? email,
  }) async {
    try {
      final res = await _ds.verifyOtp(
        phone: phone,
        token: token,
        email: email,
      );
      final data = res.data;
      final accessToken = data is Map ? data['access_token'] as String? : null;
      if (accessToken == null) {
        return const ResultError(ValidationFailure('لم يتم استلام رمز الدخول'));
      }
      await TokenStorage.saveToken(accessToken);
      final refreshToken = data is Map ? data['refresh_token'] as String? : null;
      if (refreshToken != null) {
        await TokenStorage.saveRefreshToken(refreshToken);
      }
      final user = data is Map ? data['user'] as Map? : null;
      final firstName = user?['first_name'] as String?;
      final userId = user?['user_id'] as String?;

      if (firstName != null && firstName.isNotEmpty) {
        await TokenStorage.saveFirstName(firstName);
      }

      await TokenStorage.savePhone(phone);
      
      if (userId != null) {
        await TokenStorage.saveUserId(userId);
      }
      return Success(AuthSession(
        accessToken: accessToken,
        phone: phone,
        firstName: firstName,
        userId: userId,
      ));
    } on NetworkException catch (e) {
      return ResultError(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return ResultError(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<Failure, void>> resendOtp(String phone, {OtpChannel channel = OtpChannel.whatsapp}) async {
    try {
      await _ds.resendOtp(phone: phone, channel: channel.name);
      return const Success(null);
    } on NetworkException catch (e) {
      return ResultError(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return ResultError(ServerFailure(e.message));
    }
  }
}