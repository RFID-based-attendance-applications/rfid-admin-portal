class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorData;

  ApiException({required this.message, this.statusCode, this.errorData});

  @override
  String toString() =>
      'ApiException: $message (Status: $statusCode, $errorData)';
}
