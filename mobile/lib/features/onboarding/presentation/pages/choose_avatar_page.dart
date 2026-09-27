import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/data/profile_remote_data_source.dart';

/// Onboarding step after register→OTP (prototype: ChooseAvatar,
/// screens-auth.jsx): pick a mascot avatar. Avatars and the selection
/// itself are backend-driven (GET /auth/avatars, POST
/// /auth/profile/avatar/select) via [ProfileRemoteDataSource].
class ChooseAvatarPage extends StatefulWidget {
  const ChooseAvatarPage({super.key});

  @override
  State<ChooseAvatarPage> createState() => _ChooseAvatarPageState();
}

class _ChooseAvatarPageState extends State<ChooseAvatarPage> {
  final _api = ProfileRemoteDataSource();

  List<Map<String, dynamic>> _avatars = [];
  Map<String, dynamic>? _selected;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadAvatars();
  }

  Future<void> _loadAvatars() async {
    try {
      _avatars = await _api.getAvatars();
      if (_avatars.isNotEmpty) {
        _selected = _avatars.first;
      }
    } catch (_) {
      if (mounted) {
        _showMessage(AppLocalizations.of(context)!.avatarsLoadError);
      }    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  String? _avatarUrl(Map<String, dynamic>? avatar) {
    return avatar?['url']?.toString() ??
        avatar?['avatar_url']?.toString() ??
        avatar?['image_url']?.toString();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _continue() async {
    final router = GoRouter.of(context);
    final selected = _selected;
    if (selected == null) return;

    setState(() => _saving = true);
    try {
      await _api.selectAvatar(selected['id']);
      router.go('/onboarding/first-group');
    } catch (_) {
      if (mounted) {
        _showMessage(AppLocalizations.of(context)!.avatarSelectError);
      }    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: ZaytonaColors.bgApp,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            ZaytonaSpacing.space6,
            ZaytonaSpacing.space6,
            ZaytonaSpacing.space6,
            ZaytonaSpacing.space6,
          ),
          child: Column(
            children: [
              Expanded(
                child: _loading
                    ? const Center(child: ZaytonaSpinningLogo())
                    : _content(l10n),
              ),
              ZaytonaButton(
                label: l10n.continueAction,
                variant: ZaytonaButtonVariant.primary,
                size: ZaytonaButtonSize.lg,
                block: true,
                disabled: _selected == null || _saving,
                onTap: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Big preview of the current pick.
        ZaytonaAvatar(
          src: _avatarUrl(_selected),
          size: 110,
        ),
        SizedBox(height: ZaytonaSpacing.space6),
        Text(
          l10n.chooseAvatarTitle,
          style: ZaytonaType.displaySm,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: ZaytonaSpacing.space2),
        Text(
          l10n.chooseAvatarBody,
          style: ZaytonaType.caption,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: ZaytonaSpacing.space6),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          alignment: WrapAlignment.center,
          children: [
            for (final avatar in _avatars)
              GestureDetector(
                onTap: () => setState(() => _selected = avatar),
                child: AnimatedScale(
                  scale: avatar == _selected ? 1.08 : 1,
                  duration: const Duration(milliseconds: 120),
                  child: ZaytonaAvatar(
                    src: _avatarUrl(avatar),
                    size: 66,
                    ringColor: avatar == _selected
                        ? ZaytonaColors.red
                        : ZaytonaColors.ink100,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
