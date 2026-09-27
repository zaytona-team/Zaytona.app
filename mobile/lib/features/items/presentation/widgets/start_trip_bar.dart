import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import '../cubit/items/list_items_cubit.dart';
import '../cubit/trip/active_trip_cubit.dart';

/// Bottom action bar: Start Trip (locked to one buyer, US-38) + Add Item.
/// Start Trip is disabled while another member already holds the buyer
/// spot — enforced server-side too (409/403), this is just the UX gate.
class StartTripBar extends StatelessWidget {
  final String groupId;
  final String listId;
  final String listName;
  final bool itemsEmpty;
  final VoidCallback onAddItem;

  const StartTripBar({
    super.key,
    required this.groupId,
    required this.listId,
    required this.listName,
    required this.itemsEmpty,
    required this.onAddItem,
  });

  Future<void> _onStartTrip(BuildContext context, ActiveTripState tripState) async {
    final cubit = context.read<ActiveTripCubit>();
    if (tripState is! ActiveTripLoaded || tripState.trip == null) {
      final started = await cubit.startAsSelf(listId);
      if (!started || !context.mounted) return;
    }
    await context.push(
      Uri(
        path: '${GoRouterState.of(context).uri.path}/buying',
        queryParameters: {'name': listName},
      ).toString(),
    );
    if (!context.mounted) return;
    // Trip may have checked/completed items — reload both.
    context.read<ListItemsCubit>().load(listId);
    // TODO: websocket — trip-started/trip-completed events from other
    // members should update this live instead of only on return-from-push.
    cubit.load(listId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<ActiveTripCubit, ActiveTripState>(
      builder: (context, tripState) {
        final lockedByOther = tripState is ActiveTripLoaded &&
            tripState.trip != null &&
            !tripState.isMine;
        final resolving = tripState is ActiveTripInitial || tripState is ActiveTripLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lockedByOther)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: ZaytonaSpacing.space2,
                  right: ZaytonaSpacing.space1,
                ),
                child: Text(l10n.tripInProgressByOther, style: ZaytonaType.meta),
              ),
            Row(
              children: [
                ZaytonaButton(
                  label: l10n.startTrip,
                  variant: ZaytonaButtonVariant.mint,
                  size: ZaytonaButtonSize.lg,
                  iconLeft: const Icon(Icons.storefront, size: 20),
                  disabled: itemsEmpty || lockedByOther || resolving,
                  onTap: () => _onStartTrip(context, tripState),
                ),
                const SizedBox(width: ZaytonaSpacing.space3),
                Expanded(
                  child: ZaytonaButton(
                    label: l10n.addItemAction,
                    variant: ZaytonaButtonVariant.primary,
                    size: ZaytonaButtonSize.lg,
                    block: true,
                    iconLeft: const Icon(Icons.add, size: 22),
                    onTap: onAddItem,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
