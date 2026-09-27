import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  LoginUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<Failure, String>> call(String identifier) {
    return _repository.login(identifier);
  }
}
