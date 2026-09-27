import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import 'package:zaytona/features/histories/presentation/cubit/history_cubit.dart';
import 'package:zaytona/features/histories/domain/entities/history_model.dart';
import 'package:zaytona/features/histories/domain/entities/trip_history_entry.dart';
import 'package:zaytona/features/histories/presentation/widgets/history_group_tile.dart';
import 'package:zaytona/features/histories/presentation/widgets/history_tab_switch.dart';
import 'package:zaytona/l10n/app_localizations.dart';

/// Always reached from a specific list's app bar (per-list activity +
/// that list's trips), so [listId] is required.
class HistoryPage extends StatefulWidget {
  final String listId;
  final String listName;

  const HistoryPage({super.key, required this.listId, required this.listName});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _selectedTabIndex = 0;

  static const Color _background = ZaytonaColors.bgApp;
  static const Color _navy = ZaytonaColors.textStrong;
  static const Color _orange = ZaytonaColors.red;
  static const Color _textSecondary = ZaytonaColors.textMuted;

  void _changeTab(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: ZaytonaSpacing.space4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ZaytonaSpacing.gutter),
              child: HistoryTabSwitch(
                selectedIndex: _selectedTabIndex,
                onChanged: _changeTab,
              ),
            ),
            const SizedBox(height: ZaytonaSpacing.space5),
            Expanded(child: _buildSelectedTab()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(ZaytonaSpacing.gutter, ZaytonaSpacing.space3, ZaytonaSpacing.gutter, 0),
      child: Row(
        children: [
          ZaytonaIconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            tone: ZaytonaIconButtonTone.navy,
            variant: ZaytonaIconButtonVariant.soft,
            size: ZaytonaIconButtonSize.lg,
            semanticLabel: AppLocalizations.of(context)!.backAction,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: ZaytonaSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.historyAction,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: ZaytonaSpacing.space1),
                Text(
                  widget.listName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _orange,
              shape: BoxShape.circle,
              border: Border.all(
                color: ZaytonaColors.navy,
                width: ZaytonaShadows.strokeBold,
              ),
              boxShadow: ZaytonaShadows.shadowPopSm,
            ),
            child: const Icon(
              Icons.history_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTab() {
    if (_selectedTabIndex == 1) {
      return _buildPreviousRoundsState();
    }

    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        return switch (state) {
          HistoryInitial() ||
          HistoryLoading() => const Center(child: ZaytonaSpinningLogo()),
          HistoryError(:final message) => _buildErrorState(context, message),
          HistoryLoaded(:final entries) =>
            entries.isEmpty
                ? _buildEmptyState(context)
                : ZaytonaRefreshIndicator(
                    onRefresh: () => context.read<HistoryCubit>().reload(),
                    child: _buildActivityList(entries),
                  ),
        };
      },
    );
  }

  Widget _buildActivityList(List<HistoryModel> entries) {
    final groups = groupConsecutiveByUser(entries);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(ZaytonaSpacing.gutter, 0, ZaytonaSpacing.gutter, ZaytonaSpacing.space7),
      itemCount: groups.length,
      itemBuilder: (context, index) => HistoryGroupTile(
        entries: groups[index],
        // No backend endpoint exists to undo an entry — see
        // HistoryModel.fromApi, canUndo is always false today.
        onUndoPressed: null,
      ),
    );
  }

  Widget _buildPreviousRoundsState() {
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        return switch (state) {
          HistoryInitial() ||
          HistoryLoading() => const Center(child: ZaytonaSpinningLogo()),
          HistoryError(:final message) => _buildErrorState(context, message),
          HistoryLoaded(:final trips) =>
            trips.isEmpty
                ? _buildNoTripsState(context)
                : ZaytonaRefreshIndicator(
                    onRefresh: () => context.read<HistoryCubit>().reload(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(ZaytonaSpacing.gutter, 0, ZaytonaSpacing.gutter, ZaytonaSpacing.space7),
                      itemCount: trips.length,
                      itemBuilder: (context, index) =>
                          _buildTripCard(context, trips[index]),
                    ),
                  ),
        };
      },
    );
  }

  Widget _buildTripCard(BuildContext context, TripHistoryEntry trip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ZaytonaSpacing.space4),
      child: ZaytonaTripCard(
        buyer: ZaytonaAvatar(
          name: trip.buyerName,
          src: trip.buyerAvatar,
          size: 32,
        ),
        buyerName: trip.buyerName,
        date: trip.completedAt != null
            ? MaterialLocalizations.of(
                context,
              ).formatShortDate(trip.completedAt!)
            : '',
        count: trip.itemCount,
        items: [for (final item in trip.items) item.name],
      ),
    );
  }

  Widget _buildNoTripsState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ZaytonaEmptyState(
      icon: const Icon(Icons.shopping_bag_outlined),
      title: l10n.historyNoTripsTitle,
      body: l10n.historyNoTripsBody,
      ctaLabel: l10n.backAction,
      ctaIcon: const Icon(Icons.chevron_right_rounded, size: 18),
      onCta: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ZaytonaSpacing.space7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: _orange, size: 52),
            const SizedBox(height: ZaytonaSpacing.space4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _navy,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: ZaytonaSpacing.space3),
            TextButton.icon(
              onPressed: () => context.read<HistoryCubit>().reload(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppLocalizations.of(context)!.retryAction),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ZaytonaEmptyState(
      icon: const Icon(Icons.history_toggle_off_rounded),
      title: l10n.historyActivityEmptyTitle,
      body: l10n.historyActivityEmptyBody,
      ctaLabel: l10n.backAction,
      ctaIcon: const Icon(Icons.chevron_right_rounded, size: 18),
      onCta: () => Navigator.of(context).pop(),
    );
  }
}
