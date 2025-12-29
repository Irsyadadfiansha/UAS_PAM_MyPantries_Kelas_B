/// Custom API exception classes
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Exception thrown when authentication fails
class AuthException extends ApiException {
  AuthException({required super.message, super.statusCode, super.data});
}

/// Exception thrown when validation fails
class ValidationException extends ApiException {
  final Map<String, List<String>>? errors;

  ValidationException({
    required super.message,
    super.statusCode,
    super.data,
    this.errors,
  });
}

/// Exception thrown when resource is not found
class NotFoundException extends ApiException {
  NotFoundException({required super.message, super.statusCode, super.data});
}

/// Exception thrown when server error occurs
class ServerException extends ApiException {
  ServerException({required super.message, super.statusCode, super.data});
}

/// Exception thrown when network connection fails
class NetworkException extends ApiException {
  NetworkException({required super.message, super.statusCode, super.data});
}

/// Exception thrown when request times out
class TimeoutException extends ApiException {
  TimeoutException({required super.message, super.statusCode, super.data});
}
