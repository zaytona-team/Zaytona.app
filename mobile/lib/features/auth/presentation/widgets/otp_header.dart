import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../l10n/app_localizations.dart';

/// The "edit number" link shown under the OTP page's title/subtitle, which
/// [AuthPageTemplate] renders via [titleTrailing].
class OtpEditNumberLink extends StatelessWidget {
  const OtpEditNumberLink({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: TextButton(
        onPressed: () => context.pop(),
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        child: Text(l10n.editPhoneNumberAction, style: ZaytonaType.caption.copyWith(color: ZaytonaColors.indigo)),
      ),
    );
  }
}
