import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../l10n/app_localizations.dart';

/// Collapsed-by-default disclosure for the brand and notes fields.
class AddItemExtraDetails extends StatefulWidget {
  final TextEditingController brandController;
  final TextEditingController noteController;

  const AddItemExtraDetails({
    super.key,
    required this.brandController,
    required this.noteController,
  });

  @override
  State<AddItemExtraDetails> createState() => _AddItemExtraDetailsState();
}

class _AddItemExtraDetailsState extends State<AddItemExtraDetails> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(ZaytonaRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: ZaytonaSpacing.space2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.extraDetailsLabel,
                  style: ZaytonaType.fieldLabel.copyWith(color: ZaytonaColors.red),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: ZaytonaColors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          child: _expanded ? _fields(l10n) : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _fields(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: ZaytonaSpacing.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.itemBrandLabel, style: ZaytonaType.fieldLabel),
          const SizedBox(height: ZaytonaSpacing.space2),
          ZaytonaTextField(
            controller: widget.brandController,
            placeholder: l10n.itemBrandHint,
          ),
          const SizedBox(height: ZaytonaSpacing.space4),
          Text(l10n.itemNoteLabel, style: ZaytonaType.fieldLabel),
          const SizedBox(height: ZaytonaSpacing.space2),
          ZaytonaTextField(
            controller: widget.noteController,
            placeholder: l10n.itemNoteHint,
          ),
        ],
      ),
    );
  }
}
