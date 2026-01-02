import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/pantry_item_model.dart';
import '../../data/repositories/pantry_repository.dart';
import '../../core/network/api_exceptions.dart';


class PantryState {
  final bool isLoading;
  final List<PantryItem> items;
  final List<PantryItem> expiringSoon;
  final String? error;
  final String? selectedCategory;
  final String searchQuery;

  const PantryState({
    this.isLoading = false,
    this.items = const [],
    this.expiringSoon = const [],
    this.error,
    this.selectedCategory,
    this.searchQuery = '',
  });


  List<PantryItem> get filteredItems {
    return items.where((item) {
      // Category filter
      if (selectedCategory != null && selectedCategory != 'Semua') {
        if (item.ingredientCategory != selectedCategory) {
          return false;
        }
      }


      if (searchQuery.isNotEmpty) {
        return item.ingredientName.toLowerCase().contains(
          searchQuery.toLowerCase(),
        );
      }

      return true;
    }).toList();
  }


  int get itemCount => items.length;

  PantryState copyWith({
    bool? isLoading,
    List<PantryItem>? items,
    List<PantryItem>? expiringSoon,
    String? error,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return PantryState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      expiringSoon: expiringSoon ?? this.expiringSoon,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}


class PantryNotifier extends StateNotifier<PantryState> {
  final PantryRepository _pantryRepository;

  PantryNotifier(this._pantryRepository) : super(const PantryState());


  Future<void> loadPantryItems() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _pantryRepository.getPantryItems();
      state = state.copyWith(isLoading: false, items: items);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }


  Future<void> loadExpiringSoon() async {
    try {
      final items = await _pantryRepository.getExpiringSoon();
      state = state.copyWith(expiringSoon: items);
    } catch (_) {}
  }


  Future<bool> addItem({
    required int ingredientId,
    required double quantity,
    required String unit,
    double? price,
    DateTime? expiryDate,
  }) async {
    try {
      final newItem = await _pantryRepository.addPantryItem(
        ingredientId: ingredientId,
        quantity: quantity,
        unit: unit,
        price: price,
        expiryDate: expiryDate,
      );
      state = state.copyWith(items: [...state.items, newItem]);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    }
  }


  Future<bool> deleteItem(int id) async {
    try {
      await _pantryRepository.deletePantryItem(id);
      state = state.copyWith(
        items: state.items.where((item) => item.id != id).toList(),
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    }
  }


  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }


  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> refresh() async {
    await Future.wait([loadPantryItems(), loadExpiringSoon()]);
  }
}


final pantryProvider = StateNotifierProvider<PantryNotifier, PantryState>((
  ref,
) {
  return PantryNotifier(ref.watch(pantryRepositoryProvider));
});

final pantryCountProvider = Provider<int>((ref) {
  return ref.watch(pantryProvider).itemCount;
});


final expiringSoonProvider = Provider<List<PantryItem>>((ref) {
  return ref.watch(pantryProvider).expiringSoon;
});
