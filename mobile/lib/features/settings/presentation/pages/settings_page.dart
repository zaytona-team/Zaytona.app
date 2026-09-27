import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/di/session_cleanup.dart';
import '../../../../core/l10n/locale_controller.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../core/notifications/push_notification_service.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:zaytona/features/settings/presentation/widgets/edit_account_sheet.dart';
import '../../data/profile_remote_data_source.dart';
import '../widgets/about_sheet.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ProfileRemoteDataSource _profileApi = ProfileRemoteDataSource();
  String _userName = 'المستخدم';
  String _lastName = '';
  String _phone = '';
  String? _avatarUrl;

  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final phone = await TokenStorage.readPhone();

    try {
      final profile = await _profileApi.getProfile();

      if (!mounted) return;

      setState(() {
        _userName = profile['first_name']?.toString() ?? 'المستخدم';

        _lastName = profile['last_name']?.toString() ?? '';

        _phone = profile['phone']?.toString() ?? phone ?? '';

        _avatarUrl = profile['avatar_url']?.toString();
      });
    } catch (_) {
      final name = await TokenStorage.readFirstName();

      if (!mounted) return;

      setState(() {
        _userName = name ?? 'المستخدم';
        _phone = phone ?? '';
      });
    }
  }

  Future<void> _openEditAccountSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) => EditAccountSheet(
        firstName: _userName,
        lastName: _lastName,
        phone: _phone,
      ),
    );

    if (result == null || !mounted) return;

    final firstName = result['firstName'] as String;
    final avatarUrl = result['avatarUrl'] as String?;

    await TokenStorage.saveFirstName(firstName);

    if (!mounted) return;

    setState(() {
      _userName = firstName;
      _lastName = result['lastName'] as String;
      _avatarUrl = avatarUrl ?? _avatarUrl;
    });
  }

  Future<void> _openAboutSheet() {
    return ZaytonaSheet.show<void>(context, child: const AboutSheet());
  }

  Future<void> _logout() async {
    final router = GoRouter.of(context);

    // Best effort: FCM unregistration must never block clearing the
    // session and navigating away.
    try {
      await sl<PushNotificationService>().unregisterCurrentDevice();
    } on Exception {
      // Ignored — see unregisterCurrentDevice for rationale.
    }

    await TokenStorage.clearToken();

    clearSessionState();

    if (!mounted) return;

    router.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeController = sl<LocaleController>();
    const backgroundColor = ZaytonaColors.bgApp;
    const textColor = Color(0xFF071D49);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ZaytonaSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ZaytonaIconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    tone: ZaytonaIconButtonTone.navy,
                    variant: ZaytonaIconButtonVariant.soft,
                    size: ZaytonaIconButtonSize.sm,
                    semanticLabel: 'Back',
                    onTap: context.pop,
                  ),
                  const SizedBox(width: ZaytonaSpacing.space2),
                  Text(
                    l10n.settingsTitle,
                    style: ZaytonaType.screenTitle.copyWith(color: textColor),
                  ),
                ],
              ),

              const SizedBox(height: ZaytonaSpacing.space6),

              ZaytonaCard(
                variant: ZaytonaCardVariant.pop,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: _avatarUrl == null
                        ? null
                        : NetworkImage(_avatarUrl!),
                    child: _avatarUrl == null ? const Icon(Icons.person) : null,
                  ),
                  title: Text(
                    _userName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  subtitle: Text(
                    _phone,
                    style: TextStyle(color: textColor.withValues(alpha: 0.6)),
                  ),
                  trailing: ZaytonaIconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    tone: ZaytonaIconButtonTone.navy,
                    variant: ZaytonaIconButtonVariant.soft,
                    size: ZaytonaIconButtonSize.sm,
                    semanticLabel: 'تعديل الحساب',
                    onTap: _openEditAccountSheet,
                  ),
                ),
              ),

              const SizedBox(height: ZaytonaSpacing.space6),

              ZaytonaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.languageLabel,
                      style: ZaytonaType.fieldLabel.copyWith(color: textColor),
                    ),
                    const SizedBox(height: ZaytonaSpacing.space2),
                    ValueListenableBuilder<Locale>(
                      valueListenable: localeController,
                      builder: (context, locale, _) {
                        return ZaytonaToggleSwitch(
                          leftValue: 'ar',
                          leftLabel: l10n.arabicLanguage,
                          rightValue: 'en',
                          rightLabel: l10n.englishLanguage,
                          value: locale.languageCode,
                          onChanged: (code) {
                            localeController.switchTo(Locale(code));
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: ZaytonaSpacing.space5),

              ZaytonaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.notificationsLabel,
                      style: ZaytonaType.fieldLabel.copyWith(color: textColor),
                    ),
                    const SizedBox(height: ZaytonaSpacing.space2),
                    ZaytonaToggleSwitch(
                      leftValue: 'enabled',
                      leftLabel: l10n.enableAction,
                      rightValue: 'disabled',
                      rightLabel: l10n.disableAction,
                      value: _notificationsEnabled ? 'enabled' : 'disabled',
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value == 'enabled';
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: ZaytonaSpacing.space5),

              ZaytonaCard(
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: ZaytonaColors.surfaceSunken,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: ZaytonaColors.navy,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    l10n.aboutTitle,
                    style: ZaytonaType.fieldLabel.copyWith(
                      color: textColor,
                      fontWeight: ZaytonaType.fwBold,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: ZaytonaColors.ink300,
                  ),
                  onTap: _openAboutSheet,
                ),
              ),

              const Spacer(),

              ZaytonaButton(
                label: l10n.logoutAction,
                variant: ZaytonaButtonVariant.danger,
                size: ZaytonaButtonSize.lg,
                block: true,
                iconLeft: const Icon(Icons.logout, size: 20),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
