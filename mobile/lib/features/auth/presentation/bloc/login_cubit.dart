import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/network_client.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/login_usecase.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({LoginUseCase? loginUseCase})
      : _loginUseCase = loginUseCase ?? LoginUseCase(AuthRepositoryImpl(AuthRemoteDataSource(NetworkClient.instance))),
        super(LoginInitial());

  final LoginUseCase _loginUseCase;

  Future<void> submit(String identifier) async {
    emit(LoginLoading());
    final result = await _loginUseCase(identifier);
    result.fold(
      (failure) => emit(LoginError(failure.message)),
      (phone) => emit(LoginOtpRequired(phone)),
    );
  }
}