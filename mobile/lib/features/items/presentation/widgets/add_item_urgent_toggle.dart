import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../l10n/app_localizations.dart';

/// Tappable "mark as urgent" row.
class AddItemUrgentToggle extends StatelessWidget {
  final bool urgent;
  final ValueChanged<bool> onChanged;

  const AddItemUrgentToggle({
    super.key,
    required this.urgent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => onChanged(!urgent),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ZaytonaSpacing.space4,
          vertical: ZaytonaSpacing.space3,
        ),
        decoration: BoxDecoration(
          color: ZaytonaColors.surfaceSunken,
          border: Border.all(
            color: urgent ? ZaytonaColors.red : ZaytonaColors.borderSoft,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(ZaytonaRadius.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Flexible (not just the Text) so a longer localized label or
            // high font-scale can't push this row wider than the space
            // left by the fixed-width switch — currently short in both
            // languages, but nothing here guarded against it before.
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    size: 18,
                    color: urgent ? ZaytonaColors.red : ZaytonaColors.ink300,
                  ),
                  const SizedBox(width: 9),
                  Flexible(
                    child: Text(
                      l10n.markUrgent,
                      style: ZaytonaType.cardTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            ZaytonaSwitch(
              value: urgent,
              semanticLabel: l10n.markUrgent,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
