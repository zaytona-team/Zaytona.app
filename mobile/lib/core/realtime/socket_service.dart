import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as socket_io;

import '../network/api_config.dart';
import '../network/token_storage.dart';

/// Single Socket.IO connection for the whole app — the client-side half of
/// the backend's real-time sync (see zaytona_api/app/sockets and
/// app/services/facade/realtime.py). Registered as a GetIt lazy singleton
/// so every cubit shares one connection instead of opening its own.
///
/// Cubits never touch the underlying `socket_io.Socket` directly — they
/// call [on] for the event names they care about, which lazily creates a
/// broadcast stream fed by a single `onAny` listener. New backend events
/// never require touching this file: just call `.on('some.event')`
/// wherever it's needed.
class SocketService {
  socket_io.Socket? _socket;
  bool _connecting = false;
  final Map<String, StreamController<Map<String, dynamic>>> _controllers = {};

  /// (Re)connects using the freshest stored access token. Safe to call
  /// repeatedly — e.g. on every app-foreground resume, since a background
  /// stint may have outlived the previous token (see main.dart's
  /// WidgetsBindingObserver). No-ops if there's no session to connect with.
  Future<void> connect() async {
    if (_connecting) return;
    _connecting = true;
    try {
      final token = await TokenStorage.readToken();
      if (token == null) return;

      _socket?.dispose();

      // The REST API lives at `<host>/api/v1`; Flask-SocketIO mounts the
      // socket endpoint at the bare host root (`/socket.io/`), so strip
      // the API suffix rather than hardcoding a second base URL.
      final host = ApiConfig.baseUrl.replaceFirst(RegExp(r'/api/v1/?$'), '');

      final socket = socket_io.io(
        host,
        socket_io.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .build(),
      );
      _socket = socket;

      socket.onAny((event, data) {
        final controller = _controllers[event];
        if (controller == null || controller.isClosed) return;
        if (data is Map) {
          controller.add(Map<String, dynamic>.from(data));
        }
      });
    } finally {
      _connecting = false;
    }
  }

  /// A broadcast stream of every payload received for [event]. Multiple
  /// listeners (e.g. a page-scoped cubit and a global one) can subscribe to
  /// the same event independently.
  Stream<Map<String, dynamic>> on(String event) {
    return (_controllers[event] ??=
            StreamController<Map<String, dynamic>>.broadcast())
        .stream;
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }
}
