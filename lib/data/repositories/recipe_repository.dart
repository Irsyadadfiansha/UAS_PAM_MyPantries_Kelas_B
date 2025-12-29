import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exceptions.dart';
import '../models/recipe_model.dart';

/// Recipe repository for recipe operations
class RecipeRepository {
  final ApiClient _apiClient;

  RecipeRepository(this._apiClient);

  /// Get all recipes
  Future<List<Recipe>> getRecipes({String? category, String? sortBy}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.recipes,
        queryParameters: {
          if (category != null) 'category': category,
          if (sortBy != null) 'sort_by': sortBy,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>;
      return items
          .map((item) => Recipe.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: 'Failed to get recipes: ${e.message}');
    }
  }

  /// Get recipes with match percentage
  Future<List<Recipe>> getRecipesWithMatch({
    String? category,
    String? sortBy,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.recipesWithMatch,
        queryParameters: {
          if (category != null) 'category': category,
          if (sortBy != null) 'sort_by': sortBy,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>;
      return items
          .map((item) => Recipe.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: 'Failed to get recipes: ${e.message}');
    }
  }

  /// Get recommended recipes (can cook now)
  Future<List<Recipe>> getRecommendations() async {
    try {
      final response = await _apiClient.get(ApiConstants.recipeRecommendations);
      final data = response.data as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>;
      return items
          .map((item) => Recipe.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(
        message: 'Failed to get recommendations: ${e.message}',
      );
    }
  }

  /// Get single recipe with ingredients
  Future<Recipe> getRecipe(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.recipes}/$id');
      final data = response.data as Map<String, dynamic>;
      return Recipe.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: 'Failed to get recipe: ${e.message}');
    }
  }

  /// Create new recipe
  Future<Recipe> createRecipe({
    required String title,
    required String description,
    required String instructions,
    required int cookingTime,
    int? servings,
    List<String>? categories,
    String? imageUrl,
    required List<Map<String, dynamic>> ingredients,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.recipes,
        data: {
          'title': title,
          'description': description,
          'instructions': instructions,
          'cooking_time': cookingTime,
          if (servings != null) 'servings': servings,
          if (categories != null) 'categories': categories,
          if (imageUrl != null) 'image_url': imageUrl,
          'ingredients': ingredients,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return Recipe.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: 'Failed to create recipe: ${e.message}');
    }
  }

  /// Update recipe
  Future<Recipe> updateRecipe({
    required int id,
    String? title,
    String? description,
    String? instructions,
    int? cookingTime,
    int? servings,
    List<String>? categories,
    String? imageUrl,
    List<Map<String, dynamic>>? ingredients,
  }) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.recipes}/$id',
        data: {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (instructions != null) 'instructions': instructions,
          if (cookingTime != null) 'cooking_time': cookingTime,
          if (servings != null) 'servings': servings,
          if (categories != null) 'categories': categories,
          if (imageUrl != null) 'image_url': imageUrl,
          if (ingredients != null) 'ingredients': ingredients,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return Recipe.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: 'Failed to update recipe: ${e.message}');
    }
  }

  /// Delete recipe
  Future<void> deleteRecipe(int id) async {
    try {
      await _apiClient.delete('${ApiConstants.recipes}/$id');
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: 'Failed to delete recipe: ${e.message}');
    }
  }

  /// Cook recipe (deduct ingredients from pantry)
  Future<void> cookRecipe(int id) async {
    try {
      await _apiClient.post('${ApiConstants.recipes}/$id/cook');
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: 'Failed to cook recipe: ${e.message}');
    }
  }
}

/// Provider for RecipeRepository
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepository(ref.watch(apiClientProvider));
});
