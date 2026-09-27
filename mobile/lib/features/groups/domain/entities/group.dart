/// A group as returned by the backend (GET/POST /groups).
class Group {
  final String groupId;
  final String createdBy;
  final String name;
  final String? imageUrl;
  final String? icon;
  final String type;
  /// Null for private (individual) groups — they're never joinable.
  final String? inviteCode;

  /// Only present on the full detail response (GET /groups/{id}).
  /// List endpoints don't include it — null there, not an empty list,
  /// so callers can tell "no data yet" apart from "confirmed zero members".
  final int? memberCount;

  /// The caller's role in this group ('admin' | 'member'), when the
  /// response includes it. Gating on it is UX only — the backend's
  /// require_admin() is the enforcement.
  final String? role;

  const Group({
    required this.groupId,
    required this.createdBy,
    required this.name,
    this.imageUrl,
    this.icon,
    required this.type,
    this.inviteCode,
    this.memberCount,
    this.role,
  });

  bool get isPrivate => type == 'individual';

  bool get isAdmin => role == 'admin';

  Group copyWith({
    String? name,
    String? imageUrl,
    String? icon,
    String? type,
    String? inviteCode,
    int? memberCount,
    String? role,
  }) {
    return Group(
      groupId: groupId,
      createdBy: createdBy,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      inviteCode: inviteCode ?? this.inviteCode,
      memberCount: memberCount ?? this.memberCount,
      role: role ?? this.role,
    );
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    final members = json['members'];
    return Group(
      groupId: json['group_id'] as String,
      createdBy: json['created_by'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
      icon: json['icon'] as String?,
      type: json['type'] as String? ?? 'household',
      inviteCode: json['invite_code'] as String?,
      memberCount: json['member_count'] as int? ??
          (members is List ? members.length : null),
      role: json['role'] as String?,
    );
  }
}
