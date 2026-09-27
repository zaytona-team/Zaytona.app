import 'package:dio/dio.dart';
import '../../../../../core/network/network_client.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../../core/network/remote_data_source_base.dart';

/// ItemRemoteDataSource — list-item API calls per the STAGE3 endpoint table
/// (US-16 add/edit/delete, US-26 mark purchased).
class ItemRemoteDataSource with RemoteDataSourceBase {
  ItemRemoteDataSource(this._client);

  final NetworkClient _client;

  /// List detail — metadata only, does NOT include items.
  Future<Response> getList({required String listId}) {
    return run(() => _client.get<Response>(
          request: NetworkRequest(endpoint: '/lists/$listId'),
          converter: (response) => response,
        ));
  }

  /// The dedicated items endpoint — returns a bare JSON array.
  Future<Response> getListItems({required String listId}) {
    return run(() => _client.get<Response>(
          request: NetworkRequest(endpoint: '/lists/$listId/items'),
          converter: (response) => response,
        ));
  }

  Future<Response> addItem({
    required String listId,
    required Map<String, dynamic> body,
  }) {
    return run(() => _client.post<Response>(
          request: NetworkRequest(endpoint: '/lists/$listId/items', body: body),
          converter: (response) => response,
        ));
  }

  Future<Response> updateItem({
    required String listId,
    required String listItemId,
    required Map<String, dynamic> body,
  }) {
    return run(() => _client.patch<Response>(
          request: NetworkRequest(
            endpoint: '/lists/$listId/items/$listItemId',
            body: body,
          ),
          converter: (response) => response,
        ));
  }

  Future<Response> deleteItem({
    required String listId,
    required String listItemId,
  }) {
    return run(() => _client.delete<Response>(
          request: NetworkRequest(endpoint: '/lists/$listId/items/$listItemId'),
          converter: (response) => response,
        ));
  }

  /// Deletes every item on the list in one atomic call, writing a single
  /// consolidated HISTORY row instead of one per item.
  Future<Response> deleteAllItems({required String listId}) {
    return run(() => _client.delete<Response>(
          request: NetworkRequest(endpoint: '/lists/$listId/items'),
          converter: (response) => response,
        ));
  }

  Future<Response> setPurchased({
    required String listId,
    required String listItemId,
    required bool isBought,
  }) {
    return run(() => _client.patch<Response>(
          request: NetworkRequest(
            endpoint: '/lists/$listId/items/$listItemId/purchase',
            body: {'is_bought': isBought},
          ),
          converter: (response) => response,
        ));
  }

  /// US-21. Response shape assumed (`{"image_url": "..."}"`) — undocumented
  /// beyond the STAGE3 service description; see backend-needs.md.
  Future<Response> uploadItemImage({
    required String listId,
    required String listItemId,
    required String filePath,
  }) {
    return run(() async {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
      });
      return _client.post<Response>(
        request: NetworkRequest(
          endpoint: '/lists/$listId/items/$listItemId/image',
          body: formData,
        ),
        converter: (response) => response,
      );
    });
  }

}
