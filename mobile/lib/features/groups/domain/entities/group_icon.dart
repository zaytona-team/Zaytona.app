import 'package:flutter/material.dart';

/// Icon choices available when creating a group. Values match the
/// backend's `icon` string field one-to-one (see ICON_CHOICES in
/// app/models/group.py on the backend branch).
enum GroupIcon { home, cart, coffee, moon, living, restaurant, pets, store }

extension GroupIconX on GroupIcon {
  String get apiValue => name;

  IconData get iconData {
    switch (this) {
      case GroupIcon.home:
        return Icons.home_outlined;
      case GroupIcon.cart:
        return Icons.shopping_cart_outlined;
      case GroupIcon.coffee:
        return Icons.coffee_outlined;
      case GroupIcon.moon:
        return Icons.bedtime_outlined;
      case GroupIcon.living:
        return Icons.weekend_outlined;
      case GroupIcon.restaurant:
        return Icons.restaurant_outlined;
      case GroupIcon.pets:
        return Icons.pets;
      case GroupIcon.store:
        return Icons.shopping_bag_outlined;
    }
  }

  static GroupIcon fromApiValue(String? value) {
    return GroupIcon.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => GroupIcon.home,
    );
  }
}
