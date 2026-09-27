// gallery_section.dart — shared section header used by gallery_page.dart and
// gallery_sections_extra.dart.

import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

class GallerySection extends StatelessWidget {
  const GallerySection(this.title, {super.key, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontFamily: ZaytonaType.fontBody,
              fontWeight: ZaytonaType.fwBold,
              fontSize: 11,
              color: ZaytonaColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
