import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../core/di/injection_container.dart';
import '../../data/category_registry.dart';
import '../../domain/entities/item_unit.dart';
import '../../domain/entities/list_item.dart';
import '../../domain/usecases/add_item_usecase.dart';
import '../cubit/items/add_item_cubit.dart';

/// Resolves category to a UUID, then pops the edited item or submits a new one.
Future<void> submitAddItemForm({
  required BuildContext context,
  required String listId,
  required ListItem? editItem,
  required String name,
  required String? notes,
  required String? brand,
  required CategoryId category,
  required bool urgent,
  required ValueChanged<bool> setUploading,
}) async {
  await sl<CategoryRegistry>().ensureLoaded();
  final categoryId = sl<CategoryRegistry>().uuidFor(category);
  if (!context.mounted) return;

  if (editItem != null) {
    final cubit = context.read<AddItemCubit>();
    var imageUrl = editItem.imageUrl;
    final pickedPath = cubit.state.imagePath;
    if (pickedPath != null) {
      setUploading(true);
      final result = await cubit.uploadImageForEdit(
        listId: listId,
        listItemId: editItem.listItemId,
        filePath: pickedPath,
      );
      if (!context.mounted) return;
      setUploading(false);
      result.fold((_) => null, (url) => imageUrl = url);
    }
    // Quantity is edited in the list view, not here — left untouched.
    Navigator.of(context).pop(
      editItem.copyWith(
        name: name,
        categoryId: categoryId,
        notes: notes,
        brand: brand,
        isUrgent: urgent,
        imageUrl: imageUrl,
      ),
    );
    return;
  }

  context.read<AddItemCubit>().submit(
    AddItemParams(
      listId: listId,
      name: name,
      quantity: 1, // not collected here; edited later in the list view
      unit: ItemUnit.pcs.name, // prototype form has no unit picker
      categoryId: categoryId,
      notes: notes,
      brand: brand,
      isUrgent: urgent,
    ),
  );
}
