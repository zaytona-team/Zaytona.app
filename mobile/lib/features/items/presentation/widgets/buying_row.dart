import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/category_registry.dart';
import '../../domain/entities/list_item.dart';
import '../cubit/items/list_items_cubit.dart';

/// Check row — the ONLY interactive element in buying mode. Uses
/// [ZaytonaItemTile] for layout parity with list view/catalog (photo/brand/
/// notes now visible here too), with a custom checkbox in the trailing slot
/// and the whole row toggling purchased on tap.
class BuyingRow extends StatelessWidget {
  final ListItem item;
  final bool pending;

  const BuyingRow({super.key, required this.item, required this.pending});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final done = item.isBought;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: done ? 0.7 : 1,
      child: ZaytonaItemTile(
        layout: ZaytonaItemTileLayout.list,
        title: item.name,
        subtitle: item.brand,
        footer: item.notes?.isNotEmpty ?? false
            ? '${item.notes} · ${item.quantity.round()} ${item.unit}'
            : '${item.quantity.round()} ${item.unit}',
        imageUrl: item.imageUrl,
        fallbackImage: AssetImage(
          sl<CategoryRegistry>().slugFor(item.categoryId).assetPath,
        ),
        strikethrough: done,
        onTap: () => context.read<ListItemsCubit>().togglePurchased(item),
        trailing: item.isUrgent && !done
            ? ZaytonaBadge(
                label: l10n.urgentBadge,
                tone: ZaytonaBadgeTone.red,
                variant: ZaytonaBadgeVariant.solid,
                size: ZaytonaBadgeSize.sm,
              )
            : null,
        titlePrefix: pending
            ? const ZaytonaSpinningLogo(size: 22)
            : Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: done ? ZaytonaColors.mint : Colors.transparent,
                  border: Border.all(
                    color: ZaytonaColors.navy,
                    width: ZaytonaShadows.strokeBold,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: done
                    ? const Icon(Icons.check, size: 16, color: ZaytonaColors.navy)
                    : null,
              ),
      ),
    );
  }
}
