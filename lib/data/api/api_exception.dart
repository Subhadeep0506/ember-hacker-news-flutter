class ApiException implements Exception {
  final int statusCode;
  final String error;
  final String? message;

  const ApiException({
    required this.statusCode,
    required this.error,
    this.message,
  });

  @override
  String toString() =>
      'ApiException($statusCode): $error${message != null ? ' - $message' : ''}';
}
