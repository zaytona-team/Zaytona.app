import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../l10n/app_localizations.dart';

Future<bool?> showDeleteListDialog(BuildContext context, String listName) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.deleteListConfirmTitle),
      content: Text(l10n.deleteListConfirmBody(listName)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.cancelAction),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.deleteAction, style: const TextStyle(color: ZaytonaColors.red)),
        ),
      ],
    ),
  );
}
