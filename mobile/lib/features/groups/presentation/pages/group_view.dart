import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router.dart';
import '../../../lists/presentation/cubit/lists/group_lists_cubit.dart';
import '../../../lists/presentation/pages/create_list_sheet.dart';
import '../cubit/groups/get_group_cubit.dart';
import '../widgets/app_drawer.dart';
import '../widgets/group_card.dart';
import '../widgets/group_header.dart';
import '../widgets/group_lists_section.dart';

// "Group View" — detail screen for a single group (Screen 4 mockup).
class GroupView extends StatelessWidget {
  final String groupId;

  const GroupView({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<GetGroupCubit>()..load(groupId)),
        BlocProvider(create: (_) => sl<GroupListsCubit>()..load(groupId)),
      ],
      child: _GroupDetailView(groupId: groupId),
    );
  }
}

class _GroupDetailView extends StatefulWidget {
  final String groupId;

  const _GroupDetailView({required this.groupId});

  @override
  State<_GroupDetailView> createState() => _GroupDetailViewState();
}

class _GroupDetailViewState extends State<_GroupDetailView> with RouteAware {
  String get groupId => widget.groupId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) routeObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Fires when a route pushed on top of this one (e.g. list detail, Buying
  // View) is popped OR go_router replaces the stack back down to this
  // route (e.g. Buying View's "trip complete" uses context.go, which
  // bypasses a plain pop) — either way, list summaries may be stale.
  @override
  void didPopNext() {
    _refresh();
  }

  void _refresh() {
    if (!mounted) return;
    context.read<GetGroupCubit>().load(groupId);
    context.read<GroupListsCubit>().load(groupId);
  }

  Future<void> _openCreateListSheet(BuildContext context) async {
    final cubit = context.read<GroupListsCubit>();
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateListSheet(groupId: groupId),
    );
    if (created == true) {
      cubit.load(groupId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    // Forced LTR so endDrawer always opens from the physical right; body
    // content below restores the real locale direction.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: ZaytonaColors.bgApp,
        endDrawer: AppDrawer(currentGroupId: groupId),
        floatingActionButton: ZaytonaFab(
          icon: const Icon(Icons.add),
          onTap: () => _openCreateListSheet(context),
          tone: ZaytonaFabTone.red,
        ),
        floatingActionButtonLocation: _BottomRightFabLocation(
          safeAreaBottom: MediaQuery.paddingOf(context).bottom,
        ),
        body: Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: SafeArea(
            child: BlocBuilder<GetGroupCubit, GetGroupState>(
              builder: (context, state) => switch (state) {
                GetGroupInitial() ||
                GetGroupLoading() => const Center(child: ZaytonaSpinningLogo()),
                GetGroupError(:final message) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message,
                        style: const TextStyle(color: ZaytonaColors.navy),
                      ),
                      const SizedBox(height: ZaytonaSpacing.space3),
                      TextButton(
                        onPressed: () =>
                            context.read<GetGroupCubit>().load(groupId),
                        child: Text(l10n.retryAction),
                      ),
                    ],
                  ),
                ),
                GetGroupLoaded(:final group, :final members) =>
                  ZaytonaRefreshIndicator(
                    onRefresh: () => Future.wait([
                      context.read<GetGroupCubit>().load(groupId),
                      context.read<GroupListsCubit>().load(groupId),
                    ]),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: ZaytonaSpacing.space6),
                      children: [
                        const SizedBox(height: ZaytonaSpacing.space6),
                        GroupViewHeader(groupId: groupId),
                        const SizedBox(height: ZaytonaSpacing.space6),
                        GroupCard(group: group, members: members),
                        const SizedBox(height: ZaytonaSpacing.space4),
                        BlocBuilder<GroupListsCubit, GroupListsState>(
                          builder: (context, listsState) {
                            final listCount = switch (listsState) {
                              GroupListsLoaded(:final lists) => lists.length,
                              _ => 0,
                            };
                            return Row(
                              children: [
                                Text(
                                  l10n.listsTab,
                                  style: ZaytonaType.overline,
                                ),
                                const SizedBox(width: ZaytonaSpacing.space2),
                                ZaytonaBadge(
                                  label: '$listCount',
                                  tone: ZaytonaBadgeTone.indigo,
                                  variant: ZaytonaBadgeVariant.solid,
                                  size: ZaytonaBadgeSize.sm,
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: ZaytonaSpacing.space6),
                        GroupListsSection(
                          groupId: groupId,
                          isPrivate: group.isPrivate,
                          onAddList: () => _openCreateListSheet(context),
                        ),
                        const SizedBox(height: ZaytonaSpacing.space6),
                      ],
                    ),
                  ),
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Always bottom-right in the Scaffold's own coordinate space, ignoring
/// ambient text direction — the create-list FAB is physically pinned in
/// both languages (matching the header's fixed menu/settings buttons).
class _BottomRightFabLocation extends FloatingActionButtonLocation {
  const _BottomRightFabLocation({required this.safeAreaBottom});

  final double safeAreaBottom;

  static const double _margin = 16;

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final dx =
        scaffoldGeometry.scaffoldSize.width -
        scaffoldGeometry.floatingActionButtonSize.width -
        _margin;
    final dy =
        scaffoldGeometry.scaffoldSize.height -
        scaffoldGeometry.floatingActionButtonSize.height -
        _margin -
        safeAreaBottom;
    return Offset(dx, dy);
  }
}
