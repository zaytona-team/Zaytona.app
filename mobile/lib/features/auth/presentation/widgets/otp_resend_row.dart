import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../l10n/app_localizations.dart';

class OtpResendRow extends StatelessWidget {
  const OtpResendRow({
    super.key,
    required this.secondsLeft,
    required this.isResending,
    required this.onResend,
  });

  final int secondsLeft;
  final bool isResending;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (secondsLeft > 0) {
      return Center(
        child: Text(
          l10n.otpResendCountdown(secondsLeft),
          style: ZaytonaType.bodySm.copyWith(color: ZaytonaColors.textMuted),
        ),
      );
    }
    return Center(
      child: TextButton(
        onPressed: isResending ? null : onResend,
        child: Text(
          isResending ? l10n.otpResending : l10n.otpResendAction,
          style: ZaytonaType.bodySm.copyWith(color: ZaytonaColors.indigo, fontWeight: ZaytonaType.fwBold),
        ),
      ),
    );
  }
}