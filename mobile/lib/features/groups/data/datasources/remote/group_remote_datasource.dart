import 'package:dio/dio.dart';
import '../../../../../core/network/network_client.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../../core/network/remote_data_source_base.dart';

/// GroupRemoteDataSource handles group management API calls (US-04..US-12).
class GroupRemoteDataSource with RemoteDataSourceBase {
  GroupRemoteDataSource(this._client);

  final NetworkClient _client;

  /// Groups the current user belongs to.
  Future<Response> listMyGroups() {
    return run(() => _client.get<Response>(
          request: NetworkRequest(endpoint: '/groups'),
          converter: (response) => response,
        ));
  }

  /// Creates a group; the caller becomes its admin.
  Future<Response> createGroup({
    required String name,
    String? icon,
    String type = 'household',
  }) {
    return run(() => _client.post<Response>(
          request: NetworkRequest(
            endpoint: '/groups',
            body: {
              'name': name,
              'type': type,
              'icon': ?icon,
            },
          ),
          converter: (response) => response,
        ));
  }

  /// Joins a group by its invite code.
  Future<Response> joinGroup({required String inviteCode}) {
    return run(() => _client.post<Response>(
          request: NetworkRequest(
            endpoint: '/groups/join',
            body: {'invite_code': inviteCode},
          ),
          converter: (response) => response,
        ));
  }

  /// Full group detail, including members.
  Future<Response> getGroup({required String groupId}) {
    return run(() => _client.get<Response>(
          request: NetworkRequest(endpoint: '/groups/$groupId'),
          converter: (response) => response,
        ));
  }

  /// Members of a group (GROUP_MEMBER rows).
  Future<Response> getMembers({required String groupId}) {
    return run(() => _client.get<Response>(
          request: NetworkRequest(endpoint: '/groups/$groupId/members'),
          converter: (response) => response,
        ));
  }

  /// Updates the group's identity (name and/or icon). Admin only.
  Future<Response> updateGroup({
    required String groupId,
    String? name,
    String? icon,
  }) {
    return run(() => _client.patch<Response>(
          request: NetworkRequest(
            endpoint: '/groups/$groupId',
            body: {
              'name': ?name,
              'icon': ?icon,
            },
          ),
          converter: (response) => response,
        ));
  }

  /// Removes a member from the group. Admin only.
  Future<Response> removeMember({
    required String groupId,
    required String userId,
  }) {
    return run(() => _client.delete<Response>(
          request: NetworkRequest(endpoint: '/groups/$groupId/members/$userId'),
          converter: (response) => response,
        ));
  }

  /// Transfers the admin role — atomic on the backend: the new admin is
  /// assigned and the current admin demoted in one operation.
  Future<Response> transferAdmin({
    required String groupId,
    required String userId,
  }) {
    return run(() => _client.post<Response>(
          request: NetworkRequest(
            endpoint: '/groups/$groupId/transfer-admin',
            body: {'new_admin_user_id': userId},
          ),
          converter: (response) => response,
        ));
  }

  /// Leaves the group. Any member may call this; the backend deletes the
  /// group outright if the caller was its last member, and refuses (400)
  /// if the caller is the admin and other members remain — transfer the
  /// admin role first in that case.
  Future<Response> leaveGroup({required String groupId}) {
    return run(() => _client.post<Response>(
          request: NetworkRequest(endpoint: '/groups/$groupId/leave'),
          converter: (response) => response,
        ));
  }

  /// Admin-only: deletes the group and everything it owns outright,
  /// regardless of member count.
  Future<Response> deleteGroup({required String groupId}) {
    return run(() => _client.delete<Response>(
          request: NetworkRequest(endpoint: '/groups/$groupId'),
          converter: (response) => response,
        ));
  }

}
