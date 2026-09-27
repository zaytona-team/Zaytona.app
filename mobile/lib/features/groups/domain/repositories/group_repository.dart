import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/group.dart';
import '../entities/group_member.dart';

abstract class GroupRepository {
  /// Groups the current user belongs to.
  Future<Result<Failure, List<Group>>> listMyGroups();

  /// Creates a group; the caller becomes its admin.
  Future<Result<Failure, Group>> createGroup({
    required String name,
    String? icon,
    String type = 'household',
  });

  /// Joins a group by its invite code.
  Future<Result<Failure, Group>> joinGroup({required String inviteCode});

  /// Full group detail, including members.
  Future<Result<Failure, Group>> getGroup({required String groupId});

  /// Members of a group.
  Future<Result<Failure, List<GroupMember>>> getMembers({
    required String groupId,
  });

  /// Updates the group's name and/or icon. Admin only.
  Future<Result<Failure, Group>> updateGroup({
    required String groupId,
    String? name,
    String? icon,
  });

  /// Removes a member. Admin only.
  Future<Result<Failure, void>> removeMember({
    required String groupId,
    required String userId,
  });

  /// Transfers the admin role atomically to [userId]. Admin only.
  Future<Result<Failure, void>> transferAdmin({
    required String groupId,
    required String userId,
  });

  /// Leaves the group (any member). The backend deletes the group
  /// outright if the caller was its last member; refuses (400) if the
  /// caller is admin and other members remain — transfer admin first.
  Future<Result<Failure, void>> leaveGroup({required String groupId});

  /// Deletes the group and everything it owns outright. Admin only.
  Future<Result<Failure, void>> deleteGroup({required String groupId});
}
