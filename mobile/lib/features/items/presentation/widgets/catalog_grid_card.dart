import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/category_registry.dart';
import '../../domain/entities/catalog_entry.dart';

/// Prototype's per-category tone assignment (CATS table in
/// design_source/.../i18n.jsx) — arbitrary content data, not a color rule,
/// so it lives with the feature rather than in the design-system tokens.
const Map<CategoryId, ZaytonaCatalogTone> _catalogTone = {
  CategoryId.produce: ZaytonaCatalogTone.mint,
  CategoryId.bakery: ZaytonaCatalogTone.red,
  CategoryId.meat: ZaytonaCatalogTone.red,
  CategoryId.dairy: ZaytonaCatalogTone.indigo,
  CategoryId.frozen: ZaytonaCatalogTone.indigo,
  CategoryId.pantry: ZaytonaCatalogTone.lilac,
  CategoryId.cooking: ZaytonaCatalogTone.red,
  CategoryId.breakfast: ZaytonaCatalogTone.indigo,
  CategoryId.snacks: ZaytonaCatalogTone.lilac,
  CategoryId.beverages: ZaytonaCatalogTone.indigo,
  CategoryId.ready: ZaytonaCatalogTone.red,
  CategoryId.baby: ZaytonaCatalogTone.lilac,
  CategoryId.care: ZaytonaCatalogTone.mint,
  CategoryId.health: ZaytonaCatalogTone.red,
  CategoryId.household: ZaytonaCatalogTone.mint,
  CategoryId.pets: ZaytonaCatalogTone.lilac,
};

/// Catalog grid tile (US-16): wraps [ZaytonaCatalogCard] with the local
/// qty-stepper value and the transient "Added" flash, matching the
/// prototype's CatalogPicker (setTimeout(...,1200) revert).
class CatalogGridCard extends StatefulWidget {
  final CatalogEntry entry;
  final VoidCallback onTap;
  final Future<void> Function(int quantity) onAdd;

  const CatalogGridCard({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onAdd,
  });

  @override
  State<CatalogGridCard> createState() => _CatalogGridCardState();
}

class _CatalogGridCardState extends State<CatalogGridCard> {
  int _qty = 1;
  bool _added = false;
  bool _submitting = false;

  Future<void> _handleAdd() async {
    // Guard re-entrancy: without this, repeated taps before the first
    // request resolves each read the same not-yet-updated list state and
    // all decide independently to create a new item instead of merging.
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await widget.onAdd(_qty);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
    if (!mounted) return;
    setState(() => _added = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _added = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final category = sl<CategoryRegistry>().slugFor(widget.entry.categoryId);

    return ZaytonaCatalogCard(
      name: widget.entry.name,
      subtitleText: widget.entry.brand,
      tone: _catalogTone[category] ?? ZaytonaCatalogTone.indigo,
      added: _added,
      onTap: widget.onTap,
      seal: Image.asset(category.assetPath, width: 58, height: 58),
      quantity: ZaytonaQtyStepper(
        value: _qty,
        min: 1,
        size: ZaytonaQtyStepperSize.sm,
        onChanged: (v) => setState(() => _qty = v),
      ),
      action: ZaytonaButton(
        label: _added ? l10n.addedLabel : l10n.addAction,
        variant: ZaytonaButtonVariant.mint,
        size: ZaytonaButtonSize.sm,
        block: true,
        disabled: _submitting,
        iconLeft: Icon(_added ? Icons.check : Icons.add, size: 16),
        onTap: _handleAdd,
      ),
    );
  }
}
