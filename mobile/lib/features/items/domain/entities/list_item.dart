import 'item_unit.dart';

/// Distinguishes "not passed" from "explicitly passed null" in [ListItem.copyWith]
/// for nullable fields the edit form can clear (e.g. erasing the brand field).
const Object _unset = Object();

/// One item on a shopping list (ER: LIST_ITEM joined with its catalog ITEM).
class ListItem {
  final String listItemId;
  final String listId;
  final String name;
  final double quantity;
  final String unit;

  /// Category slug from the fixed system enum (DS CategoryId slugs).
  final String? categoryId;
  final bool isBought;
  final bool isUrgent;
  final String? notes;
  final String? brand;
  final String? addedBy;
  final String? imageUrl;

  const ListItem({
    required this.listItemId,
    required this.listId,
    required this.name,
    required this.quantity,
    required this.unit,
    this.categoryId,
    this.isBought = false,
    this.isUrgent = false,
    this.notes,
    this.brand,
    this.addedBy,
    this.imageUrl,
  });

  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem(
      listItemId: json['list_item_id'] as String,
      listId: json['list_id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
      unit: json['unit'] as String? ?? ItemUnit.pcs.name,
      categoryId: json['category_id'] as String?,
      isBought: json['is_bought'] as bool? ?? false,
      isUrgent: json['is_urgent'] as bool? ?? false,
      notes: json['notes'] as String?,
      brand: json['brand'] as String?,
      addedBy: json['added_by'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  ListItem copyWith({
    double? quantity,
    String? unit,
    String? categoryId,
    bool? isBought,
    bool? isUrgent,
    // notes/brand/imageUrl: pass null explicitly to clear (e.g. the edit
    // form erasing the field), vs. omitting to leave unchanged.
    Object? notes = _unset,
    Object? brand = _unset,
    Object? imageUrl = _unset,
    String? name,
  }) {
    return ListItem(
      listItemId: listItemId,
      listId: listId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      categoryId: categoryId ?? this.categoryId,
      isBought: isBought ?? this.isBought,
      isUrgent: isUrgent ?? this.isUrgent,
      notes: identical(notes, _unset) ? this.notes : notes as String?,
      brand: identical(brand, _unset) ? this.brand : brand as String?,
      addedBy: addedBy,
      imageUrl:
          identical(imageUrl, _unset) ? this.imageUrl : imageUrl as String?,
    );
  }
}
