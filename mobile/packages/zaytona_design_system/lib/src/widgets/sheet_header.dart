import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';
import 'icon_button.dart';

/// Drag handle + title + close button shared by every bottom sheet
/// (CreateGroupSheet, CreateListSheet, JoinGroupSheet, ...).
class ZaytonaSheetHeader extends StatelessWidget {
  const ZaytonaSheetHeader({
    super.key,
    required this.title,
    required this.onClose,
  });

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: ZaytonaColors.borderHair,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: ZaytonaType.sheetTitle),
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
      ],
    );
  }
}
