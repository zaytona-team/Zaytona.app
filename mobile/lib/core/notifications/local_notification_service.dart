import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// General-purpose local notification popper — the single place in the app
/// that owns [FlutterLocalNotificationsPlugin] and talks to it.
///
/// flutter_local_notifications talks to one native platform channel no
/// matter how many Dart-side `FlutterLocalNotificationsPlugin()` instances
/// exist, so a second `initialize()` call anywhere else in the app would
/// silently steal the tap callback from this one. Anything that needs to
/// show a local notification — an FCM foreground banner, a "trip
/// completed" confirmation, a reminder, whatever — should call [show] on
/// this service instead of creating its own plugin instance.
class LocalNotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  final _taps = StreamController<String?>.broadcast();
  final _createdChannels = <String>{};
  bool _initialized = false;

  /// Fires with the `payload` of whichever notification the user tapped
  /// (foreground taps only — see [init]).
  Stream<String?> get onTap => _taps.stream;

  /// Call once, before runApp. Safe to call again — later calls are a no-op.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Requested explicitly via requestPermission() instead, so callers
        // can control when the OS prompt appears rather than having it
        // fire the instant this runs at app boot.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) =>
          _taps.add(response.payload),
    );
  }

  /// Android 13+ and iOS both require an explicit runtime prompt before a
  /// notification will actually show. Harmless to call more than once — the
  /// OS just re-returns the existing answer after the first time.
  Future<bool> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return granted ?? false;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    return false;
  }

  /// Shows one local notification immediately. Pass any [channelId] you
  /// like — a fresh Android channel is created from [channelName] /
  /// [channelDescription] / [importance] on first use and reused after
  /// that, so callers never have to register one up front. [payload] comes
  /// back out through [onTap] if the user taps it.
  Future<void> show({
    String? title,
    String? body,
    int? id,
    String? payload,
    String channelId = 'zaytona_general',
    String channelName = 'General',
    String channelDescription = '',
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    if (!_initialized) await init();
    if (defaultTargetPlatform == TargetPlatform.android &&
        _createdChannels.add(channelId)) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDescription,
            importance: importance,
          ));
    }
    await _plugin.show(
      id: id ?? DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: importance,
          priority: priority,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// Shows a notification on a repeating interval, first firing after
  /// [repeatInterval] and then every [repeatInterval] after that.
  /// [repeatInterval] must be at least one minute — Android rejects
  /// anything shorter by throwing. Uses
  /// `inexactAllowWhileIdle` on Android — fires roughly on schedule (may
  /// drift under battery optimization) without needing the
  /// `SCHEDULE_EXACT_ALARM` permission, which is the right tradeoff for
  /// anything that doesn't need to-the-minute precision. Each distinct [id]
  /// is its own independent repeating series — call [cancel] with the same
  /// [id] to stop it.
  Future<void> showRepeating({
    required int id,
    required Duration repeatInterval,
    String? title,
    String? body,
    String? payload,
    String channelId = 'zaytona_general',
    String channelName = 'General',
    String channelDescription = '',
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    if (!_initialized) await init();
    if (defaultTargetPlatform == TargetPlatform.android &&
        _createdChannels.add(channelId)) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDescription,
            importance: importance,
          ));
    }
    await _plugin.periodicallyShowWithDuration(
      id: id,
      repeatDurationInterval: repeatInterval,
      title: title,
      body: body,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: importance,
          priority: priority,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id: id);

  Future<void> cancelAll() => _plugin.cancelAll();
}
