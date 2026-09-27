import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

/// Prototype: LangPill — tap to switch to the other language.
class LangToggle extends StatelessWidget {
  const LangToggle({super.key, required this.isArabic, required this.onTap});

  final bool isArabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ZaytonaButton(
      label: isArabic ? 'English' : 'العربية',
      variant: ZaytonaButtonVariant.outline,
      size: ZaytonaButtonSize.sm,
      iconLeft: const Icon(Icons.language, size: 16),
      onTap: onTap,
    );
  }
}
