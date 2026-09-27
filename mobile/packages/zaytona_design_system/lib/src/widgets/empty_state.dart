// empty_state.dart — ZaytonaEmptyState
//
// Source spec: design_source/.../ui_kits/thalaja-app/screens-main.jsx
// (EmptyState) — the brand's 14-point star as an icon holder, title, body,
// optional CTA. Reusable everywhere an empty list/screen needs this shape
// instead of a page-local ad-hoc empty state.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';
import 'button.dart';
import 'star.dart';

class ZaytonaEmptyState extends StatelessWidget {
  const ZaytonaEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.tone = ZaytonaStarTone.red,
    this.ctaLabel,
    this.onCta,
    this.ctaIcon,
  });

  final Widget icon;
  final String title;
  final String body;
  final ZaytonaStarTone tone;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final Widget? ctaIcon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ZaytonaStar(size: 108, tone: tone, rotate: -6, child: icon),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: ZaytonaType.fontDisplay,
                fontFamilyFallback: [ZaytonaType.fontBody],
                fontWeight: ZaytonaType.fwBlack,
                fontSize: ZaytonaType.fsTitle,
                color: ZaytonaColors.navy,
              ),
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Text(
                body,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: ZaytonaType.fontBody,
                  fontSize: ZaytonaType.fsBodySm,
                  color: ZaytonaColors.textMuted,
                  height: ZaytonaType.lhRelaxed,
                ),
              ),
            ),
            if (ctaLabel != null && onCta != null) ...[
              const SizedBox(height: 18),
              ZaytonaButton(
                label: ctaLabel!,
                variant: ZaytonaButtonVariant.primary,
                size: ZaytonaButtonSize.md,
                iconLeft: ctaIcon ?? const Icon(Icons.add, size: 18),
                onTap: onCta,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
