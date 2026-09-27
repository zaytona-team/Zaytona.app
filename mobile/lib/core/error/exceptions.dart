/// Thrown by datasources on request failure; repositories catch these and
/// translate them into [Failure] values for the domain/presentation layers.
class ServerException implements Exception {
  const ServerException([this.message = 'حدث خطأ في الخادم، حاول مرة أخرى']);
  final String message;
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'تعذر الاتصال بالإنترنت، تحقق من اتصالك']);
  final String message;
}

class ValidationException implements Exception {
  const ValidationException([this.message = 'البيانات المدخلة غير صحيحة']);
  final String message;
}

class CacheException implements Exception {
  const CacheException([this.message = 'تعذر قراءة البيانات المحفوظة']);
  final String message;
}
