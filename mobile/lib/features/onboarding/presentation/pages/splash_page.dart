import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/token_storage.dart';
import '../../../groups/presentation/cubit/groups/list_groups_cubit.dart';

/// Prototype: Splash, screens-auth.jsx.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  // Prototype: onDone fires at 2.5s; the mark pop + fade-out play inside it.
  static const _splashDuration = Duration(milliseconds: 2500);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..forward();

  late final Animation<double> _pop = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutBack,
  );

  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    final delay = Future.delayed(_splashDuration);
    final token = await TokenStorage.readToken();
    if (token != null && token.isNotEmpty) {
      sl<ListGroupsCubit>().load();
    }
    await delay;
    if (!mounted) return;
    setState(() => _leaving = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    context.go(token == null || token.isEmpty ? '/welcome' : '/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _route,
      child: Scaffold(
        backgroundColor: ZaytonaColors.bgApp,
        body: AnimatedOpacity(
          opacity: _leaving ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          child: Stack(
            children: [
              PositionedDirectional(
                top: -70,
                start: -60,
                child: _DriftingSeal(
                  size: 220,
                  tone: ZaytonaStarTone.mint,
                  reverse: false,
                  seconds: 26,
                  opacity: 0.12,
                ),
              ),
              PositionedDirectional(
                bottom: -90,
                end: -70,
                child: _DriftingSeal(
                  size: 260,
                  tone: ZaytonaStarTone.red,
                  reverse: true,
                  seconds: 34,
                  opacity: 0.1,
                ),
              ),
              Center(
                child: FadeTransition(
                  opacity: _controller,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: Tween(begin: 0.6, end: 1.0).animate(_pop),
                        child: Image.asset(
                          'assets/images/logo_mark.png',
                          width: 128,
                          height: 128,
                        ),
                      ),
                      SizedBox(height: ZaytonaSpacing.space4),
                      Text('Zaytona زيتونة', style: ZaytonaType.displaySm),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Slow continuous rotation behind the mark (prototype: zspin-slow keyframes).
class _DriftingSeal extends StatefulWidget {
  const _DriftingSeal({
    required this.size,
    required this.tone,
    required this.reverse,
    required this.seconds,
    required this.opacity,
  });

  final double size;
  final ZaytonaStarTone tone;
  final bool reverse;
  final int seconds;
  final double opacity;

  @override
  State<_DriftingSeal> createState() => _DriftingSealState();
}

class _DriftingSealState extends State<_DriftingSeal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(seconds: widget.seconds),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.opacity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final turns = widget.reverse ? -_controller.value : _controller.value;
          return Transform.rotate(angle: turns * 2 * 3.14159265, child: child);
        },
        child: ZaytonaStar(size: widget.size, tone: widget.tone, halo: null),
      ),
    );
  }
}
