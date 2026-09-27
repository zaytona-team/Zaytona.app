import 'package:dio/dio.dart';
import 'api_config.dart';
import 'token_storage.dart';

/// Exchanges the stored refresh_token for a new access_token by calling
/// POST /auth/refresh. Uses its own bare Dio instance (no interceptors) so
/// the call never attaches the dying access token and a 401 here can't
/// recursively re-enter NetworkClient's error interceptor. Concurrent 401s
/// share a single in-flight refresh instead of each firing their own call.
class TokenRefresher {
  TokenRefresher._();
  static final instance = TokenRefresher._();

  final Dio _bareDio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
    ),
  );

  Future<String?>? _inFlight;

  /// Returns the new access token on success, or null if there was no
  /// stored refresh token or the refresh call failed.
  Future<String?> refresh() {
    return _inFlight ??= _doRefresh().whenComplete(() => _inFlight = null);
  }

  Future<String?> _doRefresh() async {
    final refreshToken = await TokenStorage.readRefreshToken();
    if (refreshToken == null) return null;
    try {
      final res = await _bareDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final data = res.data;
      final newAccessToken = data is Map ? data['access_token'] as String? : null;
      if (newAccessToken == null) return null;
      await TokenStorage.saveToken(newAccessToken);
      return newAccessToken;
    } on DioException {
      return null;
    }
  }
}
