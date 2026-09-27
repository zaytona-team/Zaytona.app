import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'api_config.dart';
import 'errors/transport_exception.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/refresh_interceptor.dart';
import 'network_request.dart';
import 'network_response.dart';

/// Shared typed Dio wrapper — the app's single network client. Attaches the
/// stored access token via [AuthInterceptor], refreshes it on a 401 via
/// [TokenRefresher] before falling back to logout, and retries once on a
/// Render cold-start timeout.
class NetworkClient {
  late Dio _dio;
  static NetworkClient instance = NetworkClient._();

  NetworkClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
      ),
    );

    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(RefreshInterceptor(_dio));
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestBody: true,
          requestHeader: true,
          responseBody: true,
          responseHeader: true,
          error: true,
        ),
      );
    }
  }

  Future<NetworkResponse<Body>> get<Body>({
    required NetworkRequest request,
    required Body Function(Response response) converter,
  }) async {
    try {
      final response = await _dio.get(
        request.endpoint,
        queryParameters: request.queryParams,
        options: _buildOptions(request),
        cancelToken: request.cancelToken,
      );
      return NetworkResponse<Body>(
        body: converter(response),
        headers: response.headers.map,
        statusCode: response.statusCode,
      );
    } catch (error) {
      throw TransportException.handle(error as Exception);
    }
  }

  Future<NetworkResponse<Body>> post<Body>({
    required NetworkRequest request,
    required Body Function(Response response) converter,
  }) async {
    try {
      final response = await _dio.post(
        request.endpoint,
        data: request.body,
        queryParameters: request.queryParams,
        options: _buildOptions(request),
        cancelToken: request.cancelToken,
      );
      return NetworkResponse<Body>(
        body: converter(response),
        headers: response.headers.map,
        statusCode: response.statusCode,
      );
    } catch (error) {
      throw TransportException.handle(error as Exception);
    }
  }

  Future<NetworkResponse<Body>> put<Body>({
    required NetworkRequest request,
    required Body Function(Response response) converter,
  }) async {
    try {
      final response = await _dio.put(
        request.endpoint,
        data: request.body,
        queryParameters: request.queryParams,
        options: _buildOptions(request),
        cancelToken: request.cancelToken,
      );
      return NetworkResponse<Body>(
        body: converter(response),
        headers: response.headers.map,
        statusCode: response.statusCode,
      );
    } catch (error) {
      throw TransportException.handle(error as Exception);
    }
  }

  Future<NetworkResponse<Body>> delete<Body>({
    required NetworkRequest request,
    required Body Function(Response response) converter,
  }) async {
    try {
      final response = await _dio.delete(
        request.endpoint,
        data: request.body,
        queryParameters: request.queryParams,
        options: _buildOptions(request),
        cancelToken: request.cancelToken,
      );
      return NetworkResponse<Body>(
        body: converter(response),
        headers: response.headers.map,
        statusCode: response.statusCode,
      );
    } catch (error) {
      throw TransportException.handle(error as Exception);
    }
  }

  Future<NetworkResponse<Body>> patch<Body>({
    required NetworkRequest request,
    required Body Function(Response response) converter,
  }) async {
    try {
      final response = await _dio.patch(
        request.endpoint,
        data: request.body,
        queryParameters: request.queryParams,
        options: _buildOptions(request),
        cancelToken: request.cancelToken,
      );
      return NetworkResponse<Body>(
        body: converter(response),
        headers: response.headers.map,
        statusCode: response.statusCode,
      );
    } catch (error) {
      throw TransportException.handle(error as Exception);
    }
  }

  Options _buildOptions(NetworkRequest request) {
    return Options(
      headers: request.headers,
      extra: {AuthInterceptor.requiresAuthTokenKey: request.requiresAuthToken},
    );
  }
}
