import 'package:dio/dio.dart';
import '../error/exceptions.dart';
import 'errors/transport_exception.dart';
import 'network_response.dart';

const _timeoutTypes = {
  ExceptionType.connectTimeout,
  ExceptionType.sendTimeout,
  ExceptionType.receiveTimeout,
  ExceptionType.fetchData,
};

/// Shared error mapping for remote datasources: runs a [NetworkClient] call
/// and translates a [TransportException] into the domain-level exceptions
/// (core/error/exceptions.dart) that repositories expect.
mixin RemoteDataSourceBase {
  Future<Response> run(
    Future<NetworkResponse<Response>> Function() request, {
    String? notFoundMessage,
  }) async {
    try {
      final res = await request();
      return res.body as Response;
    } on TransportException catch (e) {
      if (_timeoutTypes.contains(e.exceptionType)) throw const NetworkException();
      final data = e.responseData;
      final message = data is Map && data['message'] is String ? data['message'] as String : null;
      if (e.statusCode == 404 && notFoundMessage != null) {
        throw ServerException(message ?? notFoundMessage);
      }
      throw ServerException(message ?? 'حدث خطأ، حاول مرة أخرى');
    }
  }
}
