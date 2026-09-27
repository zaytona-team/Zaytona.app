/// Units an item's quantity can be measured in.
/// Values match the allowed units list in validation.md exactly
/// (pcs, kg, g, L, ml, pack, box, bottle).
enum ItemUnit { pcs, kg, g, l, ml, pack, box, bottle }

extension ItemUnitX on ItemUnit {
  // this is what gets sent to the backend later
  String get apiValue {
    switch (this) {
      case ItemUnit.l:
        return 'L';
      default:
        return name;
    }
  }

  // Arabic label shown to the user
  String get arabicLabel {
    switch (this) {
      case ItemUnit.pcs:
        return 'قطعة';
      case ItemUnit.kg:
        return 'كجم';
      case ItemUnit.g:
        return 'جم';
      case ItemUnit.l:
        return 'لتر';
      case ItemUnit.ml:
        return 'مل';
      case ItemUnit.pack:
        return 'عبوة';
      case ItemUnit.box:
        return 'صندوق';
      case ItemUnit.bottle:
        return 'زجاجة';
    }
  }
}
