// color_picker.dart — ZaytonaColorPicker
//
// Presentational grid of ZaytonaListAccent swatches. Knows nothing about
// creating or updating a list — takes a current value, emits a change.
// Callers (create-list, edit-list, ...) own their own cubit/state around it.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';
import 'list_summary_card.dart';

class ZaytonaColorPicker extends StatelessWidget {
  const ZaytonaColorPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ZaytonaListAccent value;
  final ValueChanged<ZaytonaListAccent> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final accent in ZaytonaListAccent.values) ...[
          _ColorSwatch(
            accent: accent,
            selected: value == accent,
            onTap: () => onChanged(accent),
          ),
          const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final ZaytonaListAccent accent;
  final bool selected;
  final VoidCallback onTap;

  Color get _color => switch (accent) {
        ZaytonaListAccent.red => ZaytonaColors.red,
        ZaytonaListAccent.indigo => ZaytonaColors.indigo,
        ZaytonaListAccent.mint => ZaytonaColors.mint,
        ZaytonaListAccent.navy => ZaytonaColors.navy,
        ZaytonaListAccent.lilac => ZaytonaColors.lilac,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _color,
          shape: BoxShape.circle,
          border: Border.all(
            color: ZaytonaColors.navy,
            width: selected ? 2.5 : 0,
          ),
        ),
      ),
    );
  }
}
