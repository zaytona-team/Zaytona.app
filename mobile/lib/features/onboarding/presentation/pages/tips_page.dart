import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../l10n/app_localizations.dart';

/// Onboarding closer: a few quick, fun-toned orientation tips before
/// landing in /home. Shown after every first-group sub-path (create +
/// invite, join with code, or skip).
class TipsPage extends StatelessWidget {
  const TipsPage({super.key});

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: ZaytonaSpacing.space3),
              Text(
                l10n.tipsTitle,
                style: ZaytonaType.displaySm,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ZaytonaSpacing.space6),
              Expanded(
                child: ListView(
                  children: [
                    _TipCard(
                      icon: Icons.menu,
                      title: l10n.tipDrawerTitle,
                      body: l10n.tipDrawerBody,
                    ),
                    SizedBox(height: ZaytonaSpacing.space4),
                    _TipCard(
                      icon: Icons.person_outline,
                      title: l10n.tipPersonalGroupTitle,
                      body: l10n.tipPersonalGroupBody,
                    ),
                    SizedBox(height: ZaytonaSpacing.space4),
                    _TipCard(
                      icon: Icons.add,
                      title: l10n.tipCreateListTitle,
                      body: l10n.tipCreateListBody,
                    ),
                    SizedBox(height: ZaytonaSpacing.space4),
                    _TipCard(
                      icon: Icons.settings_outlined,
                      title: l10n.tipGroupSettingsTitle,
                      body: l10n.tipGroupSettingsBody,
                    ),
                  ],
                ),
              ),
              ZaytonaButton(
                label: l10n.letsGoAction,
                variant: ZaytonaButtonVariant.primary,
                size: ZaytonaButtonSize.lg,
                block: true,
                onTap: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _TipCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return ZaytonaCard(
      variant: ZaytonaCardVariant.plain,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: ZaytonaColors.indigoTint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: ZaytonaColors.indigo, size: 20),
          ),
          SizedBox(width: ZaytonaSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ZaytonaType.fieldLabel),
                SizedBox(height: ZaytonaSpacing.space1),
                Text(body, style: ZaytonaType.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
