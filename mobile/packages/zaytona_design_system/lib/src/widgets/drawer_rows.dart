// drawer_rows.dart — ZaytonaDrawerGroupItem / ZaytonaDrawerSection /
// ZaytonaDrawerDivider. Split out of drawer.dart to stay under the 180-line
// file cap. Source spec: Zaytona-Design-System-2/components/patterns/
// Sidebar.jsx (SidebarGroupItem, SidebarSection, SidebarDivider).

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';

class ZaytonaDrawerGroupItem extends StatelessWidget {
  const ZaytonaDrawerGroupItem({
    super.key,
    required this.leading,
    required this.name,
    this.meta,
    this.active = false,
    required this.onTap,
  });

  final Widget leading;
  final String name;
  final String? meta;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: ZaytonaRadius.brMd,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: active ? ZaytonaColors.surfaceSunken : Colors.transparent,
          borderRadius: ZaytonaRadius.brMd,
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: ZaytonaType.fontDisplay,
                      fontFamilyFallback: [ZaytonaType.fontBody],
                      fontWeight: ZaytonaType.fwBold,
                      fontSize: 15.5,
                      color: ZaytonaColors.navy,
                    ),
                  ),
                  if (meta != null)
                    Text(
                      meta!,
                      style: const TextStyle(
                        fontFamily: ZaytonaType.fontBody,
                        fontSize: 11.5,
                        color: ZaytonaColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
            if (active) const Icon(Icons.check, size: 20, color: ZaytonaColors.red),
          ],
        ),
      ),
    );
  }
}

class ZaytonaDrawerSection extends StatelessWidget {
  const ZaytonaDrawerSection({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 14, 4),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: ZaytonaType.fontBody,
          fontWeight: ZaytonaType.fwBlack,
          fontSize: 10.5,
          letterSpacing: 10.5 * 0.06,
          color: ZaytonaColors.textHint,
        ),
      ),
    );
  }
}

class ZaytonaDrawerDivider extends StatelessWidget {
  const ZaytonaDrawerDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.5,
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 8),
      color: ZaytonaColors.borderSoft,
    );
  }
}
