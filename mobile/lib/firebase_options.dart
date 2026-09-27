// GENERATED-STYLE FILE — hand-written to match `flutterfire configure`'s
// output shape, sourced from android/app/google-services.json (Android app
// com.zaytona.mobile) and ios/Runner/GoogleService-Info.plist (iOS app
// zaytona.sa), both under Firebase project zaytona-e2f90.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have only been configured for Android and iOS '
          'so far — this build is running on $defaultTargetPlatform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDAeIuf1h75DmeuCYqjPemyX7cp2h0SyTs',
    appId: '1:122890951071:android:73f572c1e753adb585c5aa',
    messagingSenderId: '122890951071',
    projectId: 'zaytona-e2f90',
    storageBucket: 'zaytona-e2f90.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAgOQnYbUsnsQeV4zqbtSnqiQggBIbUKmk',
    appId: '1:122890951071:ios:843d193c82f8867985c5aa',
    messagingSenderId: '122890951071',
    projectId: 'zaytona-e2f90',
    storageBucket: 'zaytona-e2f90.firebasestorage.app',
    iosBundleId: 'zaytona.sa',
  );
}
