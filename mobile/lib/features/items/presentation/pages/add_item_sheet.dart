import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/list_item.dart';
import '../cubit/items/add_item_cubit.dart';
import 'add_item_form_view.dart';

/// Add/Edit item bottom sheet. Pops with the resulting [ListItem] on success.
class AddItemSheet extends StatelessWidget {
  final String listId;
  final ListItem? editItem;

  /// Names already on the list, for the non-blocking duplicate warning.
  final List<String> existingNames;

  /// Skip the browse-tiles step and open straight into the manual form.
  final bool startManual;

  /// Prefill values from a catalog item or a "My Items" draft.
  final String? initialName;
  final String? initialBrand;
  final String? initialCategoryId;

  const AddItemSheet({
    super.key,
    required this.listId,
    this.editItem,
    this.existingNames = const [],
    this.startManual = false,
    this.initialName,
    this.initialBrand,
    this.initialCategoryId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AddItemCubit>(),
      child: AddItemFormView(
        listId: listId,
        editItem: editItem,
        existingNames: existingNames,
        startManual: startManual,
        initialName: initialName,
        initialBrand: initialBrand,
        initialCategoryId: initialCategoryId,
      ),
    );
  }
}
