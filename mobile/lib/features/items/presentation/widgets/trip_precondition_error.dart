import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../l10n/app_localizations.dart';

/// Shown if the buying view is reached without an active trip on the list
/// — a precondition failure (Start Trip should have locked one already),
/// not something to silently work around.
class TripPreconditionError extends StatelessWidget {
  final String groupId;

  const TripPreconditionError({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.noActiveTripError,
            style: ZaytonaType.bodySm.copyWith(color: ZaytonaColors.cream),
          ),
          const SizedBox(height: ZaytonaSpacing.space3),
          ZaytonaButton(
            label: l10n.backToGroupAction,
            variant: ZaytonaButtonVariant.mint,
            size: ZaytonaButtonSize.md,
            onTap: () => context.go('/groups/$groupId'),
          ),
        ],
      ),
    );
  }
}
