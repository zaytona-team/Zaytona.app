import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../router.dart';
import '../network/token_storage.dart';
import 'local_notification_service.dart';

/// Must be a top-level (or static) function: when the app is fully
/// terminated, Android wakes a fresh isolate just to run this handler and
/// that isolate never ran main() — it has no access to any state built
/// there, so Firebase has to be initialized again from scratch here.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No local-notification call needed here: FCM auto-displays a system
  // notification for background/terminated messages that carry a
  // `notification` payload (every push this backend sends does). This
  // handler exists so data-only pushes still have somewhere to run.
}

/// Owns the whole FCM lifecycle: permission, token issuance, registering
/// that token with the backend, and reacting to a push in each of the
/// three states FCM defines (foreground / background / terminated).
///
/// The FCM token is unrelated to the JWT access token TokenStorage holds:
/// the JWT proves who the user is to our API; the FCM token identifies
/// *this installation on this device* to Google's push infrastructure, is
/// issued by the Firebase SDK (not our backend), and is meaningless
/// without a valid Authorization header to attach it to a user via
/// POST /devices.
class PushNotificationService {
  PushNotificationService(this._repository, this._localNotifications);

  final NotificationRepository _repository;
  final LocalNotificationService _localNotifications;

  // Firebase is configured for Android and iOS (see firebase_options.dart) —
  // no-op on other platforms rather than crash when touching
  // FirebaseMessaging.instance.
  static bool get _firebaseAvailable =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  static const _tripAlertsChannelId = 'zaytona_trip_alerts';
  static const _tripAlertsChannelName = 'Trip alerts & reminders';
  static const _tripAlertsChannelDescription =
      'Buyer assignment, heading-out pings, and list reminders.';

  /// Call once, before runApp, *after* `sl<LocalNotificationService>().init()`
  /// — wires up the foreground listener and the two "a push brought the app
  /// to the foreground" entry points. Showing the banner itself and reacting
  /// to a tap both go through the shared [LocalNotificationService].
  Future<void> initForegroundHandling() async {
    if (!_firebaseAvailable) return;
    _localNotifications.onTap.listen(_openList);

    FirebaseMessaging.onMessage.listen(_showForegroundBanner);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);

    // App was fully terminated and got launched *by tapping a push* —
    // onMessageOpenedApp never fires for this case since there was no
    // running app to open. This is the terminated-state equivalent.
    // Timed out: on iOS Simulators (no real APNs token) this call can hang
    // indefinitely waiting on an APNs token exchange that never resolves,
    // which would otherwise block app startup forever since this method
    // runs before runApp().
    RemoteMessage? initialMessage;
    try {
      initialMessage = await FirebaseMessaging.instance
          .getInitialMessage()
          .timeout(const Duration(seconds: 3));
    } on TimeoutException {
      initialMessage = null;
    }
    if (initialMessage != null) _handleTap(initialMessage);
  }

  /// Call after login succeeds, and again at every cold start where a
  /// session already exists — a token can rotate at any time (reinstall,
  /// backup restore, Google Play services update), so "register on login
  /// only" would silently go stale.
  Future<void> registerCurrentDevice() async {
    if (!_firebaseAvailable) return;
    final settings = await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _repository.registerDevice(
        fcmToken: token,
        platform: _platform,
      );
    }

    // Fires whenever FCM rotates the token for this install — re-send it
    // so the backend's copy never drifts from what's actually live.
    FirebaseMessaging.instance.onTokenRefresh.listen(
      (newToken) => _repository.registerDevice(
        fcmToken: newToken,
        platform: _platform,
      ),
    );
  }

  /// Call on logout — an fcm_token row left behind after sign-out would
  /// keep receiving the *next* account's pushes on a shared/reused device.
  /// Timed out and swallowed: on iOS Simulators (no real APNs token) this
  /// call can hang indefinitely waiting on an APNs token exchange that never
  /// resolves, which would otherwise block the entire logout flow. Best
  /// effort only — logout must never depend on this succeeding.
  Future<void> unregisterCurrentDevice() async {
    if (!_firebaseAvailable) return;
    try {
      final token = await FirebaseMessaging.instance
          .getToken()
          .timeout(const Duration(seconds: 3));
      if (token != null) await _repository.unregisterDevice(fcmToken: token);
    } on Exception {
      // Best effort — a stale fcm_token row is harmless compared to a
      // logout button that never completes.
    }
  }

  void _showForegroundBanner(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      channelId: _tripAlertsChannelId,
      channelName: _tripAlertsChannelName,
      channelDescription: _tripAlertsChannelDescription,
      payload: message.data['list_id'],
    );
  }

  void _handleTap(RemoteMessage message) => _openList(
        message.data['list_id'],
        groupId: message.data['group_id'],
      );

  void _openList(String? listId, {String? groupId}) {
    if (listId == null || groupId == null) return;
    appRouter.go('/groups/$groupId/lists/$listId');
  }

  String get _platform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.android:
        return 'android';
      default:
        return 'web';
    }
  }
}

/// True once TokenStorage has a session — gates whether it's meaningful
/// to call registerCurrentDevice at all (POST /devices requires auth).
Future<bool> hasActiveSession() async => await TokenStorage.readToken() != null;
