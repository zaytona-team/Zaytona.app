// toggle_switch.dart — ZaytonaToggleSwitch
//
// Source spec: Zaytona-Design-System-2/components/forms/ToggleSwitch.jsx
//
// A compact binary pill switch — two fixed, equal halves (no per-label
// padding scaling like ZaytonaSegmentedControl), so long localized labels
// never blow out the track. Use for simple on/off or two-option settings
// (language, notifications) where ZaytonaSegmentedControl is too wide.
//
// Track: surface-sunken fill, 2px navy border, pill radius, 4px inner padding.
// Active half: navy fill, cream text. Inactive half: transparent, text-muted.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';

class ZaytonaToggleSwitch extends StatelessWidget {
  const ZaytonaToggleSwitch({
    super.key,
    required this.leftValue,
    required this.leftLabel,
    required this.rightValue,
    required this.rightLabel,
    required this.value,
    required this.onChanged,
  });

  final String leftValue;
  final String leftLabel;
  final String rightValue;
  final String rightLabel;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ZaytonaColors.surfaceSunken,
        borderRadius: ZaytonaRadius.brPill,
        border: Border.all(color: ZaytonaColors.navy, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        // Fixed left/right order in both languages — doesn't mirror in RTL.
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              Expanded(
                child: _Half(
                  label: leftLabel,
                  active: value == leftValue,
                  onTap: () => onChanged(leftValue),
                ),
              ),
              Expanded(
                child: _Half(
                  label: rightLabel,
                  active: value == rightValue,
                  onTap: () => onChanged(rightValue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Half extends StatelessWidget {
  const _Half({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? ZaytonaColors.navy : Colors.transparent,
          borderRadius: ZaytonaRadius.brPill,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: ZaytonaType.fontDisplay,
            fontFamilyFallback: const [ZaytonaType.fontBody],
            fontWeight: ZaytonaType.fwBold,
            fontSize: ZaytonaType.fsBodySm,
            color: active ? ZaytonaColors.cream : ZaytonaColors.textMuted,
          ),
        ),
      ),
    );
  }
}
