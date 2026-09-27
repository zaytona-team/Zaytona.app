import 'package:dio/dio.dart';

import '../../../core/network/network_client.dart';
import '../../../core/network/network_request.dart';
import '../../../core/network/remote_data_source_base.dart';

class ProfileRemoteDataSource with RemoteDataSourceBase {
  final NetworkClient _client = NetworkClient.instance;

  Future<Map<String, dynamic>> getProfile() async {
    final response = await run(() => _client.get<Response>(
          request: NetworkRequest(endpoint: '/auth/me'),
          converter: (response) => response,
        ));
    return _map(response.data);
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    await run(() => _client.patch<Response>(
          request: NetworkRequest(
            endpoint: '/auth/me',
            body: {
              'first_name': firstName,
              'last_name': lastName,
            },
          ),
          converter: (response) => response,
        ));
  }

  Future<List<Map<String, dynamic>>> getAvatars() async {
    final response = await run(() => _client.get<Response>(
          request: NetworkRequest(endpoint: '/auth/avatars'),
          converter: (response) => response,
        ));
    final data = response.data;

    final list = data is List
        ? data
        : data is Map
            ? data['avatars'] ?? data['data'] ?? []
            : [];

    return List<Map<String, dynamic>>.from(
      list.map((avatar) => Map<String, dynamic>.from(avatar)),
    );
  }

  Future<void> selectAvatar(dynamic avatarId) async {
    await run(() => _client.post<Response>(
          request: NetworkRequest(
            endpoint: '/auth/profile/avatar/select',
            body: {'avatar_id': avatarId},
          ),
          converter: (response) => response,
        ));
  }

  Map<String, dynamic> _map(dynamic data) {
    if (data is Map && data['data'] is Map) {
      return Map<String, dynamic>.from(data['data']);
    }

    return Map<String, dynamic>.from(data as Map);
  }
}