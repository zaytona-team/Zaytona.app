import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../l10n/app_localizations.dart';

/// List settings sheet — rename plus accent-colour picker (prototype:
/// EditListSheet, screens-main.jsx). `PATCH /lists/{listId}` accepts
/// `color` as one of `ZaytonaListAccent`'s 5 values.
class EditListSheet extends StatefulWidget {
  final String initialName;
  final ZaytonaListAccent initialColor;
  final Future<bool> Function(String newName, ZaytonaListAccent color) onSave;

  const EditListSheet({
    super.key,
    required this.initialName,
    required this.initialColor,
    required this.onSave,
  });

  @override
  State<EditListSheet> createState() => _EditListSheetState();
}

class _EditListSheetState extends State<EditListSheet> {
  late final _controller = TextEditingController(text: widget.initialName);
  late ZaytonaListAccent _color = widget.initialColor;
  bool _saving = false;

  bool get _canSave => _controller.text.trim().length >= 2 && !_saving;

  Future<void> _save() async {
    setState(() => _saving = true);
    final ok = await widget.onSave(_controller.text.trim(), _color);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).maybePop();
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          ZaytonaSpacing.space5,
          ZaytonaSpacing.space1,
          ZaytonaSpacing.space5,
          ZaytonaSpacing.space6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.listSettingsTitle, style: ZaytonaType.sheetTitle),
                ZaytonaIconButton(
                  icon: const Icon(Icons.close),
                  tone: ZaytonaIconButtonTone.navy,
                  variant: ZaytonaIconButtonVariant.soft,
                  size: ZaytonaIconButtonSize.sm,
                  semanticLabel: l10n.cancelAction,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
            const SizedBox(height: ZaytonaSpacing.space4),
            Text(l10n.listNameLabel, style: ZaytonaType.fieldLabel),
            const SizedBox(height: ZaytonaSpacing.space2),
            ZaytonaTextField(
              controller: _controller,
              placeholder: l10n.listNameLabel,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: ZaytonaSpacing.space4),
            Text(l10n.listColorLabel, style: ZaytonaType.fieldLabel),
            const SizedBox(height: ZaytonaSpacing.space2),
            ZaytonaColorPicker(
              value: _color,
              onChanged: (accent) => setState(() => _color = accent),
            ),
            const SizedBox(height: ZaytonaSpacing.space4),
            ZaytonaButton(
              label: l10n.saveChangesAction,
              variant: ZaytonaButtonVariant.primary,
              size: ZaytonaButtonSize.lg,
              block: true,
              disabled: !_canSave,
              onTap: _save,
            ),
          ],
        ),
      ),
    );
  }
}
