import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/repositories/group_repository.dart';
import '../datasources/remote/group_remote_datasource.dart';

class GroupRepositoryImpl implements GroupRepository {
  GroupRepositoryImpl(this._ds);
  final GroupRemoteDataSource _ds;

  @override
  Future<Result<Failure, List<Group>>> listMyGroups() async {
    try {
      final res = await _ds.listMyGroups();
      final data = res.data;
      if (data is! List) {
        return const ResultError(ValidationFailure('استجابة غير متوقعة من الخادم'));
      }
      final groups = data.map((g) => Group.fromJson(g as Map<String, dynamic>)).toList();
      return Success(groups);
    } on NetworkException catch (e) {
      return ResultError(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return ResultError(ServerFailure(e.message));
    } catch (_) {
      return const ResultError(ServerFailure());
    }
  }

  @override
  Future<Result<Failure, Group>> createGroup({
    required String name,
    String? icon,
    String type = 'household',
  }) async {
    try {
      final res = await _ds.createGroup(name: name, icon: icon, type: type);
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        return const ResultError(ValidationFailure('استجابة غير متوقعة من الخادم'));
      }
      return Success(Group.fromJson(data));
    } on NetworkException catch (e) {
      return ResultError(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return ResultError(ServerFailure(e.message));
    } catch (_) {
      return const ResultError(ServerFailure());
    }
  }

  @override
  Future<Result<Failure, Group>> joinGroup({required String inviteCode}) async {
    try {
      final res = await _ds.joinGroup(inviteCode: inviteCode);
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        return const ResultError(ValidationFailure('استجابة غير متوقعة من الخادم'));
      }
      return Success(Group.fromJson(data));
    } on NetworkException catch (e) {
      return ResultError(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return ResultError(ServerFailure(e.message));
    } catch (_) {
      return const ResultError(ServerFailure());
    }
  }

  @override
  Future<Result<Failure, Group>> getGroup({required String groupId}) async {
    try {
      final res = await _ds.getGroup(groupId: groupId);
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        return const ResultError(ValidationFailure('استجابة غير متوقعة من الخادم'));
      }
      return Success(Group.fromJson(data));
    } on NetworkException catch (e) {
      return ResultError(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return ResultError(ServerFailure(e.message));
    } catch (_) {
      return const ResultError(ServerFailure());
    }
  }

  @override
  Future<Result<Failure, List<GroupMember>>> getMembers({
    required String groupId,
  }) async {
    try {
      final res = await _ds.getMembers(groupId: groupId);
      final data = res.data;
      if (data is! List) {
        return const ResultError(ValidationFailure('استجابة غير متوقعة من الخادم'));
      }
      final members = data
          .map((m) => GroupMember.fromJson(m as Map<String, dynamic>))
          .toList();
      return Success(members);
    } on NetworkException catch (e) {
      return ResultError(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return ResultError(ServerFailure(e.message));
    } catch (_) {
      return const ResultError(ServerFailure());
    }
  }

  @override
  Future<Result<Failure, Group>> updateGroup({
    required String groupId,
    String? name,
    String? icon,
  }) async {
    try {
      final res = await _ds.updateGroup(groupId: groupId, name: name, icon: icon);
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        return const ResultError(ValidationFailure('استجابة غير متوقعة من الخادم'));
      }
      return Success(Group.fromJson(data));
    } on NetworkException catch (e) {
      return ResultError(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return ResultError(ServerFailure(e.message));
    } catch (_) {
      return const ResultError(ServerFailure());
    }
  }

  @override
  Future<Result<Failure, void>> removeMember({
    required String groupId,
    required String userId,
  }) async {
    try {
      await _ds.removeMember(groupId: groupId, userId: userId);
      return const Success(null);
    } on NetworkException catch (e) {
      return ResultError(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return ResultError(ServerFailure(e.message));
    } catch (_) {
      return const ResultError(ServerFailure());
    }
  }

  @override
  Future<Result<Failure, void>> transferAdmin({
    required String groupId,
    required String userId,
  }) async {
    try {
      await _ds.transferAdmin(groupId: groupId, userId: userId);
      return const Success(null);
    } on NetworkException catch (e) {
      return ResultError(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return ResultError(ServerFailure(e.message));
    } catch (_) {
      return const ResultError(ServerFailure());
    }
  }

  @override
  Future<Result<Failure, void>> leaveGroup({required String groupId}) async {
    try {
      await _ds.leaveGroup(groupId: groupId);
      return const Success(null);
    } on NetworkException catch (e) {
      return ResultError(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return ResultError(ServerFailure(e.message));
    } catch (_) {
      return const ResultError(ServerFailure());
    }
  }

  @override
  Future<Result<Failure, void>> deleteGroup({required String groupId}) async {
    try {
      await _ds.deleteGroup(groupId: groupId);
      return const Success(null);
    } on NetworkException catch (e) {
      return ResultError(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return ResultError(ServerFailure(e.message));
    } catch (_) {
      return const ResultError(ServerFailure());
    }
  }
}
