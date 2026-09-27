// error_state.dart — ZaytonaErrorState
//
// Source spec: Zaytona-Design-System-2/components/patterns/ErrorState.jsx —
// full-screen failure block (offline, load failure, broken invite link).
// Same centred rhythm as ZaytonaEmptyState but coral-toned, with a primary
// retry, an optional secondary escape route, and a quiet detail/code pill
// (always LTR). Never leave a blank screen or a bare spinner for this case.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';
import 'button.dart';
import 'star.dart';

class ZaytonaErrorState extends StatelessWidget {
  const ZaytonaErrorState({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.detail,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final Widget icon;
  final String title;
  final String? body;

  /// Quiet technical detail (error/reference code), rendered LTR in a pill.
  final String? detail;

  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ZaytonaStar(size: 112, tone: ZaytonaStarTone.red, child: icon),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: ZaytonaType.fontDisplay,
                fontFamilyFallback: [ZaytonaType.fontBody],
                fontWeight: ZaytonaType.fwBlack,
                fontSize: 22,
                height: 1.35,
                color: ZaytonaColors.navy,
              ),
            ),
            if (body != null) ...[
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(
                  body!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: ZaytonaType.fontBody,
                    fontSize: 14.5,
                    color: ZaytonaColors.textMuted,
                    height: ZaytonaType.lhRelaxed,
                  ),
                ),
              ),
            ],
            if (actionLabel != null || secondaryActionLabel != null) ...[
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Column(
                  children: [
                    if (actionLabel != null)
                      ZaytonaButton(
                        label: actionLabel!,
                        variant: ZaytonaButtonVariant.primary,
                        block: true,
                        onTap: onAction,
                      ),
                    if (actionLabel != null && secondaryActionLabel != null)
                      const SizedBox(height: 8),
                    if (secondaryActionLabel != null)
                      ZaytonaButton(
                        label: secondaryActionLabel!,
                        variant: ZaytonaButtonVariant.ghost,
                        block: true,
                        onTap: onSecondaryAction,
                      ),
                  ],
                ),
              ),
            ],
            if (detail != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ZaytonaColors.surfaceSunken,
                  borderRadius: ZaytonaRadius.brPill,
                ),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    detail!,
                    style: const TextStyle(
                      fontFamily: ZaytonaType.fontBody,
                      fontWeight: ZaytonaType.fwMedium,
                      fontSize: 11.5,
                      color: ZaytonaColors.textHint,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
