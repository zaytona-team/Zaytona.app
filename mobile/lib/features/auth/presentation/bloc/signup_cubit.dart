import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/network_client.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/register_usecase.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit({RegisterUseCase? registerUseCase})
      : _registerUseCase = registerUseCase ?? RegisterUseCase(AuthRepositoryImpl(AuthRemoteDataSource(NetworkClient.instance))),
        super(SignupInitial());

  final RegisterUseCase _registerUseCase;

  Future<void> submit({
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
  }) async {
    emit(SignupLoading());
    final result = await _registerUseCase(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
    );
    result.fold(
      (failure) => emit(SignupError(failure.message)),
      (_) => emit(SignupSuccess(phone: phone, email: email)),
    );
  }
}