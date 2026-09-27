import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import '../cubit/items/add_item_cubit.dart';

/// Photo thumbnail + attach/remove controls, driven by [AddItemCubit].
class AddItemPhotoField extends StatelessWidget {
  final String? existingImageUrl;
  final VoidCallback onPick;

  const AddItemPhotoField({
    super.key,
    required this.existingImageUrl,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<AddItemCubit, AddItemState>(
      buildWhen: (previous, current) =>
          previous.imagePath != current.imagePath,
      builder: (context, state) {
        final pickedPath = state.imagePath;
        final hasImage = pickedPath != null || existingImageUrl != null;

        if (!hasImage) {
          return ZaytonaButton(
            label: l10n.attachPhotoLabel,
            variant: ZaytonaButtonVariant.outline,
            size: ZaytonaButtonSize.md,
            block: true,
            iconLeft: const Icon(Icons.photo_camera_outlined),
            onTap: onPick,
          );
        }

        return Row(
          children: [
            GestureDetector(
              onTap: onPick,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(ZaytonaRadius.sm),
                child: Container(
                  width: 56,
                  height: 56,
                  color: ZaytonaColors.surfaceSunken,
                  child: pickedPath != null
                      ? Image.file(File(pickedPath), fit: BoxFit.cover)
                      : Image.network(existingImageUrl!, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(width: ZaytonaSpacing.space3),
            Expanded(
              child: ZaytonaButton(
                label: l10n.attachPhotoLabel,
                variant: ZaytonaButtonVariant.outline,
                size: ZaytonaButtonSize.sm,
                onTap: onPick,
              ),
            ),
            const SizedBox(width: ZaytonaSpacing.space2),
            ZaytonaIconButton(
              icon: const Icon(Icons.close, size: 16),
              tone: ZaytonaIconButtonTone.navy,
              variant: ZaytonaIconButtonVariant.soft,
              size: ZaytonaIconButtonSize.sm,
              semanticLabel: l10n.removePhotoLabel,
              onTap: () => context.read<AddItemCubit>().clearImage(),
            ),
          ],
        );
      },
    );
  }
}
