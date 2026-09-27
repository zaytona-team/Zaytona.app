import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/category_registry.dart';
import '../../domain/entities/list_item.dart';
import '../cubit/items/catalog_cubit.dart';
import '../cubit/items/catalog_state.dart';
import '../widgets/catalog_grid_card.dart';
import 'add_item_sheet.dart';

/// Full-screen "Add Item" entry point (US-16): the user's personal item
/// history — every item they've created before, across every group —
/// searchable, filterable by category, one-tap re-added. Every path here
/// ends at [AddItemSheet]; the tile's own quick-add button is the only
/// exception (adds directly with default quantity, no sheet).
class CatalogPage extends StatelessWidget {
  final String listId;

  const CatalogPage({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CatalogCubit>()
        ..loadMyItems()
        ..loadExistingItems(listId),
      child: _CatalogView(listId: listId),
    );
  }
}

class _CatalogView extends StatelessWidget {
  final String listId;

  const _CatalogView({required this.listId});

  Future<void> _openManualForm(
    BuildContext context, {
    bool startManual = false,
    String? name,
    String? brand,
    String? categoryId,
  }) async {
    final existingNames = context
        .read<CatalogCubit>()
        .state
        .existingItems
        .map((i) => i.name)
        .toList();
    final result = await showModalBottomSheet<ListItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddItemSheet(
        listId: listId,
        startManual: startManual,
        initialName: name,
        initialBrand: brand,
        initialCategoryId: categoryId,
        existingNames: existingNames,
      ),
    );
    if (result != null && context.mounted) {
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final cubit = context.read<CatalogCubit>();

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(cubit.state.hasQuickAdded ? true : null);
      },
      child: Scaffold(
        backgroundColor: ZaytonaColors.bgApp,
        floatingActionButton: ZaytonaButton(
          label: l10n.addManuallyAction,
          variant: ZaytonaButtonVariant.primary,
          size: ZaytonaButtonSize.lg,
          iconLeft: const Icon(Icons.edit_outlined),
          onTap: () => _openManualForm(context, startManual: true),
        ),
        body: SafeArea(
          child: BlocListener<CatalogCubit, CatalogState>(
            listenWhen: (previous, current) =>
                current.feedback != null &&
                current.feedback != previous.feedback,
            listener: (context, state) {
              final message = state.mergedQuantity == null
                  ? l10n.itemAddedMessage(state.feedback!)
                  : l10n.itemQuantityIncreasedMessage(
                      state.feedback!,
                      state.mergedQuantity!.toInt(),
                    );
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pinned header — search + category filter stay visible while
                // the grid below scrolls.
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    ZaytonaSpacing.space5,
                    ZaytonaSpacing.space1,
                    ZaytonaSpacing.space5,
                    ZaytonaSpacing.space3,
                  ),
                  child: Row(
                    children: [
                      ZaytonaIconButton(
                        icon: const Icon(Icons.chevron_left),
                        tone: ZaytonaIconButtonTone.navy,
                        variant: ZaytonaIconButtonVariant.soft,
                        size: ZaytonaIconButtonSize.sm,
                        semanticLabel: l10n.backAction,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: ZaytonaSpacing.space2),
                      Expanded(
                        child: Text(
                          l10n.catalogTitle,
                          style: ZaytonaType.sheetTitle,
                        ),
                      ),
                    ],
                  ),
                ),
                BlocBuilder<CatalogCubit, CatalogState>(
                  buildWhen: (previous, current) =>
                      previous.myItems.isEmpty != current.myItems.isEmpty,
                  builder: (context, state) {
                    if (state.myItems.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ZaytonaSpacing.space5,
                      ),
                      child: ZaytonaTextField(
                        placeholder: l10n.catalogSearchHint,
                        icon: const Icon(Icons.search, size: 18),
                        onChanged: cubit.setSearchQuery,
                      ),
                    );
                  },
                ),
                const SizedBox(height: ZaytonaSpacing.space3),
                BlocBuilder<CatalogCubit, CatalogState>(
                  buildWhen: (previous, current) =>
                      previous.myItems != current.myItems ||
                      previous.categoryFilter != current.categoryFilter,
                  builder: (context, state) {
                    final presentCats = CategoryId.values
                        .where(
                          (c) => state.myItems.any(
                            (e) =>
                                sl<CategoryRegistry>().slugFor(
                                  e.categoryId,
                                ) ==
                                c,
                          ),
                        )
                        .toList();
                    if (presentCats.isEmpty) return const SizedBox.shrink();
                    return SizedBox(
                      height: ZaytonaSpacing.tapMin,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                        horizontal: ZaytonaSpacing.space5,
                      ),
                        children: [
                          ZaytonaCategoryChip(
                            label: l10n.allCategories,
                            selected: state.categoryFilter == null,
                            onTap: () => cubit.setCategoryFilter(null),
                          ),
                          for (final cat in presentCats) ...[
                            const SizedBox(width: ZaytonaSpacing.space2),
                            ZaytonaCategoryChip(
                              label: cat.label(locale),
                              icon: Image.asset(
                                cat.assetPath,
                                width: 20,
                                height: 20,
                              ),
                              selected: state.categoryFilter == cat,
                              onTap: () => cubit.setCategoryFilter(cat),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: ZaytonaSpacing.space2),
                Expanded(
                  child: BlocBuilder<CatalogCubit, CatalogState>(
                    builder: (context, state) {
                      if (state.myItems.isEmpty) {
                        return ZaytonaEmptyState(
                          icon: const Icon(Icons.shopping_basket_outlined),
                          title: l10n.catalogEmptyTitle,
                          body: l10n.catalogEmptyBody,
                          ctaLabel: l10n.addManuallyAction,
                          onCta: () =>
                              _openManualForm(context, startManual: true),
                        );
                      }

                      final filtered = state.myItems.where((entry) {
                        final matchesQuery =
                            state.searchQuery.isEmpty ||
                            entry.name.toLowerCase().contains(
                              state.searchQuery,
                            );
                        final matchesCategory =
                            state.categoryFilter == null ||
                            sl<CategoryRegistry>().slugFor(
                                  entry.categoryId,
                                ) ==
                                state.categoryFilter;
                        return matchesQuery && matchesCategory;
                      }).toList();

                      if (filtered.isEmpty) {
                        return ZaytonaEmptyState(
                          icon: const Icon(Icons.search_off),
                          title: l10n.noResultsTitle,
                          body: l10n.nothingInCategory,
                          ctaLabel: l10n.clearFilterAction,
                          ctaIcon: const Icon(Icons.close, size: 18),
                          onCta: () {
                            context.read<CatalogCubit>().setSearchQuery('');
                            context.read<CatalogCubit>().setCategoryFilter(
                              null,
                            );
                          },
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          ZaytonaSpacing.space5,
                          ZaytonaSpacing.space1,
                          ZaytonaSpacing.space5,
                          ZaytonaSpacing.space12,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              // A fixed aspect ratio was the actual bug:
                              // ZaytonaCatalogCard's content height is
                              // mostly fixed pixels (86px image + fixed
                              // stepper/button heights), not proportional
                              // to cell width, but aspect-ratio shrinks
                              // the height budget along with width on
                              // narrower devices — so no ratio value can
                              // work across all screen sizes. A fixed
                              // mainAxisExtent instead gives every card
                              // the same row height regardless of device
                              // width, matching how the content actually
                              // behaves. The card's fixed sub-widgets sum
                              // to ~223px, but that was measured in a
                              // widget test against Flutter's fallback
                              // test font — the real bundled fonts (MADE
                              // Tommy Soft / Vazirmatn) render taller, so
                              // this carries real margin on top, not just
                              // the test's. See
                              // test/widgets/grid_card_overflow_test.dart
                              // (now loads the real fonts via
                              // flutter_test_config.dart).
                              mainAxisExtent: 258,
                            ),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) => CatalogGridCard(
                          entry: filtered[i],
                          onTap: () => _openManualForm(
                            context,
                            startManual: true,
                            name: filtered[i].name,
                            brand: filtered[i].brand,
                            categoryId: filtered[i].categoryId,
                          ),
                          onAdd: (quantity) => cubit.quickAdd(
                            listId,
                            filtered[i],
                            quantity: quantity.toDouble(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
