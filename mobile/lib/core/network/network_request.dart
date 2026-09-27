import 'package:dio/dio.dart';

class NetworkRequest {
  final String endpoint;
  final Map<String, dynamic>? headers;
  final Map<String, String>? queryParams;
  final Object? body;
  final CancelToken? cancelToken;
  final bool requiresAuthToken;

  NetworkRequest({
    required this.endpoint,
    this.headers,
    this.body,
    this.queryParams,
    this.cancelToken,

    this.requiresAuthToken = true,
  });
}
