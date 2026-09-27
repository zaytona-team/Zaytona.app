import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/group_icon.dart';
import '../cubit/groups/create_group_cubit.dart';
import '../widgets/group_icon_picker.dart';

/// "Create Group" bottom sheet (mirrors CreateListSheet/JoinGroupSheet).
/// Show with: showModalBottomSheet(builder: (_) => const CreateGroupSheet())
class CreateGroupSheet extends StatelessWidget {
  /// Called with the new group on success. Defaults to
  /// `context.go('/groups/${group.groupId}')` — pass an override when this
  /// sheet is a step in a larger flow (e.g. onboarding).
  final void Function(Group group)? onSuccess;

  const CreateGroupSheet({super.key, this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CreateGroupCubit>(),
      child: _CreateGroupView(onSuccess: onSuccess),
    );
  }
}

class _CreateGroupView extends StatefulWidget {
  final void Function(Group group)? onSuccess;

  const _CreateGroupView({this.onSuccess});

  @override
  State<_CreateGroupView> createState() => _CreateGroupViewState();
}

class _CreateGroupViewState extends State<_CreateGroupView> {
  final _nameController = TextEditingController();

  GroupIcon _selectedIcon = GroupIcon.home;
  String? _nameError;
  String? _lastName;

  @override
  void initState() {
    super.initState();
    TokenStorage.readLastName().then((lastName) {
      if (mounted && lastName != null && lastName.trim().isNotEmpty) {
        setState(() => _lastName = lastName.trim());
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onCreatePressed(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = l10n.fieldRequired);
      return;
    }
    context.read<CreateGroupCubit>().submit(
          name: _nameController.text.trim(),
          icon: _selectedIcon.apiValue,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<CreateGroupCubit, CreateGroupState>(
      listener: (context, state) {
        if (state is CreateGroupSuccess) {
          if (widget.onSuccess != null) {
            widget.onSuccess!(state.group);
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
              title: l10n.newGroupTitle,
              onClose: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: ZaytonaSpacing.space4),
            Text(l10n.groupNameLabel, style: ZaytonaType.fieldLabel),
            const SizedBox(height: ZaytonaSpacing.space2),
            ZaytonaTextField(
              controller: _nameController,
              placeholder: _lastName == null
                  ? l10n.groupNameHint
                  : l10n.groupNameHintPersonalized(_lastName!),
              autofocus: true,
              error: _nameError,
              onChanged: (_) => setState(() => _nameError = null),
            ),
            const SizedBox(height: ZaytonaSpacing.space5),
            Text(l10n.groupIconLabel, style: ZaytonaType.fieldLabel),
            const SizedBox(height: ZaytonaSpacing.space3),
            GroupIconPicker(
              selected: _selectedIcon,
              onSelect: (icon) => setState(() => _selectedIcon = icon),
            ),
            BlocBuilder<CreateGroupCubit, CreateGroupState>(
              builder: (context, state) {
                if (state is! CreateGroupError) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: ZaytonaSpacing.space3),
                  child: Text(state.message, style: ZaytonaType.fieldError),
                );
              },
            ),
            const SizedBox(height: ZaytonaSpacing.space6),
            _createButton(l10n),
          ],
        ),
      ),
    );
  }

  Widget _createButton(AppLocalizations l10n) {
    return BlocBuilder<CreateGroupCubit, CreateGroupState>(
      builder: (context, state) {
        final isLoading = state is CreateGroupLoading;
        return ZaytonaButton(
          label: l10n.createGroupAction,
          variant: ZaytonaButtonVariant.primary,
          size: ZaytonaButtonSize.lg,
          block: true,
          iconLeft: const Icon(Icons.add, size: 20),
          disabled: isLoading,
          onTap: () => _onCreatePressed(context),
        );
      },
    );
  }
}
