class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => message;
}

class TimeoutException extends ApiException {
  TimeoutException()
      : super(
          message: 'Request timeout. Silakan coba lagi.',
          statusCode: 408,
        );
}
