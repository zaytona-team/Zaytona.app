// item_tile.dart — ZaytonaItemTile
//
// One canonical item card, in two layouts (grid / list), replacing the
// separately hand-rolled rows that used to live in the catalog, list-detail,
// and buying-view screens — those had drifted out of visual sync with each
// other (buying view had no category art or brand; list view had no brand).
// Slot-based: image (tap-to-zoom), title, subtitle, tags, trailing, footer.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';
import 'image_viewer.dart';
import 'pressable.dart';

enum ZaytonaItemTileLayout { grid, list }

class ZaytonaItemTile extends StatelessWidget {
  const ZaytonaItemTile({
    super.key,
    required this.layout,
    required this.title,
    this.subtitle,
    this.footer,
    this.imageUrl,
    this.fallbackImage,
    this.urgent = false,
    this.strikethrough = false,
    this.dim = false,
    this.titlePrefix,
    this.trailing,
    this.onTap,
  });

  final ZaytonaItemTileLayout layout;
  final String title;

  /// Shown as a small caption line under the title (e.g. brand).
  final String? subtitle;

  /// Shown as a further caption line (e.g. notes).
  final String? footer;

  /// A real uploaded photo, if any.
  final String? imageUrl;

  /// Shown when [imageUrl] is null (e.g. the category icon asset).
  final ImageProvider? fallbackImage;

  final bool urgent;
  final bool strikethrough;

  /// Faded, e.g. a bought/completed item.
  final bool dim;

  /// A small leading glyph before the title (e.g. a "bought" checkmark).
  final Widget? titlePrefix;

  /// Caller-owned interaction slot: quick-add button (catalog grid), qty
  /// stepper (list view), checkbox (buying view) — the tile only
  /// standardizes layout, each screen keeps its own interaction.
  final Widget? trailing;

  final VoidCallback? onTap;

  ImageProvider? get _image =>
      imageUrl != null ? NetworkImage(imageUrl!) : fallbackImage;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dim ? 0.65 : 1,
      child: layout == ZaytonaItemTileLayout.grid
          ? _buildGrid(context)
          : _buildList(context),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return ZaytonaPressable(
      mode: ZaytonaPressMode.scale,
      scaleAmount: 0.97,
      onTap: onTap,
      builder: (context, pressed) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ZaytonaColors.surfaceCard,
          border: Border.all(color: ZaytonaColors.borderSoft, width: 1.5),
          borderRadius: BorderRadius.circular(ZaytonaRadius.md),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1.3,
                  child: LayoutBuilder(
                    builder: (context, constraints) => _ZoomableImage(
                      image: _image,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ZaytonaType.cardTitle.copyWith(fontSize: 14.5),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ZaytonaType.meta,
                  ),
              ],
            ),
            if (trailing != null)
              PositionedDirectional(end: 0, bottom: 0, child: trailing!),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: urgent ? ZaytonaColors.redTint : ZaytonaColors.surfaceCard,
          border: Border.all(
            color: urgent ? ZaytonaColors.red : ZaytonaColors.borderSoft,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(ZaytonaRadius.md),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _ZoomableImage(image: _image, width: 40, height: 40),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (titlePrefix != null) ...[
                        titlePrefix!,
                        const SizedBox(width: 5),
                      ],
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: ZaytonaType.fontBody,
                            fontWeight: ZaytonaType.fwBold,
                            fontSize: 15.5,
                            color: ZaytonaColors.textStrong,
                            decoration: strikethrough
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      if (urgent) ...[
                        const SizedBox(width: 7),
                        const Icon(Icons.local_fire_department,
                            size: 15, color: ZaytonaColors.red),
                      ],
                    ],
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ZaytonaType.meta,
                    ),
                  if (footer != null)
                    Text(
                      footer!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ZaytonaType.meta,
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class _ZoomableImage extends StatelessWidget {
  const _ZoomableImage({
    required this.image,
    required this.width,
    required this.height,
  });

  final ImageProvider? image;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final child = ClipRRect(
      borderRadius: BorderRadius.circular(ZaytonaRadius.sm),
      child: SizedBox(
        width: width,
        height: height,
        child: image == null
            ? const ColoredBox(
                color: ZaytonaColors.surfaceSunken,
                child: Center(
                  child: Icon(Icons.image_outlined, color: ZaytonaColors.ink300),
                ),
              )
            : Image(image: image!, fit: BoxFit.cover),
      ),
    );
    if (image == null) return child;
    return GestureDetector(
      onTap: () => ZaytonaImageViewer.show(context, image!),
      child: child,
    );
  }
}
