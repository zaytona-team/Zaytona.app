// qty_stepper.dart — ZaytonaQtyStepper
//
// Source spec: design_source/.../components/forms/QtyStepper.jsx
//
// Controlled widget — the parent (or Cubit) owns the value and clamps it.
// ZaytonaQtyStepper only fires onChanged; it never holds state internally.
//
// − and + buttons: pill shape, 2px navy border, surface-card fill, scale(0.88) press.
// Value: display font 800, tabular-nums so digits don't shift width.
// Optional unit suffix: body font 700 11px, text-muted color.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';
import 'pressable.dart';

enum ZaytonaQtyStepperSize { sm, md }

class ZaytonaQtyStepper extends StatelessWidget {
  const ZaytonaQtyStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 99,
    this.unit,
    this.size = ZaytonaQtyStepperSize.md,
  });

  final int value;
  final void Function(int) onChanged;
  final int min;
  final int max;

  /// Optional unit label shown after the number (e.g. "kg").
  final String? unit;

  final ZaytonaQtyStepperSize size;

  void _set(int n) => onChanged(n.clamp(min, max));

  @override
  Widget build(BuildContext context) {
    final btnDim = size == ZaytonaQtyStepperSize.sm ? 30.0 : 36.0;
    final fontSize = size == ZaytonaQtyStepperSize.sm
        ? ZaytonaType.fsBody       // 16
        : ZaytonaType.fsBodyLg;    // 18
    final minValueWidth = size == ZaytonaQtyStepperSize.sm ? 22.0 : 26.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _StepBtn(
          sign: _StepSign.minus,
          dim: btnDim,
          disabled: value <= min,
          onTap: () => _set(value - 1),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: minValueWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$value',
                style: TextStyle(
                  fontFamily: ZaytonaType.fontDisplay,
                  fontFamilyFallback: const [ZaytonaType.fontBody],
                  fontWeight: ZaytonaType.fwBlack,
                  fontSize: fontSize,
                  color: ZaytonaColors.navy,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 3),
                Text(
                  unit!,
                  style: const TextStyle(
                    fontFamily: ZaytonaType.fontBody,
                    fontWeight: ZaytonaType.fwBold,
                    fontSize: ZaytonaType.fsMicro, // 11
                    color: ZaytonaColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),
        _StepBtn(
          sign: _StepSign.plus,
          dim: btnDim,
          disabled: value >= max,
          onTap: () => _set(value + 1),
        ),
      ],
    );
  }
}

enum _StepSign { minus, plus }

class _StepBtn extends StatelessWidget {
  const _StepBtn({
    required this.sign,
    required this.dim,
    required this.disabled,
    required this.onTap,
  });

  final _StepSign sign;
  final double dim;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.3 : 1.0,
      child: ZaytonaPressable(
        onTap: disabled ? null : onTap,
        mode: ZaytonaPressMode.scale,
        scaleAmount: 0.88,
        disabled: disabled,
        builder: (context, _) => DecoratedBox(
          decoration: BoxDecoration(
            color: ZaytonaColors.surfaceCard,
            shape: BoxShape.circle,
            border: Border.all(color: ZaytonaColors.navy, width: 2),
          ),
          child: SizedBox(
            width: dim,
            height: dim,
            child: Center(
              child: CustomPaint(
                size: const Size(15, 15),
                painter: _SignPainter(sign),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Draws − or + icon matching the SVG in the source.
class _SignPainter extends CustomPainter {
  const _SignPainter(this.sign);
  final _StepSign sign;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ZaytonaColors.navy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2 * (size.width / 24)
      ..strokeCap = StrokeCap.round;

    final s = size.width / 24;
    // Horizontal bar (both signs)
    canvas.drawLine(Offset(6 * s, 12 * s), Offset(18 * s, 12 * s), paint);
    // Vertical bar (+ only)
    if (sign == _StepSign.plus) {
      canvas.drawLine(Offset(12 * s, 6 * s), Offset(12 * s, 18 * s), paint);
    }
  }

  @override
  bool shouldRepaint(_SignPainter old) => old.sign != sign;
}
