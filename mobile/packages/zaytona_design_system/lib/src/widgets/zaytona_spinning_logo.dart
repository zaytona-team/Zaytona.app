import 'package:flutter/material.dart';

/// The Zaytona logo, continuously rotating — the app's one loading motif.
/// Used both by [ZaytonaRefreshIndicator] (pull-to-refresh) and by any row
/// that wants to show "this action is waiting on the backend" without
/// blocking the rest of the screen.
class ZaytonaSpinningLogo extends StatefulWidget {
  final double size;

  const ZaytonaSpinningLogo({super.key, this.size = 34});

  @override
  State<ZaytonaSpinningLogo> createState() => _ZaytonaSpinningLogoState();
}

class _ZaytonaSpinningLogoState extends State<ZaytonaSpinningLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Image.asset(
        'packages/zaytona_design_system/assets/images/zaytona.png',
        width: widget.size,
        height: widget.size,
      ),
    );
  }
}
