import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/category_registry.dart';
import '../../domain/entities/list_item.dart';
import '../cubit/items/list_items_cubit.dart';
import '../cubit/trip/active_trip_cubit.dart';
import '../widgets/list_detail_actions.dart';
import '../widgets/list_detail_body.dart';
import '../widgets/list_detail_list_actions.dart';

/// List detail — Screen 5 (prototype: ListDetail, screens-main.jsx).
/// Category filter chips → aisle-grouped item rows → bottom bar with
/// "start trip" + "add item". Row tap opens the edit sheet; the qty
/// stepper edits inline (qty < 1 deletes, matching the prototype).
class ListDetailPage extends StatelessWidget {
  final String groupId;
  final String listId;
  final String listName;
  final ZaytonaListAccent listColor;

  /// A private/individual group is a single-member space — there's no one
  /// else to coordinate a shopping trip with, so Trip Alerts (US-30..32)
  /// has nothing to do there. Threaded down from the group view, which is
  /// the only place that already knows the group's type.
  final bool isPrivateGroup;

  const ListDetailPage({
    super.key,
    required this.groupId,
    required this.listId,
    this.listName = '',
    this.listColor = ZaytonaListAccent.indigo,
    this.isPrivateGroup = false,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // TODO: websocket — item add/edit/remove pushes from other members
        // should refresh this instead of the manual load()/pull-to-refresh.
        BlocProvider(create: (_) => sl<ListItemsCubit>()..load(listId)),
        BlocProvider(create: (_) => sl<ActiveTripCubit>()..load(listId)),
      ],
      child: _ListDetailView(
        groupId: groupId,
        listId: listId,
        listName: listName,
        listColor: listColor,
        isPrivateGroup: isPrivateGroup,
      ),
    );
  }
}

/// Stateful only for the local category-filter selection.
class _ListDetailView extends StatefulWidget {
  final String groupId;
  final String listId;
  final String listName;
  final ZaytonaListAccent listColor;
  final bool isPrivateGroup;

  const _ListDetailView({
    required this.groupId,
    required this.listId,
    required this.listName,
    required this.listColor,
    required this.isPrivateGroup,
  });

  @override
  State<_ListDetailView> createState() => _ListDetailViewState();
}

class _ListDetailViewState extends State<_ListDetailView> {
  /// null = "all" chip selected.
  CategoryId? _filter;
  late String _listName = widget.listName;
  late ZaytonaListAccent _listColor = widget.listColor;

  @override
  void initState() {
    super.initState();
    // Reaching this page doesn't require having visited the catalog first
    // (e.g. a fresh app launch straight into a list) — warm the registry
    // here too so aisle grouping/icons resolve real category_ids correctly.
    sl<CategoryRegistry>().ensureLoaded();
  }

  Future<bool> _renameList(
    BuildContext context,
    String newName,
    ZaytonaListAccent color,
  ) async {
    final result = await renameList(context, widget.listId, newName, color);
    if (result == null) return false;
    if (mounted) {
      setState(() {
        _listName = result.name;
        _listColor = ZaytonaListAccent.values.firstWhere(
          (a) => a.name == result.color,
          orElse: () => color,
        );
      });
    }
    return true;
  }

  Future<void> _deleteList(BuildContext context) async {
    final succeeded = await confirmDeleteList(
      context,
      groupId: widget.groupId,
      listId: widget.listId,
      listName: _listName,
    );
    if (!mounted) return;
    if (succeeded) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: ZaytonaColors.bgApp,
      body: SafeArea(
        child: BlocListener<ListItemsCubit, ListItemsState>(
          listenWhen: (previous, current) =>
              current is ListItemsLoaded && current.error != null,
          listener: (context, state) {
            final error = (state as ListItemsLoaded).error!;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error)));
          },
          child: BlocBuilder<ListItemsCubit, ListItemsState>(
            builder: (context, state) => switch (state) {
              ListItemsInitial() ||
              ListItemsLoading() => const Center(child: ZaytonaSpinningLogo()),
              ListItemsError(:final message) => ZaytonaListLoadError(
                message: message,
                retryLabel: l10n.retryAction,
                onRetry: () =>
                    context.read<ListItemsCubit>().load(widget.listId),
              ),
              ListItemsLoaded(:final items, :final pendingIds) => _body(
                context,
                l10n,
                items,
                pendingIds,
              ),
            },
          ),
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations l10n,
    List<ListItem> items,
    Set<String> pendingIds,
  ) {
    return ListDetailBody(
      groupId: widget.groupId,
      listId: widget.listId,
      listName: _listName,
      listColor: _listColor,
      isPrivateGroup: widget.isPrivateGroup,
      items: items,
      pendingIds: pendingIds,
      filter: _filter,
      onFilterChanged: (cat) => setState(() => _filter = cat),
      onBack: () => Navigator.of(context).pop(),
      onNotify: () => openNotificationsSheet(
        context,
        groupId: widget.groupId,
        listId: widget.listId,
      ),
      onDelete: () => _deleteList(context),
      onHistory: () => context.push(
        Uri(
          path: '${GoRouterState.of(context).uri.path}/history',
          queryParameters: {'name': _listName},
        ).toString(),
      ),
      onRenameList: (newName, color) => _renameList(context, newName, color),
      onEditItem: (item) => openEditSheet(context, widget.listId, item),
      onAddItem: () => openCatalog(context, widget.listId),
    );
  }
}
