import 'package:dio/dio.dart';
import '../../../../../core/network/network_client.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../../core/network/remote_data_source_base.dart';

/// HistoryRemoteDataSource — activity-log reads (Story 8).
class HistoryRemoteDataSource with RemoteDataSourceBase {
  HistoryRemoteDataSource(this._client);

  final NetworkClient _client;

  Future<Response> getListHistory({required String listId}) {
    return run(() => _client.get<Response>(
          request: NetworkRequest(endpoint: '/lists/$listId/history'),
          converter: (response) => response,
        ));
  }

  /// Completed trips for this list, newest first — powers the "الرحلات"
  /// (previous trips) tab.
  Future<Response> getListTrips({required String listId}) {
    return run(() => _client.get<Response>(
          request: NetworkRequest(endpoint: '/lists/$listId/trips'),
          converter: (response) => response,
        ));
  }

}
