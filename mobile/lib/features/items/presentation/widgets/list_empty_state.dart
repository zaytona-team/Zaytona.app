import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../l10n/app_localizations.dart';

class ListEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const ListEmptyState({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ZaytonaEmptyState(
      icon: const Icon(Icons.checklist_outlined),
      title: l10n.noItemsTitle,
      body: l10n.noItemsBody,
      ctaLabel: l10n.addItemAction,
      onCta: onAdd,
    );
  }
}
