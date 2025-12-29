import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exceptions.dart';
import '../models/pantry_item_model.dart';

/// Pantry repository for pantry operations
class PantryRepository {
  final ApiClient _apiClient;

  PantryRepository(this._apiClient);

  /// Get all pantry items
  Future<List<PantryItem>> getPantryItems() async {
    try {
      final response = await _apiClient.get(ApiConstants.pantry);
      final data = response.data as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>;
      return items
          .map((item) => PantryItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: 'Failed to get pantry items: ${e.message}');
    }
  }

  /// Get items expiring soon (within 7 days)
  Future<List<PantryItem>> getExpiringSoon() async {
    try {
      final response = await _apiClient.get(ApiConstants.pantryExpiringSoon);
      final data = response.data as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>;
      return items
          .map((item) => PantryItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: 'Failed to get expiring items: ${e.message}');
    }
  }

  /// Get single pantry item
  Future<PantryItem> getPantryItem(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.pantry}/$id');
      final data = response.data as Map<String, dynamic>;
      return PantryItem.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: 'Failed to get pantry item: ${e.message}');
    }
  }

  /// Add new pantry item
  Future<PantryItem> addPantryItem({
    required int ingredientId,
    required double quantity,
    required String unit,
    double? price,
    DateTime? expiryDate,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.pantry,
        data: {
          'ingredient_id': ingredientId,
          'quantity': quantity,
          'unit': unit,
          if (price != null) 'price': price,
          if (expiryDate != null)
            'expiry_date': expiryDate.toIso8601String().substring(0, 10),
        },
      );
      final data = response.data as Map<String, dynamic>;
      return PantryItem.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: 'Failed to add pantry item: ${e.message}');
    }
  }

  /// Update pantry item
  Future<PantryItem> updatePantryItem({
    required int id,
    int? ingredientId,
    double? quantity,
    String? unit,
    double? price,
    DateTime? expiryDate,
  }) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.pantry}/$id',
        data: {
          if (ingredientId != null) 'ingredient_id': ingredientId,
          if (quantity != null) 'quantity': quantity,
          if (unit != null) 'unit': unit,
          if (price != null) 'price': price,
          if (expiryDate != null)
            'expiry_date': expiryDate.toIso8601String().substring(0, 10),
        },
      );
      final data = response.data as Map<String, dynamic>;
      return PantryItem.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: 'Failed to update pantry item: ${e.message}');
    }
  }

  /// Delete pantry item
  Future<void> deletePantryItem(int id) async {
    try {
      await _apiClient.delete('${ApiConstants.pantry}/$id');
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: 'Failed to delete pantry item: ${e.message}');
    }
  }
}

/// Provider for PantryRepository
final pantryRepositoryProvider = Provider<PantryRepository>((ref) {
  return PantryRepository(ref.watch(apiClientProvider));
});
