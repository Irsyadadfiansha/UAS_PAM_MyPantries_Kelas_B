import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/recipe_model.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../core/network/api_exceptions.dart';


class RecipeState {
  final bool isLoading;
  final List<Recipe> recipes;
  final List<Recipe> recommendations;
  final String? error;
  final String? selectedCategory;
  final String? sortBy;
  final bool showOnlyCanCook;
  final int? cookingRecipeId;

  const RecipeState({
    this.isLoading = false,
    this.recipes = const [],
    this.recommendations = const [],
    this.error,
    this.selectedCategory,
    this.sortBy,
    this.showOnlyCanCook = false,
    this.cookingRecipeId,
  });

  
  List<Recipe> get filteredRecipes {
    var result = recipes;

   
    if (selectedCategory != null) {
      result = result.where((r) {
        final recipeCategories = r.categories ?? [];
        return recipeCategories.any(
          (cat) => cat.toLowerCase() == selectedCategory!.toLowerCase(),
        );
      }).toList();
    }

   
    if (showOnlyCanCook) {
      result = result.where((r) => r.canCook == true).toList();
    }

    return result;
  }

  int get canCookCount => recipes.where((r) => r.canCook == true).length;

  RecipeState copyWith({
    bool? isLoading,
    List<Recipe>? recipes,
    List<Recipe>? recommendations,
    String? error,
    String? selectedCategory,
    String? sortBy,
    bool? showOnlyCanCook,
    int? cookingRecipeId,
  }) {
    return RecipeState(
      isLoading: isLoading ?? this.isLoading,
      recipes: recipes ?? this.recipes,
      recommendations: recommendations ?? this.recommendations,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sortBy: sortBy ?? this.sortBy,
      showOnlyCanCook: showOnlyCanCook ?? this.showOnlyCanCook,
      cookingRecipeId: cookingRecipeId,
    );
  }
}


class RecipeNotifier extends StateNotifier<RecipeState> {
  final RecipeRepository _recipeRepository;

  RecipeNotifier(this._recipeRepository) : super(const RecipeState());


  Future<void> loadRecipes() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final recipes = await _recipeRepository.getRecipesWithMatch(
        category: state.selectedCategory,
        sortBy: state.sortBy,
      );
      state = state.copyWith(isLoading: false, recipes: recipes);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }


  Future<void> loadRecommendations() async {
    try {
      final recommendations = await _recipeRepository.getRecommendations();
      state = state.copyWith(recommendations: recommendations);
    } catch (_) {}
  }


  Future<bool> createRecipe({
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
      print('Creating recipe: $title');
      final recipe = await _recipeRepository.createRecipe(
        title: title,
        description: description,
        instructions: instructions,
        cookingTime: cookingTime,
        servings: servings,
        categories: categories,
        imageUrl: imageUrl,
        ingredients: ingredients,
      );
      print('Recipe created successfully: ${recipe.id}');
      state = state.copyWith(recipes: [...state.recipes, recipe]);
      return true;
    } on ApiException catch (e) {
      print('API Error creating recipe: ${e.message}');
      state = state.copyWith(error: e.message);
      return false;
    } catch (e) {
      print('Unexpected error creating recipe: $e');
      state = state.copyWith(error: 'Unexpected error: $e');
      return false;
    }
  }


  Future<bool> deleteRecipe(int id) async {
    try {
      await _recipeRepository.deleteRecipe(id);
      state = state.copyWith(
        recipes: state.recipes.where((r) => r.id != id).toList(),
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    }
  }


  Future<bool> cookRecipe(int id) async {
 
    state = state.copyWith(cookingRecipeId: id);

    try {
      await _recipeRepository.cookRecipe(id);
     
      state = state.copyWith(cookingRecipeId: null);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(cookingRecipeId: null, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        cookingRecipeId: null,
        error: 'Gagal memasak resep: $e',
      );
      return false;
    }
  }


  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

 
  void setSortBy(String? sort) {
    state = state.copyWith(sortBy: sort);
  }


  void setShowOnlyCanCook(bool value) {
    state = state.copyWith(showOnlyCanCook: value);
  }


  void clearFilters() {
    state = state.copyWith(
      selectedCategory: null,
      sortBy: null,
      showOnlyCanCook: false,
    );
  }


  void clearError() {
    state = state.copyWith(error: null);
  }

 
  Future<void> refresh() async {
    await Future.wait([loadRecipes(), loadRecommendations()]);
  }
}


final recipeProvider = StateNotifierProvider<RecipeNotifier, RecipeState>((
  ref,
) {
  return RecipeNotifier(ref.watch(recipeRepositoryProvider));
});


final canCookCountProvider = Provider<int>((ref) {
  return ref.watch(recipeProvider).canCookCount;
});


final recommendationsProvider = Provider<List<Recipe>>((ref) {
  return ref.watch(recipeProvider).recommendations;
});
