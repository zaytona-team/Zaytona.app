// checkbox.dart — ZaytonaCheckbox
//
// Source spec: design_source/.../components/forms/Checkbox.jsx
//
// Custom widget — Material's Checkbox cannot produce:
//   · mint fill on checked
//   · strike-through + dimmed label text
//   · 2.5px navy border that stays visible in both states
//
// Box fill animates surface-card → mint over 150 ms.
// The tick is a CustomPainter that draws the exact path from the source SVG
// (M5 13l4 4L19 7) scaled to the box size.
// Label dims to opacity 0.55 and gains line-through when checked.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';

class ZaytonaCheckbox extends StatelessWidget {
  const ZaytonaCheckbox({
    super.key,
    required this.checked,
    required this.onChanged,
    this.label,
    this.size = 24,
  });

  final bool checked;
  final void Function(bool) onChanged;
  final String? label;

  /// Box size in logical px. Default 24.
  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = (size * 0.32).roundToDouble();

    return GestureDetector(
      onTap: () => onChanged(!checked),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Box ────────────────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: checked ? ZaytonaColors.mint : ZaytonaColors.surfaceCard,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: ZaytonaColors.navy,
                width: ZaytonaShadows.strokeBold,
              ),
            ),
            child: Center(
              child: AnimatedOpacity(
                opacity: checked ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 120),
                child: CustomPaint(
                  size: Size(size * 0.62, size * 0.62),
                  painter: _TickPainter(),
                ),
              ),
            ),
          ),
          // ── Label ──────────────────────────────────────────────────────────
          if (label != null) ...[
            const SizedBox(width: 10),
            AnimatedOpacity(
              opacity: checked ? 0.55 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Text(
                label!,
                style: TextStyle(
                  fontFamily: ZaytonaType.fontBody,
                  fontSize: ZaytonaType.fsBody,
                  fontWeight: ZaytonaType.fwMedium,
                  color: ZaytonaColors.textBody,
                  decoration:
                      checked ? TextDecoration.lineThrough : TextDecoration.none,
                  decorationColor: ZaytonaColors.ink300,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Draws the checkmark path M5 13l4 4L19 7 on a 24×24 viewBox, scaled to fit.
class _TickPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    final paint = Paint()
      ..color = ZaytonaColors.navy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(5 * scale, 13 * scale)
      ..lineTo(9 * scale, 17 * scale)
      ..lineTo(19 * scale, 7 * scale);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TickPainter _) => false;
}
