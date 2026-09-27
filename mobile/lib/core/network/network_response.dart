class NetworkResponse<Body> {
  final int? statusCode;
  final Map<String, List<String>> headers;
  final Body? body;

  const NetworkResponse({required this.statusCode, required this.headers, this.body});
}
