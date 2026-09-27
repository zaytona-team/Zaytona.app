import 'package:dio/dio.dart';
import '../../../../../core/network/network_client.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../../core/network/remote_data_source_base.dart';

class AuthRemoteDataSource with RemoteDataSourceBase {
  AuthRemoteDataSource(this._client);

  final NetworkClient _client;

  Future<Response> register({
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
  }) {
    return run(() => _client.post<Response>(
          request: NetworkRequest(
            endpoint: '/auth/register',
            body: {
              'first_name': firstName,
              'last_name': lastName,
              'phone': phone,
              'email': ?email,
            },
          ),
          converter: (response) => response,
        ));
  }

  Future<Response> login({required String identifier}) {
    return run(
      () => _client.post<Response>(
        request: NetworkRequest(
          endpoint: '/auth/login',
          body: {'identifier': identifier},
        ),
        converter: (response) => response,
      ),
      notFoundMessage: 'لا يوجد حساب مرتبط بهذا الرقم أو البريد',
    );
  }

  Future<Response> verifyOtp({
    required String phone,
    required String token,
    String? email,
  }) {
    return run(() => _client.post<Response>(
          request: NetworkRequest(
            endpoint: '/auth/otp/verify',
            body: {
              'phone': phone,
              'token': token,
              'email': ?email,
            },
          ),
          converter: (response) => response,
        ));
  }

  Future<Response> resendOtp({required String phone, String? channel}) {
    return run(() => _client.post<Response>(
          request: NetworkRequest(
            endpoint: '/auth/otp/resend',
            body: {'phone': phone, 'channel': ?channel},
          ),
          converter: (response) => response,
        ));
  }

}
