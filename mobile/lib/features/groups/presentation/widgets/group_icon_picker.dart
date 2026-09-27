import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../domain/entities/group_icon.dart';

/// Icon grid for CreateGroupSheet — stateless, selection lives with the caller.
class GroupIconPicker extends StatelessWidget {
  const GroupIconPicker({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final GroupIcon selected;
  final ValueChanged<GroupIcon> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: GroupIcon.values.map(_tile).toList(),
    );
  }

  Widget _tile(GroupIcon type) {
    final isSelected = type == selected;
    return GestureDetector(
      onTap: () => onSelect(type),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: ZaytonaColors.surfaceSunken,
          borderRadius: BorderRadius.circular(ZaytonaRadius.md),
          border: isSelected
              ? Border.all(
                  color: ZaytonaColors.borderBold,
                  width: ZaytonaShadows.strokeBold,
                )
              : null,
        ),
        child: Icon(type.iconData, color: ZaytonaColors.textStrong, size: 22),
      ),
    );
  }
}
