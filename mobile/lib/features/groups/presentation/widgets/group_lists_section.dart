import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../lists/domain/entities/shopping_list.dart';
import '../../../lists/presentation/cubit/lists/group_lists_cubit.dart';

class GroupListsSection extends StatefulWidget {
  final String groupId;
  final bool isPrivate;
  final VoidCallback onAddList;

  const GroupListsSection({
    super.key,
    required this.groupId,
    required this.isPrivate,
    required this.onAddList,
  });

  @override
  State<GroupListsSection> createState() => _GroupListsSectionState();
}

class _GroupListsSectionState extends State<GroupListsSection> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<GroupListsCubit, GroupListsState>(
      builder: (context, state) => switch (state) {
        GroupListsInitial() || GroupListsLoading() => const Padding(
          padding: EdgeInsets.symmetric(vertical: ZaytonaSpacing.space8),
          child: Center(child: ZaytonaSpinningLogo()),
        ),
        GroupListsError(:final message) => Column(
          children: [
            Text(message, style: const TextStyle(color: ZaytonaColors.navy)),
            const SizedBox(height: ZaytonaSpacing.space2),
            TextButton(
              onPressed: () =>
                  context.read<GroupListsCubit>().load(widget.groupId),
              child: Text(l10n.retryAction),
            ),
          ],
        ),
        GroupListsLoaded(:final lists) => _loaded(l10n, lists),
      },
    );
  }

  Widget _loaded(AppLocalizations l10n, List<ShoppingList> lists) {
    if (lists.isEmpty) {
      return ZaytonaEmptyState(
        icon: const Icon(Icons.list_alt_outlined),
        title: l10n.noListsYet,
        body: l10n.noListsYetBody,
        ctaLabel: l10n.createListAction,
        onCta: widget.onAddList,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final list in lists) ...[
          _ListCard(
            list: list,
            isPrivate: widget.isPrivate,
            groupId: widget.groupId,
          ),
          const SizedBox(height: ZaytonaSpacing.space3),
        ],
      ],
    );
  }
}

// Server-assigned accent (`ShoppingList.color`); falls back to a stable
// per-list-id derivation only for lists that predate the backend column.
extension _ListAccent on ShoppingList {
  ZaytonaListAccent get accent {
    final serverColor = color;
    if (serverColor != null) {
      for (final a in ZaytonaListAccent.values) {
        if (a.name == serverColor) return a;
      }
    }
    const accents = [
      ZaytonaListAccent.red,
      ZaytonaListAccent.mint,
      ZaytonaListAccent.indigo,
    ];
    return accents[listId.hashCode.abs() % accents.length];
  }
}

class _ListCard extends StatelessWidget {
  final ShoppingList list;
  final bool isPrivate;
  final String groupId;

  const _ListCard({
    required this.list,
    required this.isPrivate,
    required this.groupId,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteListConfirmTitle),
        content: Text(l10n.deleteListConfirmBody(list.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancelAction),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.confirmAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final cubit = context.read<GroupListsCubit>();
    final deleted = await cubit.deleteList(
      groupId: groupId,
      listId: list.listId,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted
              ? l10n.listDeletedMessage(list.name)
              : l10n.listDeleteFailedMessage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onLongPress: () => _confirmDelete(context),
      child: ZaytonaListSummaryCard(
        name: list.name,
        total: list.itemCount ?? 0,
        urgent: list.urgentCount ?? 0,
        itemsLabel: l10n.listItemCount(list.itemCount ?? 0),
        urgentLabel: (list.urgentCount ?? 0) > 0
            ? l10n.urgentCount(list.urgentCount ?? 0)
            : null,
        accent: list.accent,
        updated: list.updatedAt != null
            ? MaterialLocalizations.of(context).formatShortDate(list.updatedAt!)
            : null,
        onTap: () => context.push(
          '/groups/$groupId/lists/${list.listId}'
          '?name=${Uri.encodeComponent(list.name)}'
          '&color=${list.accent.name}'
          '${isPrivate ? '&private=true' : ''}',
        ),
      ),
    );
  }
}
