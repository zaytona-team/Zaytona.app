import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';

import 'zaytona_spinning_logo.dart';

/// Branded pull-to-refresh used across every scrollable screen: reveals
/// the Zaytona logo as the user pulls down, then spins it while
/// [onRefresh] is in flight, instead of the stock Material spinner.
class ZaytonaRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const ZaytonaRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  static const double _maxPull = 70;
  static const double _logoSize = 34;

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      onRefresh: onRefresh,
      trigger: IndicatorTrigger.leadingEdge,
      builder: (context, child, controller) {
        final pull = controller.value.clamp(0.0, 1.5);
        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: pull * _maxPull,
              child: Center(
                child: Opacity(
                  opacity: pull.clamp(0.0, 1.0),
                  child: controller.isLoading
                      ? const ZaytonaSpinningLogo(size: _logoSize)
                      : Transform.scale(
                          scale: (0.6 + pull * 0.4).clamp(0.0, 1.0),
                          child: _logo(),
                        ),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(0, pull * _maxPull),
              child: child,
            ),
          ],
        );
      },
      child: child,
    );
  }

  static Widget _logo() => Image.asset(
        'packages/zaytona_design_system/assets/images/zaytona.png',
        width: _logoSize,
        height: _logoSize,
      );
}
