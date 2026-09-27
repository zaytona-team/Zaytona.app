import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/list_item.dart';
import '../cubit/items/add_item_cubit.dart';
import '../widgets/add_item_category_selector.dart';
import '../widgets/add_item_extra_details.dart';
import '../widgets/add_item_form_submit.dart';
import '../widgets/add_item_image_picker.dart';
import '../widgets/add_item_name_field.dart';
import '../widgets/add_item_photo_field.dart';
import '../widgets/add_item_sheet_frame.dart';
import '../widgets/add_item_submit_button.dart';
import '../widgets/add_item_urgent_toggle.dart';

/// Holds the form's text controllers and local picker selections.
class AddItemFormView extends StatefulWidget {
  final String listId;
  final ListItem? editItem;
  final List<String> existingNames;
  final bool startManual;
  final String? initialName;
  final String? initialBrand;
  final String? initialCategoryId;

  const AddItemFormView({
    super.key,
    required this.listId,
    required this.editItem,
    required this.existingNames,
    required this.startManual,
    required this.initialName,
    required this.initialBrand,
    required this.initialCategoryId,
  });

  @override
  State<AddItemFormView> createState() => _AddItemFormViewState();
}

class _AddItemFormViewState extends State<AddItemFormView> {
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _noteController;

  bool get _editing => widget.editItem != null;
  late final bool _manualMode = _editing || widget.startManual;
  late CategoryId _category = CategoryId.fromSlug(
    widget.editItem?.categoryId ?? widget.initialCategoryId,
  );
  late bool _urgent = widget.editItem?.isUrgent ?? false;
  String? _nameError;
  bool _uploadingImage = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.editItem?.name ?? widget.initialName ?? '',
    );
    _brandController = TextEditingController(
      text: widget.editItem?.brand ?? widget.initialBrand ?? '',
    );
    _noteController = TextEditingController(text: widget.editItem?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// Non-blocking duplicate hint (business rule: user can proceed anyway).
  bool get _isPossibleDuplicate {
    if (_editing) return false;
    final name = _nameController.text.trim().toLowerCase();
    return name.isNotEmpty &&
        widget.existingNames.any((n) => n.trim().toLowerCase() == name);
  }

  Future<void> _pickImage(BuildContext context) async {
    final path = await pickAddItemImagePath(context);
    if (path == null || !context.mounted) return;
    context.read<AddItemCubit>().pickImage(path);
  }

  Future<void> _submit(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = l10n.fieldRequired);
      return;
    }
    final note = _noteController.text.trim();
    final brand = _brandController.text.trim();
    await submitAddItemForm(
      context: context,
      listId: widget.listId,
      editItem: widget.editItem,
      name: name,
      notes: note.isEmpty ? null : note,
      brand: brand.isEmpty ? null : brand,
      category: _category,
      urgent: _urgent,
      setUploading: (v) => setState(() => _uploadingImage = v),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AddItemSheetFrame(
      title: _editing
          ? l10n.editItemTitle
          : _manualMode
              ? l10n.manualEntryTitle
              : l10n.addItemAction,
      footer: AddItemSubmitButton(
        editing: _editing,
        uploadingImage: _uploadingImage,
        label: _editing ? l10n.saveChangesAction : l10n.addToListAction,
        onTap: () => _submit(context),
      ),
      child: _manualForm(),
    );
  }

  // Primary fields are always visible; brand/notes are behind the disclosure.
  Widget _manualForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddItemPhotoField(
          existingImageUrl: widget.editItem?.imageUrl,
          onPick: () => _pickImage(context),
        ),
        const SizedBox(height: ZaytonaSpacing.space4),
        AddItemNameField(
          controller: _nameController,
          error: _nameError,
          showDuplicateWarning: _isPossibleDuplicate,
          onChanged: (_) => setState(() => _nameError = null),
        ),
        const SizedBox(height: ZaytonaSpacing.space4),
        AddItemCategorySelector(
          selected: _category,
          onSelected: (cat) => setState(() => _category = cat),
        ),
        const SizedBox(height: ZaytonaSpacing.space4),
        AddItemUrgentToggle(
          urgent: _urgent,
          onChanged: (v) => setState(() => _urgent = v),
        ),
        const SizedBox(height: ZaytonaSpacing.space4),
        AddItemExtraDetails(
          brandController: _brandController,
          noteController: _noteController,
        ),
      ],
    );
  }
}
