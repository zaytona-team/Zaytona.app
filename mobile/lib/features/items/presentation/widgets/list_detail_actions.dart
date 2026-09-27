import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/list_item.dart';
import '../cubit/items/list_items_cubit.dart';
import '../pages/add_item_sheet.dart';

/// Editing an existing row stays a sheet; adding a new item goes through
/// the full-screen Catalog page (search/browse/my-items/manual).
Future<void> openEditSheet(
  BuildContext context,
  String listId,
  ListItem edit,
) async {
  final cubit = context.read<ListItemsCubit>();
  final existingNames = switch (cubit.state) {
    ListItemsLoaded(:final items) => items.map((i) => i.name).toList(),
    _ => const <String>[],
  };
  final result = await showModalBottomSheet<ListItem>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddItemSheet(
      listId: listId,
      editItem: edit,
      existingNames: existingNames,
    ),
  );
  if (result != null) {
    cubit.updateItem(result);
  }
}

Future<void> openCatalog(BuildContext context, String listId) async {
  final cubit = context.read<ListItemsCubit>();
  final result = await context.push<Object>(
    '${GoRouterState.of(context).uri.path}/add-item',
  );
  if (result is ListItem) {
    cubit.itemAdded(result);
  } else if (result == true) {
    cubit.load(listId);
  }
}
