import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../l10n/app_localizations.dart';

/// The confirm dialog IS the trip summary — one step, not confirm-then-
/// summary-screen. Guards against an accidental tap mid-shop and doubles
/// as the (future) home for a receipt-scan step.
Future<bool?> showFinishTripDialog(
  BuildContext context, {
  required int bought,
  required int remaining,
}) {
  final l10n = AppLocalizations.of(context)!;

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: ZaytonaColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ZaytonaRadius.lg),
      ),
      title: Text(
        l10n.completeTripTitle,
        textAlign: TextAlign.center,
        style: ZaytonaType.title,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.completeTripBody,
            textAlign: TextAlign.center,
            style: ZaytonaType.caption,
          ),
          const SizedBox(height: ZaytonaSpacing.space3),
          Text(
            l10n.tripSummaryCounts(bought, remaining),
            textAlign: TextAlign.center,
            style: ZaytonaType.bodySm.copyWith(fontWeight: ZaytonaType.fwBold),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ZaytonaButton(
          label: l10n.cancelAction,
          variant: ZaytonaButtonVariant.ghost,
          size: ZaytonaButtonSize.md,
          onTap: () => dialogContext.pop(false),
        ),
        ZaytonaButton(
          label: l10n.confirmAction,
          variant: ZaytonaButtonVariant.mint,
          size: ZaytonaButtonSize.md,
          onTap: () => dialogContext.pop(true),
        ),
      ],
    ),
  );
}
