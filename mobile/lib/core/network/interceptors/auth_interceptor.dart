import 'package:dio/dio.dart';
import '../token_storage.dart';

class AuthInterceptor extends Interceptor {
  static const String requiresAuthTokenKey = 'requiresAuthToken';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.extra[requiresAuthTokenKey] == true) {
      final token = await TokenStorage.readToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      options.extra.remove(requiresAuthTokenKey);
    }
    handler.next(options);
  }
}
