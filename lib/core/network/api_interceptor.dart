import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/storage_service.dart';
import 'api_exceptions.dart';


class ApiInterceptor extends Interceptor {
  final Ref ref;

  ApiInterceptor(this.ref);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
   
    final storageService = ref.read(storageServiceProvider);
    final token = await storageService.getToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }


    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _handleError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        response: err.response,
        type: err.type,
      ),
    );
  }

  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'Koneksi timeout. Silakan coba lagi.',
          statusCode: null,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message:
              'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
          statusCode: null,
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);

      case DioExceptionType.cancel:
        return ApiException(message: 'Request dibatalkan.', statusCode: null);

      default:
        return ApiException(
          message: error.message ?? 'Terjadi kesalahan tidak diketahui.',
          statusCode: null,
        );
    }
  }

  ApiException _handleResponseError(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    String message = 'Terjadi kesalahan.';
    if (data is Map<String, dynamic>) {
      message = data['message'] ?? message;
    }

    switch (statusCode) {
      case 400:
        return ValidationException(
          message: message,
          statusCode: statusCode,
          data: data,
          errors: _extractValidationErrors(data),
        );

      case 401:
        return AuthException(
          message: 'Sesi telah berakhir. Silakan login kembali.',
          statusCode: statusCode,
          data: data,
        );

      case 403:
        return AuthException(
          message: 'Anda tidak memiliki akses untuk melakukan ini.',
          statusCode: statusCode,
          data: data,
        );

      case 404:
        return NotFoundException(
          message: 'Data tidak ditemukan.',
          statusCode: statusCode,
          data: data,
        );

      case 422:
        return ValidationException(
          message: message,
          statusCode: statusCode,
          data: data,
          errors: _extractValidationErrors(data),
        );

      case 500:
      case 502:
      case 503:
        return ServerException(
          message: 'Terjadi kesalahan pada server. Silakan coba lagi nanti.',
          statusCode: statusCode,
          data: data,
        );

      default:
        return ApiException(
          message: message,
          statusCode: statusCode,
          data: data,
        );
    }
  }

  Map<String, List<String>>? _extractValidationErrors(dynamic data) {
    if (data is Map<String, dynamic> && data['errors'] != null) {
      final errors = data['errors'] as Map<String, dynamic>;
      return errors.map((key, value) {
        if (value is List) {
          return MapEntry(key, value.cast<String>());
        }
        return MapEntry(key, [value.toString()]);
      });
    }
    return null;
  }
}
