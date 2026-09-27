// drawer.dart — ZaytonaDrawer + row parts
//
// Source spec: Zaytona-Design-System-2/components/patterns/Sidebar.jsx —
// slide-in navigation drawer: scrim + panel sliding from the inline-start
// edge (right in RTL), fixed header/footer, scrolling nav body.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';

class ZaytonaDrawer extends StatelessWidget {
  const ZaytonaDrawer({
    super.key,
    this.header,
    required this.children,
    this.footer,
    this.width = 296,
  });

  final Widget? header;
  final List<Widget> children;
  final Widget? footer;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        width: width,
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.86),
        height: double.infinity,
        decoration: const BoxDecoration(
          color: ZaytonaColors.surfaceCard,
          boxShadow: ZaytonaShadows.shadowMd,
        ),
        child: Column(
          children: [
            ?header,
            Expanded(
              child: ListView(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 6, 10, 20),
                children: children,
              ),
            ),
            if (footer != null)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 6, 10, 16),
                child: footer!,
              ),
          ],
        ),
      ),
    );
  }
}

enum ZaytonaDrawerLinkTone { navy, red, indigo, mint }

class ZaytonaDrawerLink extends StatelessWidget {
  const ZaytonaDrawerLink({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.tone = ZaytonaDrawerLinkTone.navy,
  });

  final Widget icon;
  final String label;
  final VoidCallback onTap;
  final ZaytonaDrawerLinkTone tone;

  Color get _iconColor => switch (tone) {
        ZaytonaDrawerLinkTone.navy => ZaytonaColors.navy,
        ZaytonaDrawerLinkTone.red => ZaytonaColors.red,
        ZaytonaDrawerLinkTone.indigo => ZaytonaColors.indigo,
        ZaytonaDrawerLinkTone.mint => ZaytonaColors.mint,
      };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: ZaytonaRadius.brMd,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ZaytonaColors.surfaceSunken,
                borderRadius: ZaytonaRadius.brPill,
              ),
              child: IconTheme(
                data: IconThemeData(color: _iconColor, size: 20),
                child: icon,
              ),
            ),
            const SizedBox(width: 13),
            Text(
              label,
              style: const TextStyle(
                fontFamily: ZaytonaType.fontDisplay,
                fontFamilyFallback: [ZaytonaType.fontBody],
                fontWeight: ZaytonaType.fwBold,
                fontSize: 15.5,
                color: ZaytonaColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
