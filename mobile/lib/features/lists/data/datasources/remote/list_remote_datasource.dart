import 'package:dio/dio.dart';
import '../../../../../core/network/network_client.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../../core/network/remote_data_source_base.dart';

/// ListRemoteDataSource handles shopping-list API calls (US-13..US-15).
class ListRemoteDataSource with RemoteDataSourceBase {
  ListRemoteDataSource(this._client);

  final NetworkClient _client;

  /// Creates a list inside a group. Backend checks membership (403 if not).
  Future<Response> createList({required String groupId, required String name}) {
    return run(() => _client.post<Response>(
          request: NetworkRequest(
            endpoint: '/groups/$groupId/lists',
            body: {'name': name},
          ),
          converter: (response) => response,
        ));
  }

  /// All lists belonging to a group.
  Future<Response> getGroupLists({required String groupId}) {
    return run(() => _client.get<Response>(
          request: NetworkRequest(endpoint: '/groups/$groupId/lists'),
          converter: (response) => response,
        ));
  }

  /// Full list detail.
  Future<Response> getList({required String listId}) {
    return run(() => _client.get<Response>(
          request: NetworkRequest(endpoint: '/lists/$listId'),
          converter: (response) => response,
        ));
  }

  /// Deletes the whole list. Not in the documented STAGE3 endpoint table —
  /// see Documentation/backend-needs.md.
  Future<Response> deleteList({
    required String groupId,
    required String listId,
  }) {
    return run(() => _client.delete<Response>(
          request: NetworkRequest(endpoint: '/groups/$groupId/lists/$listId'),
          converter: (response) => response,
        ));
  }

  /// Updates a list's name and/or accent color.
  Future<Response> updateList({
    required String listId,
    required String name,
    String? color,
  }) {
    return run(() => _client.patch<Response>(
          request: NetworkRequest(
            endpoint: '/lists/$listId',
            body: {'name': name, 'color': ?color},
          ),
          converter: (response) => response,
        ));
  }

}
