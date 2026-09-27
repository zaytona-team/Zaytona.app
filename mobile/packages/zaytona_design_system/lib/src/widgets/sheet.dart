// sheet.dart — ZaytonaSheet
//
// Source spec: Zaytona-Design-System-2/components/patterns/Sheet.jsx —
// bottom-sheet shell: scrim + rounded navy-outlined panel with a grab
// handle. Body scrolls, actions are pinned by the caller's own layout.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';

class ZaytonaSheet extends StatelessWidget {
  const ZaytonaSheet({
    super.key,
    required this.child,
    this.onClose,
    this.maxHeightFraction = 0.86,
  });

  final Widget child;
  final VoidCallback? onClose;
  final double maxHeightFraction;

  /// Shows the sheet as a modal bottom sheet with the brand scrim + panel.
  static Future<T?> show<T>(BuildContext context, {required Widget child}) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x6B0D0050), // navy @ 42%
      isScrollControlled: true,
      builder: (_) => ZaytonaSheet(
        onClose: () => Navigator.of(context).maybePop(),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * maxHeightFraction,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: ZaytonaColors.surfaceCard,
          border: Border(
            top: BorderSide(color: ZaytonaColors.navy, width: ZaytonaShadows.strokeBold),
            left: BorderSide(color: ZaytonaColors.navy, width: ZaytonaShadows.strokeBold),
            right: BorderSide(color: ZaytonaColors.navy, width: ZaytonaShadows.strokeBold),
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(color: Color(0x330D0050), offset: Offset(0, -10), blurRadius: 40),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              decoration: BoxDecoration(
                color: ZaytonaColors.ink100,
                borderRadius: ZaytonaRadius.brPill,
              ),
            ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
