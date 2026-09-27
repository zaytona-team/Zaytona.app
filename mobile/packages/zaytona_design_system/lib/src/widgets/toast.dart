// toast.dart — ZaytonaToast
//
// Source spec: Zaytona-Design-System-2/components/patterns/Toast.jsx —
// transient navy-pill toast, centered near the bottom. Use for transient
// confirmations only; ZaytonaBanner is for inline warnings inside a working
// screen, ZaytonaErrorState for a screen that cannot render.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';

class ZaytonaToast extends StatelessWidget {
  const ZaytonaToast({super.key, required this.message, this.icon});

  final String message;
  final Widget? icon;

  /// Shows a transient toast for [duration], anchored near the bottom of the
  /// screen, matching the prototype's `bottom: 96`.
  static void show(
    BuildContext context, {
    required String message,
    Widget? icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        left: 20,
        right: 20,
        bottom: 96,
        child: IgnorePointer(
          child: Center(
            child: ZaytonaToast(message: message, icon: icon),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(duration, entry.remove);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: ZaytonaColors.navy,
        borderRadius: ZaytonaRadius.brPill,
        boxShadow: ZaytonaShadows.shadowMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 9)],
          Text(
            message,
            style: const TextStyle(
              fontFamily: ZaytonaType.fontDisplay,
              fontFamilyFallback: [ZaytonaType.fontBody],
              fontWeight: ZaytonaType.fwBold,
              fontSize: 14.5,
              color: ZaytonaColors.cream,
            ),
          ),
        ],
      ),
    );
  }
}
