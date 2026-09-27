// switch.dart — ZaytonaSwitch
//
// Source spec: design_source/.../screens-flows.jsx "Mark as urgent" toggle
// (46×27 pill track, 2px navy border, 20×20 cream thumb sliding on
// inset-inline-start, red when on / ink-100 when off).
//
// Custom widget — Material's Switch cannot produce the navy outline or the
// exact red/ink-100 track fill this brand uses.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';

class ZaytonaSwitch extends StatelessWidget {
  const ZaytonaSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  final bool value;
  final void Function(bool) onChanged;
  final String? semanticLabel;

  static const double _width = 46;
  static const double _height = 27;
  static const double _thumbSize = 20;
  static const double _inset = 2;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: semanticLabel,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: _width,
          height: _height,
          decoration: BoxDecoration(
            color: value ? ZaytonaColors.red : ZaytonaColors.ink100,
            borderRadius: BorderRadius.circular(ZaytonaRadius.pill),
            border: Border.all(
              color: ZaytonaColors.navy,
              width: ZaytonaShadows.strokeBold,
            ),
          ),
          child: Stack(
            children: [
              AnimatedPositionedDirectional(
                duration: const Duration(milliseconds: 150),
                top: 1.5,
                start: value ? _width - _thumbSize - _inset - 3 : _inset,
                child: Container(
                  width: _thumbSize,
                  height: _thumbSize,
                  decoration: const BoxDecoration(
                    color: ZaytonaColors.cream,
                    shape: BoxShape.circle,
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
