import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../l10n/app_localizations.dart';

/// Loading placeholder for [NotificationsSheet] while members load.
class NotificationsSheetLoading extends StatelessWidget {
  const NotificationsSheetLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 200, child: Center(child: ZaytonaSpinningLogo()));
  }
}

/// Error placeholder for [NotificationsSheet] with a retry button.
class NotificationsSheetError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const NotificationsSheetError({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: ZaytonaType.bodySm),
            const SizedBox(height: ZaytonaSpacing.space3),
            TextButton(onPressed: onRetry, child: Text(l10n.retryAction)),
          ],
        ),
      ),
    );
  }
}
