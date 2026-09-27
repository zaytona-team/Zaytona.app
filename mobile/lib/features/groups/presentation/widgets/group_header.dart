import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

/// GroupView's top bar: menu (opens drawer), logo, settings + add-list.
class GroupViewHeader extends StatelessWidget {
  final String groupId;

  const GroupViewHeader({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Center(
            child: Image(
              image: AssetImage('assets/images/logo.png'),
              height: 36,
            ),
          ),
          // Forced LTR: settings physically left, menu physically right,
          // in both languages (matches the drawer's pinned side).
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ZaytonaIconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tone: ZaytonaIconButtonTone.navy,
                  variant: ZaytonaIconButtonVariant.soft,
                  semanticLabel: 'Settings',
                  onTap: () => context.push('/groups/$groupId/settings'),
                ),
                ZaytonaIconButton(
                  icon: const Icon(Icons.menu),
                  tone: ZaytonaIconButtonTone.navy,
                  variant: ZaytonaIconButtonVariant.soft,
                  semanticLabel: 'Menu',
                  onTap: () => Scaffold.of(context).openEndDrawer(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
