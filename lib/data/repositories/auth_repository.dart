import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exceptions.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';


class AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthRepository(this._apiClient, this._storageService);


  Future<User> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;
      final authResponse = AuthResponse.fromJson(data);

  
      await _storageService.saveToken(authResponse.token);
      await _storageService.saveUserId(authResponse.user.id);

      return authResponse.user;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: 'Login failed: ${e.message}');
    }
  }


  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final authResponse = AuthResponse.fromJson(data);

     
      await _storageService.saveToken(authResponse.token);
      await _storageService.saveUserId(authResponse.user.id);

      return authResponse.user;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: 'Registration failed: ${e.message}');
    }
  }


  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiConstants.user);
      final data = response.data as Map<String, dynamic>;
      print('getCurrentUser API response: $data');

   
      if (data.containsKey('data')) {
        return User.fromJson(data['data'] as Map<String, dynamic>);
      } else if (data.containsKey('user')) {
        return User.fromJson(data['user'] as Map<String, dynamic>);
      } else {
        return User.fromJson(data);
      }
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: 'Failed to get user: ${e.message}');
    }
  }


  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } catch (_) {
      // Ignore logout errors
    } finally {
      await _storageService.clearAll();
    }
  }


  Future<bool> isLoggedIn() async {
    return await _storageService.isLoggedIn();
  }
}


final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  );
});
