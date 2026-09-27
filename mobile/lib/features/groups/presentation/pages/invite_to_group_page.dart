import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/invited_person.dart';
import '../widgets/joined_members_list.dart';

/// Invite to Group — shows the group's invite code with copy/share actions
/// (prototype: InviteReveal, screens-flows.jsx). Pure presentation: the
/// caller passes inviteCode and optionally the members who already joined.
class InviteToGroupPage extends StatelessWidget {
  final String inviteCode;
  final List<InvitedPerson> joinedMembers;

  /// Called on "Done"/back. Defaults to popping the route — pass an
  /// override when this page is a step in a larger flow (e.g. onboarding).
  final VoidCallback? onDone;
  final VoidCallback? onBack;

  const InviteToGroupPage({
    super.key,
    required this.inviteCode,
    this.joinedMembers = const [],
    this.onDone,
    this.onBack,
  });

  String get inviteLink => 'https://zaytouna.app/join/$inviteCode';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: ZaytonaColors.bgApp,
      body: SafeArea(
        child: Column(
          children: [
            _header(context, l10n),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: ZaytonaSpacing.space5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: ZaytonaSpacing.space5),
                    ZaytonaStar(
                      size: 84,
                      tone: ZaytonaStarTone.indigo,
                      rotate: -6,
                      child: const Icon(Icons.group_add_outlined, size: 38),
                    ),
                    const SizedBox(height: ZaytonaSpacing.space4),
                    Text(
                      l10n.inviteMembersTitle,
                      textAlign: TextAlign.center,
                      style: ZaytonaType.displaySm,
                    ),
                    const SizedBox(height: ZaytonaSpacing.space2),
                    Text(
                      l10n.inviteCodeLabel,
                      textAlign: TextAlign.center,
                      style: ZaytonaType.caption,
                    ),
                    const SizedBox(height: ZaytonaSpacing.space5),
                    _codeCard(),
                    const SizedBox(height: ZaytonaSpacing.space3),
                    Row(
                      children: [
                        Expanded(
                          child: ZaytonaButton(
                            label: l10n.copyAction,
                            variant: ZaytonaButtonVariant.outline,
                            size: ZaytonaButtonSize.md,
                            iconLeft: const Icon(Icons.copy, size: 18),
                            onTap: () => _onCopyCodePressed(context),
                          ),
                        ),
                        const SizedBox(width: ZaytonaSpacing.space3),
                        Expanded(
                          child: ZaytonaButton(
                            label: l10n.shareInviteLink,
                            variant: ZaytonaButtonVariant.primary,
                            size: ZaytonaButtonSize.md,
                            iconLeft: const Icon(Icons.ios_share, size: 18),
                            onTap: () => _onShareLinkPressed(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: ZaytonaSpacing.space7),
                    JoinedMembersList(
                      members: joinedMembers,
                      onShareLink: () => _onShareLinkPressed(context),
                    ),
                  ],
                ),
              ),
            ),
            _doneButton(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ZaytonaSpacing.space2, vertical: ZaytonaSpacing.space2),
      child: Row(
        children: [
          ZaytonaIconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            tone: ZaytonaIconButtonTone.navy,
            variant: ZaytonaIconButtonVariant.soft,
            size: ZaytonaIconButtonSize.md,
            semanticLabel: l10n.backAction,
            onTap: onBack ?? () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _codeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: ZaytonaSpacing.space5),
      decoration: BoxDecoration(
        color: ZaytonaColors.surfaceSunken,
        borderRadius: BorderRadius.circular(ZaytonaRadius.md),
        border: Border.all(
          color: ZaytonaColors.navy,
          width: ZaytonaShadows.strokeBold,
          style: BorderStyle.solid,
        ),
      ),
      alignment: Alignment.center,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          inviteCode,
          style: ZaytonaType.displaySm.copyWith(letterSpacing: 3),
        ),
      ),
    );
  }

  Widget _doneButton(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(ZaytonaSpacing.space5, ZaytonaSpacing.space3, ZaytonaSpacing.space5, ZaytonaSpacing.space5),
      child: ZaytonaButton(
        label: l10n.doneAction,
        variant: ZaytonaButtonVariant.primary,
        size: ZaytonaButtonSize.lg,
        block: true,
        onTap: onDone ?? () => Navigator.of(context).pop(),
      ),
    );
  }

  Future<void> _onCopyCodePressed(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: inviteCode));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.inviteCodeCopied)),
    );
  }

  // Native share sheet needs the share_plus package (see
  // Documentation/team-setup-todo.md); until it's added, copying the
  // link keeps the flow usable.
  Future<void> _onShareLinkPressed(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: inviteLink));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.inviteLinkCopied)),
    );
  }
}
