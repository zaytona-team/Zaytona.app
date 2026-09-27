import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

class GroupDangerCard extends StatelessWidget {
  final String title;
  final String body;
  final String buttonLabel;
  final IconData buttonIcon;
  final bool disabled;
  final VoidCallback onPressed;

  const GroupDangerCard({
    super.key,
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.disabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ZaytonaSpacing.space4),
      decoration: BoxDecoration(
        color: ZaytonaColors.redTint,
        border: Border.all(color: ZaytonaColors.red, width: 2),
        borderRadius: BorderRadius.circular(ZaytonaRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: ZaytonaType.cardTitle),
          const SizedBox(height: ZaytonaSpacing.space1),
          Text(body, style: ZaytonaType.caption),
          const SizedBox(height: ZaytonaSpacing.space3),
          ZaytonaButton(
            label: buttonLabel,
            variant: ZaytonaButtonVariant.danger,
            size: ZaytonaButtonSize.md,
            iconLeft: Icon(buttonIcon, size: 18),
            disabled: disabled,
            onTap: onPressed,
          ),
        ],
      ),
    );
  }
}
