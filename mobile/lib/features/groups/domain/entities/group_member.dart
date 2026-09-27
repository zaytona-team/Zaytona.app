/// A member row from GET /groups/{id}/members (GROUP_MEMBER table).
class GroupMember {
  final String userId;
  final String name;

  /// 'admin' | 'member'. Exactly one admin exists per group.
  final String role;
  final String? avatar;

  const GroupMember({
    required this.userId,
    required this.name,
    required this.role,
    this.avatar,
  });

  bool get isAdmin => role == 'admin';

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    // The docs name the member's display name inconsistently across
    // examples; accept the common variants and verify on switch-over.
    final first = json['first_name'] as String?;
    final last = json['last_name'] as String?;
    final joined = [first, last].whereType<String>().join(' ');
    return GroupMember(
      userId: json['user_id'] as String,
      name: (json['name'] as String?) ?? (joined.isEmpty ? '' : joined),
      role: json['role'] as String? ?? 'member',
      // USER.avatar_url per the ER diagram (STAGE3technicaldocumentation.md)
      // — accept 'avatar' too in case a response shape uses the shorter key.
      avatar: json['avatar_url'] as String? ?? json['avatar'] as String?,
    );
  }
}
