import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import 'core/di/injection_container.dart';
import 'core/l10n/locale_controller.dart';
import 'core/network/token_storage.dart';
import 'core/notifications/local_notification_service.dart';
import 'core/notifications/push_notification_service.dart';
import 'core/realtime/socket_service.dart';
import 'features/items/data/category_registry.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase is configured for Android and iOS (see firebase_options.dart) —
  // skip init on every other platform (web, desktop) rather than crash at
  // boot on a target DefaultFirebaseOptions.currentPlatform doesn't cover.
  final firebaseAvailable = defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
  if (firebaseAvailable) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // Must be registered before runApp — this is what lets Android wake the
    // app to run firebaseMessagingBackgroundHandler while it's terminated.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  await setupLocator();
  // Fire-and-forget: warms the category cache and doubles as an early wake
  // ping for the (possibly cold) Render backend.
  sl<CategoryRegistry>().ensureLoaded();

  final localNotifications = sl<LocalNotificationService>();
  final pushService = sl<PushNotificationService>();
  await Future.wait([
    () async {
      try {
        await localNotifications.init().timeout(const Duration(seconds: 5));
        await localNotifications.requestPermission();
        unawaited(localNotifications.show(
          title: 'Welcome to Zaytona',
          body: 'Glad to have you here!',
        ));
      } catch (e, st) {
        debugPrint('Local notification setup failed, continuing without it: $e\n$st');
      }
    }(),
    () async {
      try {
        await pushService.initForegroundHandling().timeout(const Duration(seconds: 5));
      } catch (e, st) {
        debugPrint('Push notification setup failed, continuing without it: $e\n$st');
      }
    }(),
  ]);
  // A session from a previous launch is still valid — re-register in case
  // the FCM token rotated while the app was closed. (A *new* login/OTP
  // verification registers separately, from otp_page.dart, since no
  // session exists yet at this point in that flow.)
  if (await TokenStorage.readToken() != null) {
    unawaited(pushService.registerCurrentDevice());
    // Same "still-valid session from a previous launch" logic as the push
    // registration above — connect() always re-reads the stored token, so
    // this also covers a token that rotated while the app was closed.
    unawaited(sl<SocketService>().connect());
  }

  runApp(const ZaytonaApp());
}

class ZaytonaApp extends StatefulWidget {
  const ZaytonaApp({super.key});

  @override
  State<ZaytonaApp> createState() => _ZaytonaAppState();
}

class _ZaytonaAppState extends State<ZaytonaApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // A background stint can outlive the socket connection (or the access
    // token backing it) — reconnecting on every foreground resume is
    // cheap and re-reads a fresh token, unlike a single long-lived
    // connection that's never proven to still be authenticated.
    if (state == AppLifecycleState.resumed) {
      unawaited(() async {
        if (await TokenStorage.readToken() != null) {
          unawaited(sl<SocketService>().connect());
        }
      }());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: sl<LocaleController>(),
      builder: (context, locale, _) {
        // The framework flips text direction from the locale (ar → RTL,
        // en → LTR); we only swap the base font to match the script.
        final isArabic = locale.languageCode == 'ar';
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          locale: locale,
          supportedLocales: LocaleController.supported,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: ZaytonaTheme.lightWithFont(
            isArabic ? ZaytonaType.fontBody : ZaytonaType.fontDisplay,
          ),
          routerConfig: appRouter,
        );
      },
    );
  }
}
