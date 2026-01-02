
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}


class AuthException extends ApiException {
  AuthException({required super.message, super.statusCode, super.data});
}


class ValidationException extends ApiException {
  final Map<String, List<String>>? errors;

  ValidationException({
    required super.message,
    super.statusCode,
    super.data,
    this.errors,
  });
}


class NotFoundException extends ApiException {
  NotFoundException({required super.message, super.statusCode, super.data});
}


class ServerException extends ApiException {
  ServerException({required super.message, super.statusCode, super.data});
}


class NetworkException extends ApiException {
  NetworkException({required super.message, super.statusCode, super.data});
}


class TimeoutException extends ApiException {
  TimeoutException({required super.message, super.statusCode, super.data});
}
