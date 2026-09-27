import 'package:flutter/widgets.dart';

/// Holds the app's current locale. Arabic is the default (Zaytona is
/// Arabic-first). Call [switchTo] from a settings/language toggle; the
/// MaterialApp listens and rebuilds with the new locale, text direction
/// (framework-driven RTL/LTR), and locale-matched font.
class LocaleController extends ValueNotifier<Locale> {
  LocaleController() : super(const Locale('ar'));

  static const supported = [Locale('ar'), Locale('en')];

  void switchTo(Locale locale) {
    if (supported.contains(locale)) value = locale;
  }
}
