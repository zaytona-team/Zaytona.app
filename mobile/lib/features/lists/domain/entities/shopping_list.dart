/// A shopping list as returned by the backend
/// (POST /groups/{groupId}/lists, GET /groups/{groupId}/lists, GET /lists/{listId}).
class ShoppingList {
  final String listId;

  /// Nullable by design: private lists have no group (see business rules).
  final String? groupId;
  final String createdBy;
  final String name;

  /// Backend enum. Always "active" in practice — a list is a single
  /// persistent container reused trip after trip, never marked
  /// "completed" (see ListFacadeMixin.complete_list on the backend).
  /// Kept only because the field still exists on the API response.
  final String status;

  /// Only present on detail responses that include the list's items.
  /// Null means "not included in this response", not "zero items".
  final int? itemCount;

  /// Bought-items count for the card's progress bar. Null when the
  /// response doesn't carry item data — the UI hides the bar then.
  final int? boughtCount;

  /// Urgent unbought items, for the card's urgent indicator. Null when
  /// unknown (same rule as [boughtCount]).
  final int? urgentCount;

  final DateTime? updatedAt;

  /// One of "red" | "indigo" | "mint" | "navy" | "lilac" — matches
  /// `ZaytonaListAccent` exactly. Null for lists created before the
  /// backend added this column.
  final String? color;

  const ShoppingList({
    required this.listId,
    this.groupId,
    required this.createdBy,
    required this.name,
    required this.status,
    this.itemCount,
    this.boughtCount,
    this.urgentCount,
    this.updatedAt,
    this.color,
  });

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    return ShoppingList(
      listId: json['list_id'] as String,
      groupId: json['group_id'] as String?,
      createdBy: json['created_by'] as String,
      name: json['name'] as String,
      status: json['status'] as String? ?? 'active',
      itemCount: items is List ? items.length : json['item_count'] as int?,
      boughtCount: items is List
          ? items.where((i) => i is Map && i['is_bought'] == true).length
          : json['bought_count'] as int?,
      urgentCount: items is List
          ? items
              .where((i) =>
                  i is Map && i['is_urgent'] == true && i['is_bought'] != true)
              .length
          : json['urgent_count'] as int?,
      updatedAt: json['updated_at'] is String
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      color: json['color'] as String?,
    );
  }
}
