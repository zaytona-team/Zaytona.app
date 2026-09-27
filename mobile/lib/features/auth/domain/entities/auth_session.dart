class AuthSession {
  const AuthSession({required this.accessToken, required this.phone, this.firstName, this.userId});
  final String accessToken;
  final String phone;
  final String? firstName;
  final String? userId;
}