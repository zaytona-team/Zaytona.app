/// Mirrors the backend's `History.action` values exactly (US-Story 8) —
/// see GET /lists/{list_id}/history. No finer-grained taxonomy exists
/// server-side, so this enum doesn't invent one either.
enum HistoryType {
  created,
  updated,
  deleted,
  consumed,
  restocked,
}

class HistoryModel {
  final String id;
  final String listId;
  final String userName;
  final String? userAvatar;
  final String description;
  final DateTime createdAt;
  final HistoryType type;
  final bool canUndo;

  const HistoryModel({
    required this.id,
    required this.listId,
    required this.userName,
    this.userAvatar,
    required this.description,
    required this.createdAt,
    required this.type,
    this.canUndo = false,
  });

  String get userInitial {
    final trimmedName = userName.trim();
    if (trimmedName.isEmpty) return '؟';
    return trimmedName.substring(0, 1);
  }

  /// Builds an entry from one raw `History.to_dict()` element. [resolveName]
  /// maps `user_id` to a display name (the group's already-fetched members;
  /// falls back to a generic label for a removed/unknown member). The
  /// description names the actual item via `metadata.name` when present —
  /// every entry the backend writes now includes it; entries written
  /// before that fix won't have it, so it falls back to a generic word.
  /// A consolidated bulk-delete row instead carries `metadata.items` (a
  /// list) and `metadata.count`, with no top-level `name` — described by
  /// count instead.
  factory HistoryModel.fromApi(
    Map<String, dynamic> json, {
    required String Function(String userId) resolveName,
    String? Function(String userId)? resolveAvatar,
  }) {
    final type = HistoryTypeX.fromApiValue(json['action']?.toString());
    final userId = json['user_id']?.toString() ?? '';
    final metadata = json['metadata'];
    final itemName = metadata is Map ? metadata['name']?.toString() : null;
    final bulkCount =
        metadata is Map && metadata['items'] is List && itemName == null
            ? metadata['count'] as int?
            : null;
    return HistoryModel(
      id: json['action_id']?.toString() ?? '',
      listId: json['list_id']?.toString() ?? '',
      userName: resolveName(userId),
      userAvatar: resolveAvatar?.call(userId),
      description: bulkCount != null
          ? 'حذف $bulkCount عناصر'
          : type.describe(itemName),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      type: type,
      // undo_available_until/is_undone are never set by the backend today
      // (schema-only, no endpoint writes them) — always non-undoable.
      canUndo: json['is_undone'] != true && json['undo_available_until'] != null,
    );
  }
}

extension HistoryTypeX on HistoryType {
  String get apiValue => name;

  /// Arabic phrasing per action, naming the actual item when it's known.
  String describe(String? itemName) {
    final name = itemName ?? 'عنصر';
    switch (this) {
      case HistoryType.created:
        return 'أضاف $name';
      case HistoryType.updated:
        return 'عدّل $name';
      case HistoryType.deleted:
        return 'حذف $name';
      case HistoryType.consumed:
        return 'حدد $name كمشترى';
      case HistoryType.restocked:
        return 'أعاد $name للقائمة';
    }
  }

  static HistoryType fromApiValue(String? value) {
    return HistoryType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => HistoryType.updated,
    );
  }
}
