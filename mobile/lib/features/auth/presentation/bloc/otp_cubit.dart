import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/network_client.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/otp_channel.dart';
import '../../domain/usecases/resend_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';

part 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  OtpCubit({VerifyOtpUseCase? verifyOtpUseCase, ResendOtpUseCase? resendOtpUseCase})
      : _verifyOtpUseCase = verifyOtpUseCase ?? VerifyOtpUseCase(AuthRepositoryImpl(AuthRemoteDataSource(NetworkClient.instance))),
        _resendOtpUseCase = resendOtpUseCase ?? ResendOtpUseCase(AuthRepositoryImpl(AuthRemoteDataSource(NetworkClient.instance))),
        super(OtpInitial());

  final VerifyOtpUseCase _verifyOtpUseCase;
  final ResendOtpUseCase _resendOtpUseCase;

  Future<void> verify({required String phone, required String token, String? email}) async {
    emit(OtpVerifying());
    final result = await _verifyOtpUseCase(
      phone: phone,
      token: token,
      email: email,
    );
    result.fold(
      (failure) => emit(OtpError(failure.message)),
      (session) => emit(OtpVerified(session.firstName ?? '')),
    );
  }

  Future<void> resend(String phone, {OtpChannel channel = OtpChannel.whatsapp}) async {
    emit(OtpResending());
    final result = await _resendOtpUseCase(phone, channel: channel);
    result.fold(
      (failure) => emit(OtpError(failure.message)),
      (_) => emit(OtpResent()),
    );
  }
}