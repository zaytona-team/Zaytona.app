// dialog.dart — ZaytonaDialog
//
// Source spec: Zaytona-Design-System-2/components/patterns/Dialog.jsx —
// centred confirm dialog: navy outline + large pop shadow. Cancel = outline
// button, confirm = primary/danger button.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';
import 'button.dart';

class ZaytonaDialog extends StatelessWidget {
  const ZaytonaDialog({
    super.key,
    this.title,
    this.body,
    this.cancelLabel,
    this.confirmLabel,
    this.onCancel,
    this.onConfirm,
    this.danger = false,
    this.child,
  });

  final String? title;
  final String? body;
  final String? cancelLabel;
  final String? confirmLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  /// Confirm button uses the danger variant instead of primary.
  final bool danger;

  /// Custom content; overrides [title]/[body] when provided.
  final Widget? child;

  /// Shows the dialog as a centred confirm sheet with the brand scrim.
  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    String? body,
    String? cancelLabel,
    String? confirmLabel,
    VoidCallback? onConfirm,
    bool danger = false,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: const Color(0x730D0050), // navy @ 45%
      builder: (dialogContext) => ZaytonaDialog(
        title: title,
        body: body,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        danger: danger,
        onCancel: () => Navigator.of(dialogContext).pop(false),
        onConfirm: () {
          Navigator.of(dialogContext).pop(true);
          onConfirm?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 22, vertical: 24),
        decoration: BoxDecoration(
          color: ZaytonaColors.surfaceCard,
          border: Border.all(color: ZaytonaColors.navy, width: ZaytonaShadows.strokeBold),
          borderRadius: ZaytonaRadius.brXl,
          boxShadow: ZaytonaShadows.shadowPopLg,
        ),
        child: child ??
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) Text(title!, style: ZaytonaType.sheetTitle),
                if (body != null) ...[
                  const SizedBox(height: 8),
                  Text(body!, style: ZaytonaType.body),
                ],
                if (cancelLabel != null || confirmLabel != null) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (cancelLabel != null)
                        Expanded(
                          child: ZaytonaButton(
                            label: cancelLabel!,
                            variant: ZaytonaButtonVariant.outline,
                            onTap: onCancel,
                          ),
                        ),
                      if (cancelLabel != null && confirmLabel != null)
                        const SizedBox(width: 10),
                      if (confirmLabel != null)
                        Expanded(
                          child: ZaytonaButton(
                            label: confirmLabel!,
                            variant: danger
                                ? ZaytonaButtonVariant.danger
                                : ZaytonaButtonVariant.primary,
                            onTap: onConfirm,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
      ),
    );
  }
}
