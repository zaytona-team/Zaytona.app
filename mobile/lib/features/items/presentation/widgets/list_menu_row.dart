import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

enum ListMenuRowTone { navy, red }

/// A single row inside [ListMenuCard] — icon + label, red tone + disabled
/// state for the destructive rows (delete-all-items, delete-list).
class ListMenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ListMenuRowTone tone;
  final bool disabled;

  const ListMenuRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.tone = ListMenuRowTone.navy,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final ink = tone == ListMenuRowTone.red ? ZaytonaColors.redPress : ZaytonaColors.navy;
    return InkWell(
      onTap: disabled ? null : onTap,
      child: Opacity(
        opacity: disabled ? 0.4 : 1,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: ZaytonaSpacing.space4,
            vertical: ZaytonaSpacing.space3,
          ),
          child: Row(
            children: [
              Icon(icon, size: ZaytonaSpacing.iconSm, color: ink),
              const SizedBox(width: ZaytonaSpacing.space3),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: ZaytonaType.fontDisplay,
                    fontFamilyFallback: const [ZaytonaType.fontBody],
                    fontWeight: ZaytonaType.fwBold,
                    fontSize: 14.5,
                    color: ink,
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
