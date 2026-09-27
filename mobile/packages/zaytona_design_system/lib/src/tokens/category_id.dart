// category_id.dart
//
// The 16 permanent Zaytona grocery category identifiers.
// Slug strings match: cat-art/<id>.png assets AND the backend CAT(id) enum.
// Labels + accent colors sourced from the prototype's CATS table
// (design_source/.../ui_kits/thalaja-app/i18n.jsx) — fixed brand constants,
// not free translations, so they live here rather than in app l10n.

import 'dart:ui';

enum CategoryId {
  produce('خضار وفواكه', 'Produce', Color(0xFF43C08A)),
  bakery('مخبوزات', 'Bakery', Color(0xFFD98A3A)),
  meat('لحوم وأسماك', 'Meat', Color(0xFFFC5E4F)),
  dairy('ألبان وبيض', 'Dairy', Color(0xFF6A65EB)),
  frozen('مجمدات', 'Frozen', Color(0xFF3FB0D8)),
  pantry('مؤن', 'Pantry', Color(0xFFE07CBE)),
  cooking('أساسيات الطبخ', 'Cooking', Color(0xFFE8463A)),
  breakfast('فطور', 'Breakfast', Color(0xFF5C8DEF)),
  snacks('وجبات خفيفة', 'Snacks', Color(0xFFB072D8)),
  beverages('مشروبات', 'Beverages', Color(0xFF2FA7C9)),
  ready('وجبات جاهزة', 'Ready', Color(0xFFF2795B)),
  baby('أطفال', 'Baby', Color(0xFFEE8FBE)),
  care('عناية شخصية', 'Personal care', Color(0xFF2FBFA0)),
  health('صحة', 'Health', Color(0xFFEF5D7A)),
  household('منزلية', 'Household', Color(0xFF8B86EE)),
  pets('حيوانات أليفة', 'Pets', Color(0xFFC99A52));

  const CategoryId(this.labelAr, this.labelEn, this.color);

  final String labelAr;
  final String labelEn;

  /// Aisle accent color (prototype CATS.c).
  final Color color;

  String get assetPath => 'assets/cat-art/$name.png';

  /// Label for a locale code ('ar' | 'en').
  String label(String languageCode) => languageCode == 'ar' ? labelAr : labelEn;

  /// Resolves a backend slug; falls back to pantry like the prototype's CAT().
  static CategoryId fromSlug(String? slug) =>
      values.firstWhere((c) => c.name == slug, orElse: () => pantry);
}
