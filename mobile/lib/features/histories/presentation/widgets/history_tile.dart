import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import 'package:zaytona/features/histories/domain/entities/history_model.dart';
import 'package:zaytona/l10n/app_localizations.dart';

class HistoryTile extends StatelessWidget {
  final HistoryModel history;
  final VoidCallback? onUndoPressed;

  const HistoryTile({
    super.key,
    required this.history,
    this.onUndoPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ZaytonaSpacing.space3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ZaytonaAvatar(
            name: history.userName,
            src: history.userAvatar,
            size: 44,
          ),
          const SizedBox(width: ZaytonaSpacing.space4),
          Expanded(
            child: HistoryEntryRow(history: history, showUserName: true),
          ),
          const SizedBox(width: ZaytonaSpacing.space3),
          SizedBox(
            width: 64,
            child: history.canUndo && onUndoPressed != null
                ? UndoLink(onPressed: onUndoPressed!)
                : Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: actionColorFor(history.type),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

Color actionColorFor(HistoryType type) {
  switch (type) {
    case HistoryType.created:
    case HistoryType.consumed:
      return ZaytonaColors.successInk;

    case HistoryType.updated:
      return ZaytonaColors.indigo;

    case HistoryType.deleted:
      return ZaytonaColors.red;

    case HistoryType.restocked:
      return ZaytonaColors.navySoft;
  }
}

String historyTimeText(BuildContext context, DateTime createdAt) {
  final l10n = AppLocalizations.of(context)!;
  final difference = DateTime.now().difference(createdAt);

  if (difference.inMinutes < 1) {
    return l10n.historyTimeJustNow;
  }

  if (difference.inMinutes < 60) {
    return l10n.historyTimeMinutesAgo(difference.inMinutes);
  }

  if (difference.inHours < 24) {
    return l10n.historyTimeHoursAgo(difference.inHours);
  }

  if (difference.inDays == 1) {
    return l10n.historyTimeYesterday;
  }

  return l10n.historyTimeDaysAgo(difference.inDays);
}

/// The description + relative-time (+ optional undo) body of a single
/// history entry, without the leading avatar — shared by [HistoryTile] and
/// grouped rendering so a run of same-user entries doesn't repeat the
/// avatar/name per row.
class HistoryEntryRow extends StatelessWidget {
  final HistoryModel history;
  final bool showUserName;
  final VoidCallback? onUndoPressed;

  const HistoryEntryRow({
    super.key,
    required this.history,
    this.showUserName = false,
    this.onUndoPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              if (showUserName)
                TextSpan(
                  text: '${history.userName} ',
                  style: const TextStyle(
                    color: ZaytonaColors.textStrong,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              TextSpan(
                text: history.description,
                style: TextStyle(
                  color: actionColorFor(history.type),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: ZaytonaSpacing.space2),
        Text(
          historyTimeText(context, history.createdAt),
          style: const TextStyle(
            color: ZaytonaColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class UndoLink extends StatelessWidget {
  final VoidCallback onPressed;

  const UndoLink({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: ZaytonaRadius.brPill,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: ZaytonaSpacing.space2, horizontal: ZaytonaSpacing.space1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.undo_rounded,
              size: 16,
              color: ZaytonaColors.textStrong,
            ),
            const SizedBox(width: ZaytonaSpacing.space1),
            Text(
              AppLocalizations.of(context)!.undoAction,
              style: const TextStyle(
                color: ZaytonaColors.textStrong,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
