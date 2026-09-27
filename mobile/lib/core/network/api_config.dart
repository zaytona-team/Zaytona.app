/// Shared base URL and timeouts for both [NetworkClient] and [TokenRefresher]
/// so the two Dio instances can never drift apart.
abstract final class ApiConfig {
  // Also used by SocketService, which derives the socket host from
  // [baseUrl]. Flip to true only for local WSL-backend testing.
  static const useLocalDev = false;
  static const _prodBaseUrl = 'https://zaytona-app.onrender.com/api/v1';
  // 10.0.2.2 is the Android emulator's fixed alias for its host machine's
  // localhost. WSL2 forwards Windows' localhost to WSL by default, so this
  // reaches `python run.py` running inside WSL as long as the emulator
  // itself is on the same Windows machine (or inside WSL directly).
  static const _localBaseUrl = 'http://10.0.2.2:5000/api/v1';

  static const baseUrl = useLocalDev ? _localBaseUrl : _prodBaseUrl;
  static const connectTimeout = Duration(seconds: 30);
  static const receiveTimeout = Duration(seconds: 30);
}
