import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

/// Sheet title + close button.
class AddItemSheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const AddItemSheetHeader({
    super.key,
    required this.title,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ZaytonaSpacing.space5,
        ZaytonaSpacing.space1,
        ZaytonaSpacing.space5,
        ZaytonaSpacing.space3,
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: ZaytonaType.sheetTitle)),
          ZaytonaIconButton(
            icon: const Icon(Icons.close, size: 18),
            tone: ZaytonaIconButtonTone.navy,
            variant: ZaytonaIconButtonVariant.soft,
            size: ZaytonaIconButtonSize.sm,
            semanticLabel: 'Close',
            onTap: onClose,
          ),
        ],
      ),
    );
  }
}
