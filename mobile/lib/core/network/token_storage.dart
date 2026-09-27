import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the JWT access token (and the caller's own user_id) issued by
/// the backend after OTP verification.
class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _firstNameKey = 'first_name';
  static const _phoneKey = 'phone';
  static const _lastNameKey = 'last_name';
  static const _avatarKey = 'avatar';

  static Future<void> saveToken(String token) {
    return _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> readToken() {
    return _storage.read(key: _tokenKey);
  }

  static Future<void> saveRefreshToken(String token) {
    return _storage.write(key: _refreshTokenKey, value: token);
  }

  static Future<String?> readRefreshToken() {
    return _storage.read(key: _refreshTokenKey);
  }

  static Future<void> saveUserId(String userId) {
    return _storage.write(key: _userIdKey, value: userId);
  }

  static Future<String?> readUserId() {
    return _storage.read(key: _userIdKey);
  }


  static Future<void> saveFirstName(String firstName) {
  return _storage.write(
    key: _firstNameKey,
    value: firstName,
  );
}

  static Future<String?> readFirstName() {
    return _storage.read(key: _firstNameKey);
  }

  
  static Future<void> savePhone(String phone) {
    return _storage.write(key: _phoneKey, value: phone);
  }

  static Future<String?> readPhone() {
    return _storage.read(key: _phoneKey);
  }
  static Future<void> saveLastName(String lastName) {
    return _storage.write(
      key: _lastNameKey,
      value: lastName,
    );
  }

static Future<String?> readLastName() {
  return _storage.read(key: _lastNameKey);
}

static Future<void> saveAvatar(int avatar) {
  return _storage.write(
    key: _avatarKey,
    value: avatar.toString(),
  );
}

static Future<int> readAvatar() async {
  final value = await _storage.read(key: _avatarKey);
  return int.tryParse(value ?? '0') ?? 0;
}

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _firstNameKey);
    await _storage.delete(key: _phoneKey);
  }
}
