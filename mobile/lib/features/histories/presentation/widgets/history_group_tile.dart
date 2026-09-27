import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import 'package:zaytona/features/histories/domain/entities/history_model.dart';
import 'package:zaytona/features/histories/presentation/widgets/history_tile.dart';

/// A run of consecutive [HistoryModel] entries by the same user, rendered as
/// one block: the shared avatar/name shown once, each entry's description +
/// time stacked below it. [entries] must be non-empty.
class HistoryGroupTile extends StatelessWidget {
  final List<HistoryModel> entries;
  final void Function(HistoryModel entry)? onUndoPressed;

  const HistoryGroupTile({
    super.key,
    required this.entries,
    this.onUndoPressed,
  });

  @override
  Widget build(BuildContext context) {
    final first = entries.first;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ZaytonaSpacing.space3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ZaytonaAvatar(
            name: first.userName,
            src: first.userAvatar,
            size: 44,
          ),
          const SizedBox(width: ZaytonaSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  first.userName,
                  style: const TextStyle(
                    color: ZaytonaColors.textStrong,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.right,
                ),
                for (final entry in entries)
                  Padding(
                    padding: const EdgeInsets.only(top: ZaytonaSpacing.space2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: HistoryEntryRow(history: entry)),
                        const SizedBox(width: ZaytonaSpacing.space3),
                        SizedBox(
                          width: 54,
                          child: entry.canUndo && onUndoPressed != null
                              ? UndoLink(onPressed: () => onUndoPressed!(entry))
                              : Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    width: 9,
                                    height: 9,
                                    decoration: BoxDecoration(
                                      color: actionColorFor(entry.type),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Groups an [entries] list into runs of consecutive same-user entries,
/// used to build one [HistoryGroupTile] per run.
List<List<HistoryModel>> groupConsecutiveByUser(List<HistoryModel> entries) {
  final groups = <List<HistoryModel>>[];
  for (final entry in entries) {
    final lastGroup = groups.isEmpty ? null : groups.last;
    if (lastGroup != null && lastGroup.first.userName == entry.userName) {
      lastGroup.add(entry);
    } else {
      groups.add([entry]);
    }
  }
  return groups;
}
