# Team setup TODO

Running log of anything that needs a human/team action outside of code during the 10-hour frontend push (config, keys, native service setup, device setup). Append as items are found; this file is not shipped code.

---

- **Add `share_plus` to `mobile/pubspec.yaml` + `flutter pub get`** — the invite page's "share invite link" button currently copies the link to the clipboard as a fallback. For a native share sheet, add `share_plus` and replace the clipboard fallback in `invite_to_group_page.dart` (`_onShareLinkPressed`) with `Share.share(inviteLink)`.
- **Invite link domain** — the invite link is hardcoded as `https://zaytouna.app/join/<code>` in `invite_to_group_page.dart`. Confirm the real deep-link/universal-link domain and configure iOS Associated Domains / Android App Links when it exists.

## FCM setup (Story 7 — push notifications)

The trip-alerts screen calls the notification endpoints, but actually *receiving* pushes needs Firebase Cloud Messaging wired manually:

1. **Firebase project** — create one (e.g. `zaytona-app`) in the Firebase console; add an Android app (`applicationId` from `mobile/android/app/build.gradle`) and an iOS app (bundle id from Xcode Runner target).
2. **Config files** — place `google-services.json` in `mobile/android/app/` and `GoogleService-Info.plist` in `mobile/ios/Runner/` (add via Xcode so it's in the target). Alternatively run `flutterfire configure`, which generates `firebase_options.dart` and does both.
3. **Dependencies** — add `firebase_core` and `firebase_messaging` to `mobile/pubspec.yaml`, `flutter pub get`; call `Firebase.initializeApp()` in `main()` before `runApp`.
4. **Android** — Google services Gradle plugin in `android/build.gradle` + `android/app/build.gradle`; request the `POST_NOTIFICATIONS` runtime permission on API 33+ (`FirebaseMessaging.instance.requestPermission()`).
5. **iOS** — enable the Push Notifications capability + Background Modes → Remote notifications in Xcode; create an APNs auth key in the Apple Developer portal and upload it in Firebase project settings → Cloud Messaging.
6. **Device token registration** — after login, get the token via `FirebaseMessaging.instance.getToken()` and send it through `NotificationRepository.registerDevice` (`POST /users/me/devices`, already implemented in `mobile/lib/features/notifications/` but not called anywhere — this is the wiring point). Also listen to `onTokenRefresh`.
7. **Backend** — give the Flask side the FCM server key (env var), per STAGE3's `notification_service.py` design.
