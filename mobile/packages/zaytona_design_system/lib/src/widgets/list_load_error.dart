import 'package:flutter/material.dart';

import '../tokens/zaytona_theme.dart';

/// Shared "message + retry" state for a failed list/items load.
class ZaytonaListLoadError extends StatelessWidget {
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;
  final Color? textColor;

  const ZaytonaListLoadError({
    super.key,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: ZaytonaType.bodySm.copyWith(color: textColor)),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: Text(retryLabel)),
        ],
      ),
    );
  }
}
