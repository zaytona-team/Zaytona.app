import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/groups/join_group_cubit.dart';

/// "Join Group" bottom sheet (mirrors CreateListSheet's structure/pattern).
/// Show with: showModalBottomSheet(builder: (_) => const JoinGroupSheet())
/// On success, navigates straight into the joined group — mirrors
/// CreateGroupSheet's `context.go('/groups/${group.groupId}')`.
class JoinGroupSheet extends StatelessWidget {
  /// Called with the joined group's id on success. Defaults to
  /// `context.go('/groups/$id')` — pass an override when this sheet is a
  /// step in a larger flow (e.g. onboarding).
  final void Function(String groupId)? onSuccess;

  const JoinGroupSheet({super.key, this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<JoinGroupCubit>(),
      child: _JoinGroupView(onSuccess: onSuccess),
    );
  }
}

/// Stateful only to own the invite-code TextEditingController —
/// all submit/loading/error state lives in [JoinGroupCubit].
class _JoinGroupView extends StatefulWidget {
  final void Function(String groupId)? onSuccess;

  const _JoinGroupView({this.onSuccess});

  @override
  State<_JoinGroupView> createState() => _JoinGroupViewState();
}

class _JoinGroupViewState extends State<_JoinGroupView> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onJoinPressed(BuildContext context) {
    final code = _codeController.text.trim();
    // UX-only check: skip the round trip for an empty field. The backend
    // stays the source of truth for whether the code is valid/unexpired.
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.inviteCodeRequired)),
      );
      return;
    }
    context.read<JoinGroupCubit>().submit(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<JoinGroupCubit, JoinGroupState>(
      listener: (context, state) {
        if (state is JoinGroupSuccess) {
          if (widget.onSuccess != null) {
            widget.onSuccess!(state.group.groupId);
          } else {
            context.go('/groups/${state.group.groupId}');
          }
        }
      },
      child: Container(
        padding: EdgeInsets.only(
          left: ZaytonaSpacing.space5,
          right: ZaytonaSpacing.space5,
          top: ZaytonaSpacing.space3,
          // push content up when the keyboard opens
          bottom: MediaQuery.of(context).viewInsets.bottom + ZaytonaSpacing.space6,
        ),
        decoration: const BoxDecoration(
          color: ZaytonaColors.surfaceCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ZaytonaSheetHeader(
              title: l10n.joinGroupTitle,
              onClose: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: ZaytonaSpacing.space4),
            _fieldLabel(l10n.inviteCodeLabel),
            const SizedBox(height: ZaytonaSpacing.space2),
            _codeField(l10n),
            const SizedBox(height: ZaytonaSpacing.space6),
            _joinButton(l10n),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(text, style: ZaytonaType.fieldLabel);
  }

  Widget _codeField(AppLocalizations l10n) {
    return BlocBuilder<JoinGroupCubit, JoinGroupState>(
      builder: (context, state) {
        return ZaytonaTextField(
          controller: _codeController,
          placeholder: l10n.inviteCodeHint,
          error: state is JoinGroupError ? state.message : null,
        );
      },
    );
  }

  Widget _joinButton(AppLocalizations l10n) {
    return BlocBuilder<JoinGroupCubit, JoinGroupState>(
      builder: (context, state) {
        final isLoading = state is JoinGroupLoading;
        return ZaytonaButton(
          label: l10n.joinAction,
          variant: ZaytonaButtonVariant.primary,
          size: ZaytonaButtonSize.lg,
          block: true,
          iconLeft: const Icon(Icons.person_add_alt, size: 20),
          disabled: isLoading,
          onTap: () => _onJoinPressed(context),
        );
      },
    );
  }
}
