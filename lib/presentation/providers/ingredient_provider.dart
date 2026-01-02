import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/ingredient_model.dart';
import '../../data/repositories/ingredient_repository.dart';
import '../../core/network/api_exceptions.dart';


class IngredientState {
  final bool isLoading;
  final List<Ingredient> ingredients;
  final String? error;

  const IngredientState({
    this.isLoading = false,
    this.ingredients = const [],
    this.error,
  });

  IngredientState copyWith({
    bool? isLoading,
    List<Ingredient>? ingredients,
    String? error,
  }) {
    return IngredientState(
      isLoading: isLoading ?? this.isLoading,
      ingredients: ingredients ?? this.ingredients,
      error: error,
    );
  }
}


class IngredientNotifier extends StateNotifier<IngredientState> {
  final IngredientRepository _ingredientRepository;

  IngredientNotifier(this._ingredientRepository)
    : super(const IngredientState());


  Future<void> loadIngredients() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final ingredients = await _ingredientRepository.getIngredients();
      state = state.copyWith(isLoading: false, ingredients: ingredients);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  
  List<Ingredient> searchIngredients(String query) {
    if (query.isEmpty) return state.ingredients;
    return state.ingredients
        .where((i) => i.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }


  List<Ingredient> getByCategory(String category) {
    return state.ingredients.where((i) => i.category == category).toList();
  }
}


final ingredientProvider =
    StateNotifierProvider<IngredientNotifier, IngredientState>((ref) {
      return IngredientNotifier(ref.watch(ingredientRepositoryProvider));
    });


final ingredientsListProvider = Provider<List<Ingredient>>((ref) {
  return ref.watch(ingredientProvider).ingredients;
});
