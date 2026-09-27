import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/category_registry.dart';
import '../../domain/entities/list_item.dart';
import '../cubit/items/list_items_cubit.dart';

/// One item row via [ZaytonaItemTile]: category art/photo, name (+ flame
/// when urgent), brand, notes, inline qty stepper (qty < 1 deletes). Tap
/// opens the edit sheet. Bought state reads through strikethrough/dim on
/// the tile itself — no separate "done" icon needed on top of that.
class ListItemRow extends StatelessWidget {
  final ListItem item;
  final bool pending;
  final VoidCallback onTap;

  const ListItemRow({
    super.key,
    required this.item,
    required this.pending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ListItemsCubit>();
    final urgent = item.isUrgent && !item.isBought;
    final bought = item.isBought;

    return ZaytonaItemTile(
      layout: ZaytonaItemTileLayout.list,
      title: item.name,
      subtitle: item.brand,
      footer: item.notes,
      imageUrl: item.imageUrl,
      fallbackImage: AssetImage(
        sl<CategoryRegistry>().slugFor(item.categoryId).assetPath,
      ),
      urgent: urgent,
      strikethrough: bought,
      dim: bought,
      onTap: onTap,
      trailing: pending
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: ZaytonaSpacing.space2),
              child: ZaytonaSpinningLogo(size: 26),
            )
          : ZaytonaQtyStepper(
              value: item.quantity.round(),
              min: 0,
              size: ZaytonaQtyStepperSize.sm,
              onChanged: (q) async {
                if (q < 1) {
                  // Stepper is a controlled widget — declining leaves the
                  // displayed quantity unchanged, no accidental delete.
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(l10n.deleteItemConfirmTitle),
                      content: Text(l10n.deleteItemConfirmBody(item.name)),
                      actions: [
                        TextButton(
                          onPressed: () => dialogContext.pop(false),
                          child: Text(l10n.cancelAction),
                        ),
                        TextButton(
                          onPressed: () => dialogContext.pop(true),
                          child: Text(l10n.confirmAction),
                        ),
                      ],
                    ),
                  );
                  if (confirmed ?? false) cubit.deleteItem(item);
                } else {
                  cubit.changeQuantity(item, q.toDouble());
                }
              },
            ),
    );
  }
}
