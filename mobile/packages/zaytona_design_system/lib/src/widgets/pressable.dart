// pressable.dart — ZaytonaPressable
//
// Shared press-feedback wrapper. Every interactive Zaytona widget uses this so
// press behaviour is consistent and defined in one place.
//
// Two modes, matching the CSS prototype:
//   pop   — solid buttons / pop-cards: translate Offset(2,3) px + shadow disappears.
//           The builder receives `pressed` so the child can toggle its BoxShadow.
//   scale — icon buttons / chips: scale(0.88–0.96) on press.
//
// Transition: 80 ms (matches --transition .08s in tokens).

import 'package:flutter/material.dart';

enum ZaytonaPressMode { pop, scale }

class ZaytonaPressable extends StatefulWidget {
  const ZaytonaPressable({
    super.key,
    required this.builder,
    this.onTap,
    this.mode = ZaytonaPressMode.pop,
    this.scaleAmount = 0.9,
    this.disabled = false,
    this.pressEffect = true,
  });

  /// Builder receives the current [pressed] state so the child can adjust its
  /// BoxShadow / fill while the pressable applies the pixel Transform.
  final Widget Function(BuildContext context, bool pressed) builder;
  final VoidCallback? onTap;
  final ZaytonaPressMode mode;

  /// Only used in [ZaytonaPressMode.scale]. Default 0.9 (icon buttons).
  final double scaleAmount;

  /// Blocks taps entirely (a truly inactive control).
  final bool disabled;

  /// When false, taps still fire but no press transform is shown — for
  /// shadowless variants where the CSS source applies no press movement.
  final bool pressEffect;

  @override
  State<ZaytonaPressable> createState() => _ZaytonaPressableState();
}

class _ZaytonaPressableState extends State<ZaytonaPressable> {
  bool _pressed = false;

  static const _duration = Duration(milliseconds: 80);

  void _onDown(TapDownDetails _) {
    if (widget.disabled || !widget.pressEffect) return;
    setState(() => _pressed = true);
  }

  void _onUp(TapUpDetails _) {
    if (widget.disabled) return;
    setState(() => _pressed = false);
    widget.onTap?.call();
  }

  void _onCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final child = widget.builder(context, _pressed);
    final target = _pressed ? 1.0 : 0.0;

    Widget animated;
    if (widget.mode == ZaytonaPressMode.pop) {
      // Translate exactly 2 px right, 3 px down into the shadow direction.
      animated = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: target),
        duration: _duration,
        curve: Curves.easeOut,
        builder: (context, t, _) => Transform.translate(
          offset: Offset(2 * t, 3 * t),
          child: child,
        ),
      );
    } else {
      final targetScale = _pressed ? widget.scaleAmount : 1.0;
      animated = TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: targetScale),
        duration: _duration,
        curve: Curves.easeOut,
        builder: (context, s, _) => Transform.scale(scale: s, child: child),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onDown,
      onTapUp: _onUp,
      onTapCancel: _onCancel,
      child: animated,
    );
  }
}
