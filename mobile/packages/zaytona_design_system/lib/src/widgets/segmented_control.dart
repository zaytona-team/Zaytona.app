// segmented_control.dart — ZaytonaSegmentedControl
//
// Source spec: design_source/.../components/forms/SegmentedControl.jsx
//
// Controlled widget — the caller owns the selected value.
//
// Track: surface-sunken fill, 2px navy border, pill radius, 4px inner padding.
// Active segment: navy fill, cream text.
// Inactive segment: transparent fill, text-muted.
// Optional per-segment badge count: mint on active, ink-100 on inactive.
//
// Sizes: sm (h38, f14) / md (h44, f16).

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';

class ZaytonaSegmentOption {
  const ZaytonaSegmentOption({
    required this.value,
    required this.label,
    this.badge,
  });

  final String value;
  final String label;

  /// Optional count shown as a small pill inside the segment.
  final int? badge;
}

enum ZaytonaSegmentedSize { sm, md }

class ZaytonaSegmentedControl extends StatelessWidget {
  const ZaytonaSegmentedControl({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.size = ZaytonaSegmentedSize.md,
    this.fullWidth = false,
  });

  final List<ZaytonaSegmentOption> options;
  final String value;
  final void Function(String) onChanged;
  final ZaytonaSegmentedSize size;

  /// When true, segments split the available width equally instead of
  /// shrink-wrapping to their labels — use where the track must span its
  /// parent (e.g. a full-width tab switch).
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final segH = size == ZaytonaSegmentedSize.sm ? 38.0 : 44.0;
    final fontSize = size == ZaytonaSegmentedSize.sm
        ? ZaytonaType
              .fsBodySm // 14
        : ZaytonaType.fsBody; // 16

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ZaytonaColors.surfaceSunken,
        borderRadius: ZaytonaRadius.brPill,
        border: Border.all(color: ZaytonaColors.navy, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            children: options.map((opt) {
              final active = opt.value == value;
              final child = GestureDetector(
                onTap: () => onChanged(opt.value),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: segH,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: active ? ZaytonaColors.navy : Colors.transparent,
                    borderRadius: ZaytonaRadius.brPill,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        opt.label,
                        style: TextStyle(
                          fontFamily: ZaytonaType.fontDisplay,
                          fontFamilyFallback: const [ZaytonaType.fontBody],
                          fontWeight: ZaytonaType.fwBold,
                          fontSize: fontSize,
                          color: active
                              ? ZaytonaColors.cream
                              : ZaytonaColors.textMuted,
                        ),
                      ),
                      if (opt.badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          constraints: const BoxConstraints(minWidth: 18),
                          height: 18,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: active
                                ? ZaytonaColors.mint
                                : ZaytonaColors.ink100,
                            borderRadius: ZaytonaRadius.brPill,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${opt.badge}',
                            style: const TextStyle(
                              fontFamily: ZaytonaType.fontBody,
                              fontWeight: ZaytonaType.fwBold,
                              fontSize: ZaytonaType.fsMicro,
                              color: ZaytonaColors.navy,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
              return fullWidth
                  ? Expanded(child: child)
                  : Flexible(child: child);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
