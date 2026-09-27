import '../../../../l10n/app_localizations.dart';

class LoginValidator {
  static final RegExp _phoneRegExp = RegExp(
    r'^(?:\+?966|0)5\d{8}$',
  );

  static String? validatePhone(String? value, AppLocalizations l10n) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return l10n.fieldRequired;
    }
    if (!_phoneRegExp.hasMatch(trimmed)) {
      return l10n.phoneInvalid;
    }
    return null;
  }

  static String normalizePhone(String value) {
    final trimmed = value.trim().replaceAll(' ', '');
    if (trimmed.startsWith('+966')) return trimmed;
    if (trimmed.startsWith('966')) return '+$trimmed';
    if (trimmed.startsWith('0')) return '+966${trimmed.substring(1)}';
    return trimmed;
  }

  static String maskPhone(String phone) {
    if (phone.length < 4) return phone;
    return '${phone.substring(0, phone.length - 4).replaceAll(RegExp(r'\d'), '*')}${phone.substring(phone.length - 4)}';
  }

  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2 || parts[0].isEmpty) return email;
    final name = parts[0];
    final visible = name.length > 1 ? name[0] : name;
    return '$visible***@${parts[1]}';
  }
}