import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/lists/create_list_cubit.dart';

/// "Create List" bottom sheet (prototype: CreateListSheet, screens-flows.jsx).
/// Show with: showModalBottomSheet(builder: (_) => CreateListSheet(groupId: ...))
/// Pops with `true` on success so the caller refreshes its lists.
class CreateListSheet extends StatelessWidget {
  final String groupId;

  const CreateListSheet({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CreateListCubit>(),
      child: _CreateListView(groupId: groupId),
    );
  }
}

/// Stateful only to own the name TextEditingController —
/// all submit/loading/error state lives in [CreateListCubit].
class _CreateListView extends StatefulWidget {
  final String groupId;

  const _CreateListView({required this.groupId});

  @override
  State<_CreateListView> createState() => _CreateListViewState();
}

class _CreateListViewState extends State<_CreateListView> {
  final _nameController = TextEditingController();
  // Not sent on submit: POST /lists has no documented `color` param yet
  // (only PATCH /lists/{listId} does) — logged in backend-needs.md.
  ZaytonaListAccent _color = ZaytonaListAccent.indigo;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onCreatePressed() {
    context.read<CreateListCubit>().submit(
          groupId: widget.groupId,
          name: _nameController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<CreateListCubit, CreateListState>(
      listener: (context, state) {
        if (state is CreateListSuccess) {
          Navigator.of(context).pop(true);
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
              title: l10n.newListTitle,
              onClose: () => Navigator.of(context).pop(),
            ),
            SizedBox(height: ZaytonaSpacing.space4),
            _fieldLabel(l10n.listNameLabel),
            SizedBox(height: ZaytonaSpacing.space2),
            ZaytonaTextField(
              controller: _nameController,
              placeholder: l10n.listNameHint,
              autofocus: true,
            ),
            SizedBox(height: ZaytonaSpacing.space4),
            _fieldLabel(l10n.listColorLabel),
            SizedBox(height: ZaytonaSpacing.space2),
            ZaytonaColorPicker(
              value: _color,
              onChanged: (accent) => setState(() => _color = accent),
            ),
            BlocBuilder<CreateListCubit, CreateListState>(
              builder: (context, state) {
                if (state is! CreateListError) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.only(top: ZaytonaSpacing.space3),
                  child: Text(state.message, style: ZaytonaType.fieldError),
                );
              },
            ),
            SizedBox(height: ZaytonaSpacing.space6),
            _createButton(l10n),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(text, style: ZaytonaType.fieldLabel);
  }

  Widget _createButton(AppLocalizations l10n) {
    // Rebuilds on typing (controller listener) and on cubit state changes:
    // disabled until the name has 2+ chars, spinner label while submitting.
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _nameController,
      builder: (context, value, _) {
        return BlocBuilder<CreateListCubit, CreateListState>(
          builder: (context, state) {
            final isLoading = state is CreateListLoading;
            return ZaytonaButton(
              label: l10n.createListAction,
              variant: ZaytonaButtonVariant.primary,
              size: ZaytonaButtonSize.lg,
              block: true,
              iconLeft: const Icon(Icons.add, size: 20),
              disabled: value.text.trim().length < 2 || isLoading,
              onTap: _onCreatePressed,
            );
          },
        );
      },
    );
  }
}
