import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../l10n/app_localizations.dart';

/// Shows the camera/gallery source sheet, then launches the picker.
Future<String?> pickAddItemImagePath(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      padding: const EdgeInsets.all(ZaytonaSpacing.space5),
      decoration: const BoxDecoration(
        color: ZaytonaColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ZaytonaButton(
            label: l10n.cameraSourceLabel,
            variant: ZaytonaButtonVariant.outline,
            size: ZaytonaButtonSize.lg,
            block: true,
            iconLeft: const Icon(Icons.photo_camera_outlined, size: 20),
            onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
          ),
          const SizedBox(height: ZaytonaSpacing.space2),
          ZaytonaButton(
            label: l10n.gallerySourceLabel,
            variant: ZaytonaButtonVariant.outline,
            size: ZaytonaButtonSize.lg,
            block: true,
            iconLeft: const Icon(Icons.photo_library_outlined, size: 20),
            onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
  if (source == null || !context.mounted) return null;

  final picked = await ImagePicker().pickImage(
    source: source,
    maxWidth: 1600,
    imageQuality: 80,
  );
  return picked?.path;
}
