import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/category_registry.dart';
import '../cubit/items/list_items_cubit.dart';
import '../cubit/trip/active_trip_cubit.dart';
import '../cubit/trip/complete_trip_cubit.dart';
import '../widgets/buying_view_body.dart';
import '../widgets/trip_precondition_error.dart';

/// Buying View — Screen 7 (prototype: BuyingView, screens-flows.jsx).
/// Fully locked per the business rules: no add FAB, no item editing —
/// check/uncheck is the only mutation. Done is the only way out; the confirm
/// dialog it opens doubles as the trip summary (see finish_trip_dialog.dart).
class BuyingViewPage extends StatelessWidget {
  final String listId;
  final String listName;
  final String groupId;

  const BuyingViewPage({
    super.key,
    required this.groupId,
    required this.listId,
    this.listName = '',
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // TODO: websocket — item add/edit/remove pushes should refresh this
        // instead of the manual load()/pull-to-refresh below. The list is
        // locked during buying so this shouldn't fire from other members,
        // but keeping it live saves a stale screen if it ever does.
        BlocProvider(create: (_) => sl<ListItemsCubit>()..load(listId)),
        BlocProvider(create: (_) => sl<CompleteTripCubit>()),
        // Reaching this screen means Start Trip already locked a buyer —
        // this just resolves the trip_id the Done button needs.
        BlocProvider(create: (_) => sl<ActiveTripCubit>()..load(listId)),
      ],
      child: _BuyingView(groupId: groupId, listId: listId, listName: listName),
    );
  }
}

/// Stateful only for the local all/urgent filter selection.
class _BuyingView extends StatefulWidget {
  final String listId;
  final String listName;
  final String groupId;

  const _BuyingView({
    required this.groupId,
    required this.listId,
    required this.listName,
  });

  @override
  State<_BuyingView> createState() => _BuyingViewState();
}

class _BuyingViewState extends State<_BuyingView> {
  bool _urgentOnly = false;

  @override
  void initState() {
    super.initState();
    sl<CategoryRegistry>().ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<CompleteTripCubit, CompleteTripState>(
      listener: (context, state) {
        if (state is CompleteTripSuccess) {
          // Summary was already shown in the confirm dialog — Done is one
          // step, so success just exits to the group home.
          context.go('/groups/${widget.groupId}');
        } else if (state is CompleteTripError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: ZaytonaColors.navy,
        body: SafeArea(
          child: BlocBuilder<ActiveTripCubit, ActiveTripState>(
            builder: (context, tripState) {
              // Reaching this screen requires Start Trip to have already
              // locked a buyer — no active trip here means that precondition
              // failed (or the trip was completed from elsewhere in the
              // meantime). Fail loudly instead of guessing a fallback.
              if (tripState is ActiveTripError ||
                  (tripState is ActiveTripLoaded && tripState.trip == null)) {
                return TripPreconditionError(groupId: widget.groupId);
              }
              return BlocBuilder<ListItemsCubit, ListItemsState>(
                builder: (context, state) => switch (state) {
                  ListItemsInitial() || ListItemsLoading() =>
                    const Center(child: ZaytonaSpinningLogo()),
                  ListItemsError(:final message) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message,
                            style: ZaytonaType.bodySm.copyWith(color: ZaytonaColors.cream),
                          ),
                          const SizedBox(height: ZaytonaSpacing.space3),
                          TextButton(
                            onPressed: () => context.read<ListItemsCubit>().load(widget.listId),
                            child: Text(l10n.retryAction),
                          ),
                        ],
                      ),
                    ),
                  ListItemsLoaded(:final items, :final pendingIds) => BuyingViewBody(
                      listId: widget.listId,
                      listName: widget.listName,
                      items: items,
                      pendingIds: pendingIds,
                      urgentOnly: _urgentOnly,
                      onFilterChanged: (value) => setState(() => _urgentOnly = value),
                    ),
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
