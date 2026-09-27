import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../l10n/app_localizations.dart';

/// Channel selector for OTP resend — the picked value is forwarded as
/// `POST /auth/otp/resend`'s optional `channel` param. Rendered as
/// clickable colored text rather than a toggle, per design feedback.
class OtpChannelPicker extends StatelessWidget {
  const OtpChannelPicker({
    super.key,
    required this.value,
    required this.onChanged,
    required this.hasEmail,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool hasEmail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: Text(l10n.otpResendVia, style: ZaytonaType.caption)),
        SizedBox(height: ZaytonaSpacing.space2),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: ZaytonaSpacing.space4,
            children: [
              _ChannelText(id: 'whatsapp', label: l10n.otpChannelWhatsapp, selected: value == 'whatsapp', onTap: onChanged),
              _ChannelText(id: 'sms', label: l10n.otpChannelSms, selected: value == 'sms', onTap: onChanged),
              if (hasEmail)
                _ChannelText(id: 'email', label: l10n.otpChannelEmail, selected: value == 'email', onTap: onChanged),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChannelText extends StatelessWidget {
  const _ChannelText({required this.id, required this.label, required this.selected, required this.onTap});

  final String id;
  final String label;
  final bool selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(id),
      child: Text(
        label,
        style: ZaytonaType.bodySm.copyWith(
          color: selected ? ZaytonaColors.red : ZaytonaColors.textMuted,
          fontWeight: selected ? ZaytonaType.fwBold : FontWeight.w500,
          decoration: selected ? TextDecoration.underline : null,
          decorationColor: ZaytonaColors.red,
        ),
      ),
    );
  }
}
