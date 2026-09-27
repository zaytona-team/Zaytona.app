/// One entry in the user's personal item history — an item they have
/// created before, across any of their groups, surfaced for one-tap reuse.
class CatalogEntry {
  final String name;
  final String? brand;
  final String? categoryId;
  final String? imageUrl;

  /// Server-provided ordering hint (`GET /users/me/items` returns most
  /// recently used first) — kept for a future "recently used" grouping,
  /// not currently displayed.
  final DateTime? lastUsedAt;

  const CatalogEntry({
    required this.name,
    this.brand,
    this.categoryId,
    this.imageUrl,
    this.lastUsedAt,
  });

  factory CatalogEntry.fromJson(Map<String, dynamic> json) {
    return CatalogEntry(
      name: json['name'] as String,
      brand: json['brand'] as String?,
      categoryId: json['category_id'] as String?,
      imageUrl: json['image_url'] as String?,
      lastUsedAt: json['last_used_at'] is String
          ? DateTime.tryParse(json['last_used_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'brand': brand,
        'category_id': categoryId,
        'image_url': imageUrl,
        'last_used_at': lastUsedAt?.toIso8601String(),
      };
}
