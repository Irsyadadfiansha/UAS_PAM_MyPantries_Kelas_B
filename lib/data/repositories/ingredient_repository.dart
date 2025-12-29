import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exceptions.dart';
import '../models/ingredient_model.dart';

/// Ingredient repository for ingredient operations
class IngredientRepository {
  final ApiClient _apiClient;

  IngredientRepository(this._apiClient);

  /// Get all ingredients
  Future<List<Ingredient>> getIngredients() async {
    try {
      final response = await _apiClient.get(ApiConstants.ingredients);
      final data = response.data as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>;
      return items
          .map((item) => Ingredient.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: 'Failed to get ingredients: ${e.message}');
    }
  }

  /// Get ingredient categories
  Future<List<String>> getCategories() async {
    try {
      final response = await _apiClient.get(ApiConstants.ingredientCategories);
      final data = response.data as Map<String, dynamic>;
      final categories = data['data'] as List<dynamic>;
      return categories.cast<String>();
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: 'Failed to get categories: ${e.message}');
    }
  }

  /// Get single ingredient
  Future<Ingredient> getIngredient(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.ingredients}/$id');
      final data = response.data as Map<String, dynamic>;
      return Ingredient.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: 'Failed to get ingredient: ${e.message}');
    }
  }

  /// Create new ingredient
  Future<Ingredient> createIngredient({
    required String name,
    required String category,
    String? defaultUnit,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.ingredients,
        data: {
          'name': name,
          'category': category,
          if (defaultUnit != null) 'default_unit': defaultUnit,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return Ingredient.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: 'Failed to create ingredient: ${e.message}');
    }
  }
}

/// Provider for IngredientRepository
final ingredientRepositoryProvider = Provider<IngredientRepository>((ref) {
  return IngredientRepository(ref.watch(apiClientProvider));
});
