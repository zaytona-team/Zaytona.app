import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../l10n/app_localizations.dart';

/// Item name field with inline validation error and the non-blocking
/// possible-duplicate hint (business rule: user can proceed anyway).
class AddItemNameField extends StatelessWidget {
  final TextEditingController controller;
  final String? error;
  final bool showDuplicateWarning;
  final ValueChanged<String> onChanged;

  const AddItemNameField({
    super.key,
    required this.controller,
    required this.error,
    required this.showDuplicateWarning,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.itemNameLabel, style: ZaytonaType.fieldLabel),
        const SizedBox(height: ZaytonaSpacing.space2),
        ZaytonaTextField(
          controller: controller,
          placeholder: l10n.itemNameHint,
          autofocus: true,
          error: error,
          onChanged: onChanged,
        ),
        if (showDuplicateWarning) ...[
          const SizedBox(height: ZaytonaSpacing.space2),
          ZaytonaBanner(
            title: l10n.possibleDuplicateTitle,
            body: l10n.possibleDuplicateBody(controller.text.trim()),
            icon: const Icon(Icons.warning_amber_rounded),
          ),
        ],
      ],
    );
  }
}
