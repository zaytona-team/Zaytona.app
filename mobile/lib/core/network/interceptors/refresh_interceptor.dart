import 'package:dio/dio.dart';
import '../../../router.dart';
import '../../di/session_cleanup.dart';
import '../token_refresher.dart';
import '../token_storage.dart';

/// On a 401, attempts a token refresh and retries the original request once
/// before logging out. On a cold-start timeout, retries once unconditionally.
class RefreshInterceptor extends Interceptor {
  RefreshInterceptor(this._dio);
  final Dio _dio;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final error = err;
    if (error.response?.statusCode == 401) {
      final refreshedToken = await TokenRefresher.instance.refresh();
      if (refreshedToken != null) {
        try {
          final retryOptions = error.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $refreshedToken';
          handler.resolve(await _dio.fetch(retryOptions));
          return;
        } on DioException {
          // Retry with the refreshed token also failed — log out below.
        }
      }
      TokenStorage.clearToken();
      clearSessionState();
      appRouter.go('/welcome');
      handler.next(error);
      return;
    }

    final isTimeout = error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout;
    if (isTimeout && error.requestOptions.extra['retried'] != true) {
      error.requestOptions.extra['retried'] = true;
      try {
        handler.resolve(await _dio.fetch(error.requestOptions));
        return;
      } on DioException {
        // Retry also failed — fall through and propagate the original.
      }
    }
    handler.next(error);
  }
}
