import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.isLoading,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: ZaytonaSpacing.controlHLg,
      decoration: BoxDecoration(
        color: ZaytonaColors.red,
        borderRadius: ZaytonaRadius.brPill,
        border: Border.all(color: ZaytonaColors.navy, width: ZaytonaShadows.strokeBold),
        boxShadow: ZaytonaShadows.shadowPop,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: ZaytonaRadius.brPill),
        ),
        child: isLoading
            ? SizedBox(
                height: ZaytonaSpacing.iconMd,
                width: ZaytonaSpacing.iconMd,
                child: CircularProgressIndicator(strokeWidth: 2, color: ZaytonaColors.textOnColor),
              )
            : Text(
                label,
                style: ZaytonaType.body.copyWith(
                  color: ZaytonaColors.textOnColor,
                  fontWeight: ZaytonaType.fwBold,
                ),
              ),
      ),
    );
  }
}