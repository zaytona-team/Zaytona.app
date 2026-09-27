import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/group_icon.dart';
import '../cubit/groups/list_groups_cubit.dart';
import '../pages/create_group_sheet.dart';
import '../pages/join_group_sheet.dart';
import 'group_tone.dart';
import 'list_groups_provider.dart';

/// App navigation drawer (prototype: DrawerNav, app.jsx 370-426).
/// Entries top→bottom: logo + close, join a group, create a
/// group, "my groups" list (check on the active group), settings & account.
/// Wire via `Scaffold.endDrawer:`; [GroupView]'s Scaffold forces LTR so
/// the slide side stays physically right in both languages.
class AppDrawer extends StatelessWidget {
  /// The group currently open, to mark it in the list.
  final String currentGroupId;

  const AppDrawer({super.key, required this.currentGroupId});

  @override
  Widget build(BuildContext context) {
    // Ambient direction is forced LTR by GroupView's Scaffold; restore RTL
    // here for Arabic content since only the slide side must stay pinned.
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: ListGroupsProvider(
        child: _DrawerView(currentGroupId: currentGroupId),
      ),
    );
  }
}

class _DrawerView extends StatelessWidget {
  final String currentGroupId;

  const _DrawerView({required this.currentGroupId});

  void _goTo(BuildContext context, String location) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.push(location);
  }

  void _openJoinGroupSheet(BuildContext context) {
    Navigator.of(context).pop(); // close the drawer
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const JoinGroupSheet(),
    );
  }

  void _openCreateGroupSheet(BuildContext context) {
    Navigator.of(context).pop(); // close the drawer
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateGroupSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Drawer(
      width: 296,
      backgroundColor: ZaytonaColors.bgApp,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(ZaytonaSpacing.space5, ZaytonaSpacing.space4, ZaytonaSpacing.space3, ZaytonaSpacing.space2),
              // Logo/close stay physically fixed, don't mirror in LTR.
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/zaytona.png',
                      width: 40,
                      height: 40,
                    ),
                    ZaytonaIconButton(
                      icon: const Icon(Icons.close, size: 18),
                      tone: ZaytonaIconButtonTone.navy,
                      variant: ZaytonaIconButtonVariant.soft,
                      size: ZaytonaIconButtonSize.sm,
                      semanticLabel: 'Close',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: ZaytonaColors.borderHair),
            _DrawerEntry(
              icon: Icons.person_add_alt,
              label: l10n.drawerJoinGroup,
              tone: ZaytonaColors.indigo,
              onTap: () => _openJoinGroupSheet(context),
            ),
            _DrawerEntry(
              icon: Icons.add,
              label: l10n.drawerCreateGroup,
              tone: ZaytonaColors.red,
              onTap: () => _openCreateGroupSheet(context),
            ),
            const Divider(height: 1, color: ZaytonaColors.borderHair),
            const SizedBox(height: ZaytonaSpacing.space3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ZaytonaSpacing.space5, vertical: ZaytonaSpacing.space2),
              child: Text(l10n.drawerMyGroups, style: ZaytonaType.overline),
            ),
            Expanded(child: _GroupsList(currentGroupId: currentGroupId)),
            const Divider(height: 1, color: ZaytonaColors.borderHair),
            _DrawerEntry(
              icon: Icons.settings_outlined,
              label: l10n.drawerSettings,
              tone: ZaytonaColors.navy,
              onTap: () => _goTo(context, '/settings'),
            ),
            const SizedBox(height: ZaytonaSpacing.space2),
          ],
        ),
      ),
    );
  }
}

/// Scrollable "groups I'm in" section, driven by [ListGroupsCubit].
class _GroupsList extends StatelessWidget {
  final String currentGroupId;

  const _GroupsList({required this.currentGroupId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ListGroupsCubit, ListGroupsState>(
      builder: (context, state) => switch (state) {
        ListGroupsInitial() || ListGroupsLoading() => const Center(
          child: Padding(
            padding: EdgeInsets.all(ZaytonaSpacing.space5),
            child: ZaytonaSpinningLogo(),
          ),
        ),
        ListGroupsError(:final message) => Padding(
          padding: const EdgeInsets.all(ZaytonaSpacing.space5),
          child: Text(message, style: ZaytonaType.caption),
        ),
        ListGroupsLoaded(:final groups) ||
        ListGroupsRefreshing(:final groups) => ZaytonaRefreshIndicator(
          onRefresh: () => context.read<ListGroupsCubit>().refresh(),
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // Private/default group pinned first — every user has one.
              for (final group in [
                ...groups.where((g) => g.isPrivate),
                ...groups.where((g) => !g.isPrivate),
              ])
                ListTile(
                  leading: ZaytonaStar(
                    size: 40,
                    tone: group.tone,
                    rotate: -6,
                    child: Icon(
                      group.isPrivate
                          ? Icons.lock_outline
                          : GroupIconX.fromApiValue(group.icon).iconData,
                      size: 19,
                    ),
                  ),
                  title: Text(group.name, style: ZaytonaType.bodySm),
                  subtitle: Text(
                    l10n.memberCount(group.memberCount ?? 1),
                    style: ZaytonaType.meta,
                  ),
                  trailing: group.groupId == currentGroupId
                      ? const Icon(
                          Icons.check,
                          size: 18,
                          color: ZaytonaColors.successInk,
                        )
                      : null,
                  onTap: () {
                    final router = GoRouter.of(context);
                    Navigator.of(context).pop();
                    if (group.groupId != currentGroupId) {
                      router.go('/groups/${group.groupId}');
                    }
                  },
                ),
            ],
          ),
        ),
      },
    );
  }
}

/// One action row in the drawer (icon blob + label), per the prototype.
class _DrawerEntry extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color tone;
  final VoidCallback onTap;

  const _DrawerEntry({
    required this.icon,
    required this.label,
    required this.tone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: tone),
      title: Text(label, style: ZaytonaType.bodySm),
      onTap: onTap,
    );
  }
}
