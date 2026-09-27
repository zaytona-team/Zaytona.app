import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../l10n/app_localizations.dart';

/// Collapsible, searchable category picker.
///
/// Closed state: a bordered field showing the selected category as a filled
/// [ZaytonaCategoryChip] plus a chevron. Tapping expands a card below it with
/// a search field and a wrapping grid of category options.
class AddItemCategorySelector extends StatefulWidget {
  final CategoryId selected;
  final ValueChanged<CategoryId> onSelected;

  const AddItemCategorySelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<AddItemCategorySelector> createState() => _AddItemCategorySelectorState();
}

class _AddItemCategorySelectorState extends State<AddItemCategorySelector> {
  bool _open = false;
  String _query = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggle() => setState(() => _open = !_open);

  void _select(CategoryId cat) {
    widget.onSelected(cat);
    _searchController.clear();
    setState(() {
      _open = false;
      _query = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.categoryLabel, style: ZaytonaType.fieldLabel),
        const SizedBox(height: ZaytonaSpacing.space2),
        _ClosedField(selected: widget.selected, locale: locale, open: _open, onTap: _toggle),
        if (_open) ...[
          const SizedBox(height: ZaytonaSpacing.space2),
          _OptionsCard(
            locale: locale,
            query: _query,
            searchController: _searchController,
            selected: widget.selected,
            onQueryChanged: (v) => setState(() => _query = v),
            onSelect: _select,
          ),
        ],
      ],
    );
  }
}

class _ClosedField extends StatelessWidget {
  final CategoryId selected;
  final String locale;
  final bool open;
  final VoidCallback onTap;

  const _ClosedField({
    required this.selected,
    required this.locale,
    required this.open,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: ZaytonaRadius.brMd,
      child: Container(
        constraints: const BoxConstraints(minHeight: 54),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: ZaytonaSpacing.space4,
          vertical: ZaytonaSpacing.space2,
        ),
        decoration: BoxDecoration(
          color: ZaytonaColors.surfaceCard,
          border: Border.all(color: ZaytonaColors.borderBold, width: 2),
          borderRadius: ZaytonaRadius.brMd,
        ),
        child: Row(
          children: [
            Expanded(
              child: ZaytonaCategoryChip(
                label: selected.label(locale),
                icon: Image.asset(selected.assetPath, width: 20, height: 20),
                selected: true,
                onTap: onTap,
              ),
            ),
            AnimatedRotation(
              turns: open ? 0.5 : 0,
              duration: const Duration(milliseconds: 150),
              child: const Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: ZaytonaColors.ink300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionsCard extends StatelessWidget {
  final String locale;
  final String query;
  final TextEditingController searchController;
  final CategoryId selected;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<CategoryId> onSelect;

  const _OptionsCard({
    required this.locale,
    required this.query,
    required this.searchController,
    required this.selected,
    required this.onQueryChanged,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final q = query.trim().toLowerCase();
    final pool = CategoryId.values
        .where((c) => q.isEmpty || c.label(locale).toLowerCase().contains(q))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: ZaytonaColors.surfaceCard,
        border: Border.all(color: ZaytonaColors.borderBold, width: 2),
        borderRadius: ZaytonaRadius.brMd,
        boxShadow: ZaytonaShadows.shadowPop,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(ZaytonaSpacing.space3),
            child: ZaytonaTextField(
              controller: searchController,
              placeholder: l10n.categorySearchHint,
              icon: const Icon(Icons.search),
              onChanged: onQueryChanged,
              autofocus: true,
            ),
          ),
          Container(height: 1.5, color: ZaytonaColors.borderSoft),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 186),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(ZaytonaSpacing.space3),
              child: pool.isEmpty
                  ? Text(
                      l10n.noResultsTitle,
                      style: const TextStyle(
                        fontFamily: ZaytonaType.fontBody,
                        fontSize: 13,
                        color: ZaytonaColors.textMuted,
                      ),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final cat in pool)
                          ZaytonaCategoryChip(
                            label: cat.label(locale),
                            icon: Image.asset(cat.assetPath, width: 20, height: 20),
                            selected: cat == selected,
                            onTap: () => onSelect(cat),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
