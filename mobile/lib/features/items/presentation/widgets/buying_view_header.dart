import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../l10n/app_localizations.dart';

/// Navy header: storefront icon, list name + progress, all/urgent filter.
class BuyingViewHeader extends StatelessWidget {
  final String listName;
  final int checkedCount;
  final int totalCount;
  final bool urgentOnly;
  final ValueChanged<bool> onFilterChanged;

  const BuyingViewHeader({
    super.key,
    required this.listName,
    required this.checkedCount,
    required this.totalCount,
    required this.urgentOnly,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ZaytonaSpacing.space5,
        ZaytonaSpacing.space4,
        ZaytonaSpacing.space5,
        ZaytonaSpacing.space4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: ZaytonaSpacing.tapMin,
                height: ZaytonaSpacing.tapMin,
                decoration: const BoxDecoration(
                  color: ZaytonaColors.mint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.storefront,
                  size: 22,
                  color: ZaytonaColors.navy,
                ),
              ),
              const SizedBox(width: ZaytonaSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ZaytonaType.sheetTitle.copyWith(
                        color: ZaytonaColors.cream,
                        fontSize: 21,
                      ),
                    ),
                    const SizedBox(height: ZaytonaSpacing.space1),
                    Text(
                      '${l10n.buyingModeLabel} · $checkedCount/$totalCount',
                      style: ZaytonaType.meta.copyWith(color: ZaytonaColors.mint),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: ZaytonaSpacing.space4),
          Row(
            children: [
              _FilterPill(
                label: l10n.showAllFilter,
                icon: Icons.list,
                selected: !urgentOnly,
                selectedFill: ZaytonaColors.mint,
                selectedInk: ZaytonaColors.navy,
                onTap: () => onFilterChanged(false),
              ),
              const SizedBox(width: ZaytonaSpacing.space2),
              _FilterPill(
                label: l10n.urgentFilter,
                icon: Icons.local_fire_department,
                selected: urgentOnly,
                selectedFill: ZaytonaColors.red,
                selectedInk: ZaytonaColors.cream,
                onTap: () => onFilterChanged(true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color selectedFill;
  final Color selectedInk;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.selectedFill,
    required this.selectedInk,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ink = selected ? selectedInk : ZaytonaColors.cream;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: ZaytonaSpacing.controlHSm,
        padding: const EdgeInsets.symmetric(horizontal: ZaytonaSpacing.space4),
        decoration: BoxDecoration(
          color: selected ? selectedFill : ZaytonaColors.cream.withValues(alpha: 0.1),
          border: Border.all(
            color: selected ? selectedFill : ZaytonaColors.cream.withValues(alpha: 0.22),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(ZaytonaRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: ink),
            const SizedBox(width: ZaytonaSpacing.space2),
            Text(
              label,
              style: TextStyle(
                fontFamily: ZaytonaType.fontDisplay,
                fontFamilyFallback: const [ZaytonaType.fontBody],
                fontWeight: ZaytonaType.fwBold,
                fontSize: 13.5,
                color: ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
