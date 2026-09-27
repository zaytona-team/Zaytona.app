import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../l10n/app_localizations.dart';

class GroupInviteCodeCard extends StatelessWidget {
  final String inviteCode;

  const GroupInviteCodeCard({super.key, required this.inviteCode});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ZaytonaSpacing.space4, vertical: ZaytonaSpacing.space4),
      decoration: BoxDecoration(
        color: ZaytonaColors.surfaceCard,
        border: Border.all(
          color: ZaytonaColors.borderSoft,
          width: 1.5,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(ZaytonaRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              inviteCode,
              style: ZaytonaType.cardTitle.copyWith(letterSpacing: 3),
            ),
          ),
          ZaytonaIconButton(
            icon: const Icon(Icons.copy_outlined, size: 18),
            tone: ZaytonaIconButtonTone.navy,
            variant: ZaytonaIconButtonVariant.soft,
            size: ZaytonaIconButtonSize.sm,
            semanticLabel: l10n.inviteCodeLabel,
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: inviteCode));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.inviteCodeCopied)),
              );
            },
          ),
        ],
      ),
    );
  }
}
