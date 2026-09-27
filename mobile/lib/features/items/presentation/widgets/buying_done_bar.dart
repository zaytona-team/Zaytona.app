import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import '../cubit/trip/active_trip_cubit.dart';
import '../cubit/trip/complete_trip_cubit.dart';
import 'finish_trip_dialog.dart';

/// Cream-fade bottom bar with the Done button — the only way out of the
/// buying view. Resolves trip_id from [ActiveTripCubit] and disables
/// itself while that's still loading or a complete call is in flight.
class BuyingDoneBar extends StatelessWidget {
  final int checkedCount;
  final int totalCount;

  const BuyingDoneBar({
    super.key,
    required this.checkedCount,
    required this.totalCount,
  });

  Future<void> _confirmFinish(BuildContext context, String tripId) async {
    final cubit = context.read<CompleteTripCubit>();
    final confirmed = await showFinishTripDialog(
      context,
      bought: checkedCount,
      remaining: totalCount - checkedCount,
    );
    if (confirmed == true) {
      cubit.complete(tripId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        ZaytonaSpacing.space5,
        ZaytonaSpacing.space3,
        ZaytonaSpacing.space5,
        ZaytonaSpacing.space5,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [ZaytonaColors.cream, Color(0x00FFF8ED)],
          stops: [0.72, 1],
        ),
      ),
      child: BlocBuilder<CompleteTripCubit, CompleteTripState>(
        builder: (context, completeState) {
          final isCompleting = completeState is CompleteTripLoading;

          return BlocBuilder<ActiveTripCubit, ActiveTripState>(
            builder: (context, tripState) {
              final tripId =
                  tripState is ActiveTripLoaded ? tripState.trip?.tripId : null;

              return ZaytonaButton(
                label: checkedCount > 0
                    ? '${l10n.finishTrip} · $checkedCount'
                    : l10n.finishTrip,
                variant: ZaytonaButtonVariant.mint,
                size: ZaytonaButtonSize.lg,
                block: true,
                iconLeft: const Icon(Icons.check, size: 22),
                disabled: isCompleting || tripId == null,
                onTap: () => _confirmFinish(context, tripId!),
              );
            },
          );
        },
      ),
    );
  }
}
