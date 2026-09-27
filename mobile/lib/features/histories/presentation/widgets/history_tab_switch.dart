import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import 'package:zaytona/l10n/app_localizations.dart';

const _activityValue = 'activity';
const _tripsValue = 'trips';

/// Thin adapter over the design system's [ZaytonaSegmentedControl] so the page
/// can keep tracking the selected tab as an int index.
class HistoryTabSwitch extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const HistoryTabSwitch({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ZaytonaSegmentedControl(
      fullWidth: true,
      value: selectedIndex == 1 ? _tripsValue : _activityValue,
      onChanged: (value) => onChanged(value == _tripsValue ? 1 : 0),
      options: [
        ZaytonaSegmentOption(value: _activityValue, label: l10n.historyTabActivity),
        ZaytonaSegmentOption(value: _tripsValue, label: l10n.historyTabTrips),
      ],
    );
  }
}
