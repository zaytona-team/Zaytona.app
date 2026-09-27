/// One item bought on a trip, as returned by GET /lists/{id}/trips.
class TripHistoryItem {
  final String itemId;
  final String name;
  final String? quantity;
  final String? unit;
  final String? categoryId;

  const TripHistoryItem({
    required this.itemId,
    required this.name,
    this.quantity,
    this.unit,
    this.categoryId,
  });

  factory TripHistoryItem.fromApi(Map<String, dynamic> json) {
    return TripHistoryItem(
      itemId: json['item_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      quantity: json['quantity']?.toString(),
      unit: json['unit']?.toString(),
      categoryId: json['category_id']?.toString(),
    );
  }
}

/// One completed shopping trip, as returned by GET /lists/{id}/trips —
/// powers the History screen's "الرحلات" (previous trips) tab.
class TripHistoryEntry {
  final String tripId;
  final String listId;
  final String buyerId;
  final String buyerName;
  final String? buyerAvatar;
  final DateTime? completedAt;
  final int itemCount;

  /// Items actually bought on this trip. Bought items never leave the
  /// list they were bought on (US-38's rollover only relocates the
  /// still-unbought ones), so this is exactly what this trip bought.
  final List<TripHistoryItem> items;

  const TripHistoryEntry({
    required this.tripId,
    required this.listId,
    required this.buyerId,
    required this.buyerName,
    this.buyerAvatar,
    required this.completedAt,
    required this.itemCount,
    required this.items,
  });

  factory TripHistoryEntry.fromApi(Map<String, dynamic> json) {
    final items = json['items'];
    return TripHistoryEntry(
      tripId: json['trip_id']?.toString() ?? '',
      listId: json['list_id']?.toString() ?? '',
      buyerId: json['buyer_id']?.toString() ?? '',
      buyerName: json['buyer_name']?.toString() ?? '',
      completedAt: DateTime.tryParse(json['completed_at']?.toString() ?? ''),
      itemCount: json['item_count'] is int ? json['item_count'] as int : 0,
      items: items is List
          ? items
              .whereType<Map>()
              .map((e) => TripHistoryItem.fromApi(e.cast<String, dynamic>()))
              .toList()
          : const [],
    );
  }

  TripHistoryEntry withBuyer(String name, String? avatar) => TripHistoryEntry(
        tripId: tripId,
        listId: listId,
        buyerId: buyerId,
        buyerName: name,
        buyerAvatar: avatar,
        completedAt: completedAt,
        itemCount: itemCount,
        items: items,
      );
}
