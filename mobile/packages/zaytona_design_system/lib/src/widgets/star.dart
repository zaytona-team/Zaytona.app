// star.dart — ZaytonaStar (alias ZaytonaBlob)
//
// Source spec: design_source/.../components/patterns/Star.jsx — the brand's
// 14-point star. Tone fill, optional halo outline, optional rotation with a
// counter-rotated child glyph. The path below is the exact STAR14_PATH from
// the prototype (220x220 viewBox), replayed with cubicTo.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';

enum ZaytonaStarTone { red, mint, indigo, lilac, navy, cream }

class ZaytonaStar extends StatelessWidget {
  const ZaytonaStar({
    super.key,
    this.size = 80,
    this.tone = ZaytonaStarTone.red,
    this.halo = ZaytonaColors.cream,
    this.haloWidth = 7,
    this.rotate = 0,
    this.child,
  });

  final double size;
  final ZaytonaStarTone tone;

  /// Outline color; null for no halo (decorative background blobs).
  final Color? halo;
  final double haloWidth;

  /// Rotation in degrees; the child stays upright (counter-rotated).
  final double rotate;
  final Widget? child;

  Color get fill => switch (tone) {
        ZaytonaStarTone.red => ZaytonaColors.red,
        ZaytonaStarTone.mint => ZaytonaColors.mint,
        ZaytonaStarTone.indigo => ZaytonaColors.indigo,
        ZaytonaStarTone.lilac => ZaytonaColors.lilac,
        ZaytonaStarTone.navy => ZaytonaColors.navy,
        ZaytonaStarTone.cream => ZaytonaColors.cream,
      };

  /// Ink color that reads on this tone (prototype _glyphInk):
  /// navy on mint/lilac/cream, cream on red/indigo/navy.
  Color get ink => switch (tone) {
        ZaytonaStarTone.mint ||
        ZaytonaStarTone.lilac ||
        ZaytonaStarTone.cream =>
          ZaytonaColors.navy,
        _ => ZaytonaColors.cream,
      };

  @override
  Widget build(BuildContext context) {
    final radians = rotate * math.pi / 180;
    return SizedBox(
      width: size,
      height: size,
      child: Transform.rotate(
        angle: radians,
        child: CustomPaint(
          painter: _Star14Painter(
            fill: fill,
            halo: halo,
            haloWidth: haloWidth,
          ),
          child: child == null
              ? null
              : Transform.rotate(
                  angle: -radians,
                  child: Center(
                    child: IconTheme(
                      data: IconThemeData(color: ink),
                      child: child!,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

/// Deprecated prototype alias — same widget.
typedef ZaytonaBlob = ZaytonaStar;

class _Star14Painter extends CustomPainter {
  const _Star14Painter({
    required this.fill,
    required this.halo,
    required this.haloWidth,
  });

  final Color fill;
  final Color? halo;
  final double haloWidth;

  // STAR14_PATH control points (220x220 viewBox): M x,y then repeated
  // cubics of [c1x,c1y,c2x,c2y,x,y].
  static const List<double> _cubics = [
    115.79, 14.00, 120.41, 32.37, 127.36, 33.96, //
    134.30, 35.54, 146.44, 21.00, 151.65, 23.51,
    156.87, 26.02, 153.07, 44.58, 158.63, 49.02,
    164.20, 53.46, 181.45, 45.62, 185.06, 50.14,
    188.66, 54.67, 177.19, 69.74, 180.28, 76.16,
    183.37, 82.57, 202.31, 83.00, 203.59, 88.64,
    204.88, 94.28, 188.00, 102.88, 188.00, 110.00,
    188.00, 117.12, 204.88, 125.72, 203.59, 131.36,
    202.31, 137.00, 183.37, 137.43, 180.28, 143.84,
    177.19, 150.26, 188.66, 165.33, 185.06, 169.86,
    181.45, 174.38, 164.20, 166.54, 158.63, 170.98,
    153.07, 175.42, 156.87, 193.98, 151.65, 196.49,
    146.44, 199.00, 134.30, 184.46, 127.36, 186.04,
    120.41, 187.63, 115.79, 206.00, 110.00, 206.00,
    104.21, 206.00, 99.59, 187.63, 92.64, 186.04,
    85.70, 184.46, 73.56, 199.00, 68.35, 196.49,
    63.13, 193.98, 66.93, 175.42, 61.37, 170.98,
    55.80, 166.54, 38.55, 174.38, 34.94, 169.86,
    31.34, 165.33, 42.81, 150.26, 39.72, 143.84,
    36.63, 137.43, 17.69, 137.00, 16.41, 131.36,
    15.12, 125.72, 32.00, 117.12, 32.00, 110.00,
    32.00, 102.88, 15.12, 94.28, 16.41, 88.64,
    17.69, 83.00, 36.63, 82.57, 39.72, 76.16,
    42.81, 69.74, 31.34, 54.67, 34.94, 50.14,
    38.55, 45.62, 55.80, 53.46, 61.37, 49.02,
    66.93, 44.58, 63.13, 26.02, 68.35, 23.51,
    73.56, 21.00, 85.70, 35.54, 92.64, 33.96,
    99.59, 32.37, 104.21, 14.00, 110.00, 14.00,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 220;
    final path = Path()..moveTo(110 * s, 14 * s);
    for (var i = 0; i < _cubics.length; i += 6) {
      path.cubicTo(
        _cubics[i] * s,
        _cubics[i + 1] * s,
        _cubics[i + 2] * s,
        _cubics[i + 3] * s,
        _cubics[i + 4] * s,
        _cubics[i + 5] * s,
      );
    }
    path.close();

    canvas.drawPath(path, Paint()..color = fill);
    if (halo != null) {
      canvas.drawPath(
        path,
        Paint()
          ..color = halo!
          ..style = PaintingStyle.stroke
          ..strokeWidth = haloWidth * s,
      );
    }
  }

  @override
  bool shouldRepaint(_Star14Painter old) =>
      old.fill != fill || old.halo != halo || old.haloWidth != haloWidth;
}
