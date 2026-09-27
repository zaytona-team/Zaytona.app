import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  RegisterUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<Failure, void>> call({
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
  }) {
    return _repository.register(firstName: firstName, lastName: lastName, phone: phone, email: email);
  }
}