import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/error/result.dart';
import '../../../domain/entities/list_item.dart';
import '../../../domain/repositories/item_repository.dart';
import '../../../domain/usecases/add_item_usecase.dart';

class AddItemCubit extends Cubit<AddItemState> {
  AddItemCubit(this._addItemUseCase, this._itemRepo)
      : super(const AddItemInitial());
  final AddItemUseCase _addItemUseCase;
  final ItemRepository _itemRepo;

  /// Tracks the locally-picked photo path through the loading/error phases
  /// so it survives a failed submit and doesn't need separate widget state.
  void pickImage(String path) => emit(_withImage(path));

  void clearImage() => emit(_withImage(null));

  AddItemState _withImage(String? path) => switch (state) {
        AddItemInitial() => AddItemInitial(imagePath: path),
        AddItemLoading() => AddItemLoading(imagePath: path),
        AddItemSuccess(:final item) => AddItemSuccess(item, imagePath: path),
        AddItemError(:final message) =>
          AddItemError(message, imagePath: path),
      };

  Future<void> submit(AddItemParams params) async {
    final path = state.imagePath;
    emit(AddItemLoading(imagePath: path));
    switch (await _addItemUseCase(params)) {
      case ResultError(:final failure):
        emit(AddItemError(failure.message, imagePath: path));
      case Success(:final value):
        var item = value;
        // The item needs a listItemId before a photo can be attached, so
        // the upload follows item creation rather than happening up front.
        if (path != null) {
          final uploaded = await _itemRepo.uploadItemImage(
            listId: params.listId,
            listItemId: value.listItemId,
            filePath: path,
          );
          uploaded.fold(
            (_) => null, // a failed photo upload shouldn't block the add
            (url) => item = value.copyWith(imageUrl: url),
          );
        }
        emit(AddItemSuccess(item, imagePath: path));
    }
  }

  /// Editing an existing item already has a `listItemId`, so a newly picked
  /// replacement photo uploads directly instead of waiting on creation.
  Future<Result<Failure, String>> uploadImageForEdit({
    required String listId,
    required String listItemId,
    required String filePath,
  }) {
    return _itemRepo.uploadItemImage(
      listId: listId,
      listItemId: listItemId,
      filePath: filePath,
    );
  }
}

sealed class AddItemState {
  const AddItemState({this.imagePath});
  final String? imagePath;
}

final class AddItemInitial extends AddItemState {
  const AddItemInitial({super.imagePath});
}

final class AddItemLoading extends AddItemState {
  const AddItemLoading({super.imagePath});
}

final class AddItemSuccess extends AddItemState {
  AddItemSuccess(this.item, {super.imagePath});
  final ListItem item;
}

final class AddItemError extends AddItemState {
  AddItemError(this.message, {super.imagePath});
  final String message;
}
