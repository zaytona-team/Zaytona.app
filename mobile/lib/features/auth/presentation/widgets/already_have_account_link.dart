import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../l10n/app_localizations.dart';

/// "Already have an account? Log in" link shown under the signup form.
class AlreadyHaveAccountLink extends StatelessWidget {
  const AlreadyHaveAccountLink({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Text.rich(
          TextSpan(
            style: ZaytonaType.bodySm,
            children: [
              TextSpan(text: '${l10n.alreadyHaveAccountPrompt} '),
              TextSpan(
                text: l10n.loginAction,
                style: const TextStyle(color: ZaytonaColors.red, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
