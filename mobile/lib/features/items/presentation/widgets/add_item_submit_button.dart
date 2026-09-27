import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../cubit/items/add_item_cubit.dart';

/// Submit button + inline error, reacting to [AddItemCubit]'s state.
class AddItemSubmitButton extends StatelessWidget {
  final bool editing;
  final bool uploadingImage;
  final String label;
  final VoidCallback onTap;

  const AddItemSubmitButton({
    super.key,
    required this.editing,
    required this.uploadingImage,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddItemCubit, AddItemState>(
      builder: (context, state) {
        final isLoading = state is AddItemLoading || uploadingImage;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state is AddItemError)
              Padding(
                padding: const EdgeInsets.only(bottom: ZaytonaSpacing.space2),
                child: Text(state.message, style: ZaytonaType.fieldError),
              ),
            ZaytonaButton(
              label: label,
              variant: ZaytonaButtonVariant.primary,
              size: ZaytonaButtonSize.lg,
              block: true,
              iconLeft: Icon(editing ? Icons.check : Icons.add, size: 20),
              disabled: isLoading,
              onTap: onTap,
            ),
          ],
        );
      },
    );
  }
}
