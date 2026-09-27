import '../../../../l10n/app_localizations.dart';

/// Field-level validation for the signup form, returning localized messages.
class SignupValidator {
  static final RegExp _phoneRegExp = RegExp(r'^(?:\+?966|0)5\d{8}$');
  static final RegExp _emailRegExp = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');

  static String? validateName(String value, AppLocalizations l10n) {
    if (value.trim().isEmpty) return l10n.fieldRequired;
    if (value.trim().length < 2) return l10n.nameTooShort;
    return null;
  }

  static String? validatePhone(String value, AppLocalizations l10n) {
    if (value.trim().isEmpty) return l10n.fieldRequired;
    if (!_phoneRegExp.hasMatch(value.trim())) return l10n.phoneInvalid;
    return null;
  }

  static String? validateOptionalEmail(String value, AppLocalizations l10n) {
    if (value.trim().isEmpty) return null;
    if (!_emailRegExp.hasMatch(value.trim())) return l10n.emailInvalid;
    return null;
  }
}
