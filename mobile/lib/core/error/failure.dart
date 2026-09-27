import 'package:equatable/equatable.dart';

/// Typed failure returned by repositories instead of throwing raw exceptions.
/// [message] is always Arabic-ready copy suitable for direct display.
sealed class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'حدث خطأ في الخادم، حاول مرة أخرى']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'تعذر الاتصال بالإنترنت، تحقق من اتصالك']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'البيانات المدخلة غير صحيحة']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'تعذر قراءة البيانات المحفوظة']);
}
