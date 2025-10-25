class ApiException implements Exception {
  final dynamic message;
  final int? statusCode;
  final dynamic errorData;

  ApiException({required this.message, this.statusCode, this.errorData});

  @override
  String toString() =>
      'ApiException: $message (Status: $statusCode, $errorData)';
}
