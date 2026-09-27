import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../l10n/app_localizations.dart';

Future<void> confirmDangerDialog(
  BuildContext context,
  AppLocalizations l10n, {
  required String title,
  required String body,
  required String confirmLabel,
  required VoidCallback onConfirm,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: ZaytonaColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ZaytonaRadius.lg),
        side: const BorderSide(
          color: ZaytonaColors.borderBold,
          width: ZaytonaShadows.strokeBold,
        ),
      ),
      title: Text(title, style: ZaytonaType.sheetTitle),
      content: Text(body, style: ZaytonaType.bodySm),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        ZaytonaButton(
          label: l10n.cancelAction,
          variant: ZaytonaButtonVariant.outline,
          size: ZaytonaButtonSize.sm,
          onTap: () => Navigator.of(dialogContext).pop(false),
        ),
        ZaytonaButton(
          label: confirmLabel,
          variant: ZaytonaButtonVariant.danger,
          size: ZaytonaButtonSize.sm,
          onTap: () => Navigator.of(dialogContext).pop(true),
        ),
      ],
    ),
  );
  if (confirmed == true) onConfirm();
}
