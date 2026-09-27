import 'package:dio/dio.dart';

/// An enum that holds names for our custom exceptions.
enum ExceptionType {
  /// The exception for an expired bearer token.
  tokenExpired,

  /// The exception for a prematurely cancelled request.
  cancel,

  /// The exception for a failed connection attempt.
  connectTimeout,

  /// The exception for failing to send a request.
  sendTimeout,

  /// The exception for failing to receive a response.
  receiveTimeout,

  /// The exception for no internet connectivity.
  socket,

  /// A better name for the socket exception.
  fetchData,

  /// The exception for an incorrect parameter in a request/response.
  format,

  /// The exception for an unknown type of failure.
  unrecognized,

  /// The exception for any parsing failure encountered during
  /// serialization/deserialization of a request.
  serialization,
}

/// Transport-level failure raised by [NetworkClient] — distinct from the
/// domain-level exceptions in core/error/exceptions.dart that datasources
/// map these into for repositories/cubits to consume.
class TransportException implements Exception {
  final String? message; // Should display a user-friendly message
  final String? code;
  final int? statusCode;
  final ExceptionType exceptionType;
  final dynamic responseData;

  TransportException({
    this.code,
    int? statusCode,
    this.message,
    required this.exceptionType,
    this.responseData,
  }) : statusCode = statusCode ?? 500;

  factory TransportException.handle(Exception error) {
    try {
      if (error is DioException) {
        final responseData = error.response?.data;
        switch (error.type) {
          case DioExceptionType.connectionError:
            return TransportException(
              exceptionType: ExceptionType.fetchData,
              statusCode: error.response?.statusCode,
              responseData: responseData,
            );
          case DioExceptionType.cancel:
            return TransportException(
              exceptionType: ExceptionType.cancel,
              statusCode: error.response?.statusCode,
              responseData: responseData,
            );
          case DioExceptionType.connectionTimeout:
            return TransportException(
              exceptionType: ExceptionType.connectTimeout,
              statusCode: error.response?.statusCode,
              responseData: responseData,
            );
          case DioExceptionType.sendTimeout:
            return TransportException(
              exceptionType: ExceptionType.sendTimeout,
              statusCode: error.response?.statusCode,
              responseData: responseData,
            );
          case DioExceptionType.receiveTimeout:
            return TransportException(
              exceptionType: ExceptionType.receiveTimeout,
              statusCode: error.response?.statusCode,
              responseData: responseData,
            );
          case DioExceptionType.badResponse:
          case DioExceptionType.unknown:
            return TransportException(
              code: error.response?.statusMessage,
              statusCode: error.response?.statusCode,
              exceptionType: ExceptionType.unrecognized,
              responseData: responseData,
            );
          case DioExceptionType.badCertificate:
            return TransportException(
              exceptionType: ExceptionType.unrecognized,
              statusCode: error.response?.statusCode,
              responseData: responseData,
            );
          case DioExceptionType.transformTimeout:
            return TransportException(
              exceptionType: ExceptionType.receiveTimeout,
              statusCode: error.response?.statusCode,
              responseData: responseData,
            );
        }
      } else {
        return TransportException(exceptionType: ExceptionType.unrecognized, message: 'Error unrecognized');
      }
    } on FormatException catch (e) {
      return TransportException(exceptionType: ExceptionType.format, message: e.message);
    } on Exception catch (_) {
      return TransportException(exceptionType: ExceptionType.unrecognized, message: 'Error unrecognized');
    }
  }

  factory TransportException.fromParsingException(Exception error) {
    return TransportException(exceptionType: ExceptionType.serialization);
  }
}
