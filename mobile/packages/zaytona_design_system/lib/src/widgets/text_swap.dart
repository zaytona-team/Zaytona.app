// text_swap.dart — ZaytonaTextSwap
//
// Source spec: design_source/.../ui_kits/thalaja-app/screens-auth.jsx TextSwap
// Muted prompt + indigo display-font action, centered — the "already have an
// account? Sign in" pattern under auth forms.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';

class ZaytonaTextSwap extends StatelessWidget {
  const ZaytonaTextSwap({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  /// Muted lead-in text ("Already have an account?").
  final String prompt;

  /// Indigo tappable action label ("Sign in").
  final String action;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              prompt,
              style: const TextStyle(
                fontFamily: ZaytonaType.fontBody,
                fontSize: ZaytonaType.fsBodySm,
                color: ZaytonaColors.textMuted,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              action,
              style: const TextStyle(
                fontFamily: ZaytonaType.fontDisplay,
                fontFamilyFallback: [ZaytonaType.fontBody],
                fontWeight: ZaytonaType.fwBold,
                fontSize: ZaytonaType.fsBodySm,
                color: ZaytonaColors.link,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
