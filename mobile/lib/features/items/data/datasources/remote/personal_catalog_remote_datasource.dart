import 'package:dio/dio.dart';
import '../../../../../core/network/network_client.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../../core/network/remote_data_source_base.dart';

/// Distinct items the authenticated user has created across every group
/// they belong to, most recently used first (derived server-side from
/// list_items — no dedicated table).
class PersonalCatalogRemoteDataSource with RemoteDataSourceBase {
  PersonalCatalogRemoteDataSource(this._client);

  final NetworkClient _client;

  Future<Response> getMyItems() {
    return run(() => _client.get<Response>(
          request: NetworkRequest(endpoint: '/users/me/items'),
          converter: (response) => response,
        ));
  }
}
