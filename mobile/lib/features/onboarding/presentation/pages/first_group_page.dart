import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../groups/presentation/pages/create_group_sheet.dart';
import '../../../groups/presentation/pages/join_group_sheet.dart';

/// Onboarding step after choosing an avatar (prototype: FirstGroup,
/// screens-auth.jsx): create the family group, join with a code, or skip.
/// Register flow only — the user already has their private group.
class FirstGroupPage extends StatelessWidget {
  const FirstGroupPage({super.key});

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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ZaytonaStar(
                      size: 120,
                      tone: ZaytonaStarTone.indigo,
                      rotate: 6,
                      child: const Icon(Icons.home_outlined, size: 50),
                    ),
                    SizedBox(height: ZaytonaSpacing.space6),
                    Text(
                      l10n.firstGroupTitle,
                      style: ZaytonaType.displaySm,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.firstGroupBody,
                      style: ZaytonaType.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              ZaytonaButton(
                label: l10n.createFamilyGroupAction,
                variant: ZaytonaButtonVariant.primary,
                size: ZaytonaButtonSize.lg,
                block: true,
                iconLeft: const Icon(Icons.add, size: 20),
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => CreateGroupSheet(
                    onSuccess: (group) => context.go(
                      '/onboarding/invite?code=${group.inviteCode ?? ''}',
                    ),
                  ),
                ),
              ),
              SizedBox(height: ZaytonaSpacing.space3),
              ZaytonaButton(
                label: l10n.joinWithCodeAction,
                variant: ZaytonaButtonVariant.outline,
                size: ZaytonaButtonSize.lg,
                block: true,
                iconLeft: const Icon(Icons.person_add_alt, size: 20),
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => JoinGroupSheet(
                    onSuccess: (_) => context.go('/onboarding/tips'),
                  ),
                ),
              ),
              SizedBox(height: ZaytonaSpacing.space3),
              ZaytonaButton(
                label: l10n.skipForNowAction,
                variant: ZaytonaButtonVariant.ghost,
                size: ZaytonaButtonSize.md,
                block: true,
                onTap: () => context.go('/onboarding/tips'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
