import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';


/// Avatar picker row for [EditAccountSheet] — tap a preset avatar to select
/// it; the selected avatar gets a red ring.
class EditAccountAvatarPicker extends StatelessWidget {
  const EditAccountAvatarPicker({
    super.key,
    required this.loading,
    required this.avatars,
    required this.selectedId,
    required this.label,
    required this.urlOf,
    required this.onSelect,
  });

  final bool loading;
  final List<Map<String, dynamic>> avatars;
  final dynamic selectedId;
  final String label;
  final String? Function(Map<String, dynamic>?) urlOf;
  final void Function(Map<String, dynamic>) onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: ZaytonaSpacing.space3, vertical: ZaytonaSpacing.space4),
      decoration: BoxDecoration(
        color: ZaytonaColors.surfaceSunken,
        borderRadius: ZaytonaRadius.brLg,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: ZaytonaType.fieldLabel.copyWith(color: ZaytonaColors.textMuted),
          ),
          const SizedBox(height: ZaytonaSpacing.space3),
          if (loading)
            const ZaytonaSpinningLogo()
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: avatars.map((avatar) {
                final selected = selectedId == avatar['id'];
                return GestureDetector(
                  onTap: () => onSelect(avatar),
                  child: ZaytonaAvatar(
                    src: urlOf(avatar),
                    size: selected ? 56 : 52,
                    ringColor: selected ? ZaytonaColors.red : ZaytonaColors.ink100,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
