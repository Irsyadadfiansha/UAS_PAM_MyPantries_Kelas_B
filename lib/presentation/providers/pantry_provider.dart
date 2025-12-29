import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/pantry_item_model.dart';
import '../../data/repositories/pantry_repository.dart';
import '../../core/network/api_exceptions.dart';

/// Pantry state
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

  /// Get filtered items based on search and category
  List<PantryItem> get filteredItems {
    return items.where((item) {
      // Category filter
      if (selectedCategory != null && selectedCategory != 'Semua') {
        if (item.ingredientCategory != selectedCategory) {
          return false;
        }
      }

      // Search filter
      if (searchQuery.isNotEmpty) {
        return item.ingredientName.toLowerCase().contains(
          searchQuery.toLowerCase(),
        );
      }

      return true;
    }).toList();
  }

  /// Get count of items
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

/// Pantry notifier
class PantryNotifier extends StateNotifier<PantryState> {
  final PantryRepository _pantryRepository;

  PantryNotifier(this._pantryRepository) : super(const PantryState());

  /// Load pantry items
  Future<void> loadPantryItems() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _pantryRepository.getPantryItems();
      state = state.copyWith(isLoading: false, items: items);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  /// Load expiring soon items
  Future<void> loadExpiringSoon() async {
    try {
      final items = await _pantryRepository.getExpiringSoon();
      state = state.copyWith(expiringSoon: items);
    } catch (_) {}
  }

  /// Add pantry item
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

  /// Delete pantry item
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

  /// Set category filter
  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh all
  Future<void> refresh() async {
    await Future.wait([loadPantryItems(), loadExpiringSoon()]);
  }
}

/// Provider for PantryNotifier
final pantryProvider = StateNotifierProvider<PantryNotifier, PantryState>((
  ref,
) {
  return PantryNotifier(ref.watch(pantryRepositoryProvider));
});

/// Provider for pantry item count
final pantryCountProvider = Provider<int>((ref) {
  return ref.watch(pantryProvider).itemCount;
});

/// Provider for expiring soon items
final expiringSoonProvider = Provider<List<PantryItem>>((ref) {
  return ref.watch(pantryProvider).expiringSoon;
});
