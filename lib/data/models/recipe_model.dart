import 'package:json_annotation/json_annotation.dart';

part 'recipe_model.g.dart';

/// Recipe ingredient - the pivot table data
@JsonSerializable()
class RecipeIngredient {
  final int id;
  final String name;

  @JsonKey(name: 'quantity_needed')
  final double quantityNeeded;

  final String unit;

  @JsonKey(name: 'ingredient_id')
  final int? ingredientId;

  RecipeIngredient({
    required this.id,
    required this.name,
    required this.quantityNeeded,
    required this.unit,
    this.ingredientId,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) =>
      _$RecipeIngredientFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeIngredientToJson(this);

  /// Get formatted quantity with unit
  String get formattedQuantity =>
      '${quantityNeeded.toStringAsFixed(quantityNeeded.truncateToDouble() == quantityNeeded ? 0 : 1)} $unit';
}

/// Recipe model
@JsonSerializable()
class Recipe {
  final int id;

  @JsonKey(name: 'user_id')
  final int? userId;

  final String title;
  final String description;
  final String instructions;

  @JsonKey(name: 'cooking_time')
  final int cookingTime;

  final int? servings;
  final String? tools;
  final List<String>? categories;

  @JsonKey(name: 'image_url')
  final String? imageUrl;

  final List<RecipeIngredient>? ingredients;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  // Computed fields from API
  @JsonKey(name: 'match_percentage')
  final int? matchPercentage;

  @JsonKey(name: 'can_cook')
  final bool? canCook;

  @JsonKey(name: 'missing_count')
  final int? missingCount;

  @JsonKey(name: 'ingredient_count')
  final int? ingredientCount;

  Recipe({
    required this.id,
    this.userId,
    required this.title,
    required this.description,
    required this.instructions,
    required this.cookingTime,
    this.servings,
    this.tools,
    this.categories,
    this.imageUrl,
    this.ingredients,
    required this.createdAt,
    required this.updatedAt,
    this.matchPercentage,
    this.canCook,
    this.missingCount,
    this.ingredientCount,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeToJson(this);

  /// Get formatted cooking time
  String get formattedCookingTime => '$cookingTime menit';

  /// Get formatted servings
  String get formattedServings => servings != null ? '$servings porsi' : '-';

  /// Get actual ingredient count
  int get actualIngredientCount => ingredientCount ?? ingredients?.length ?? 0;

  /// Get instructions as list of steps
  List<String> get instructionSteps {
    return instructions
        .split('\n')
        .map((step) => step.trim())
        .where((step) => step.isNotEmpty)
        .toList();
  }

  /// Check if all ingredients are available
  bool get isReadyToCook => canCook ?? false;

  Recipe copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    String? instructions,
    int? cookingTime,
    int? servings,
    String? tools,
    List<String>? categories,
    String? imageUrl,
    List<RecipeIngredient>? ingredients,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? matchPercentage,
    bool? canCook,
    int? missingCount,
    int? ingredientCount,
  }) {
    return Recipe(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      cookingTime: cookingTime ?? this.cookingTime,
      servings: servings ?? this.servings,
      tools: tools ?? this.tools,
      categories: categories ?? this.categories,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      matchPercentage: matchPercentage ?? this.matchPercentage,
      canCook: canCook ?? this.canCook,
      missingCount: missingCount ?? this.missingCount,
      ingredientCount: ingredientCount ?? this.ingredientCount,
    );
  }
}

/// Recipe categories
class RecipeCategories {
  static const List<String> all = [
    'appetizer',
    'main course',
    'side dishes',
    'dessert',
    'beverages',
    'breakfast menu',
    'brunch menu',
    'lunch menu',
    'dinner menu',
    'supper menu',
    'tea time menu',
  ];

  static const Map<String, String> displayNames = {
    'appetizer': 'Appetizer',
    'main course': 'Main Course',
    'side dishes': 'Side Dishes',
    'dessert': 'Dessert',
    'beverages': 'Beverages',
    'breakfast menu': 'Breakfast Menu',
    'brunch menu': 'Brunch Menu',
    'lunch menu': 'Lunch Menu',
    'dinner menu': 'Dinner Menu',
    'supper menu': 'Supper Menu',
    'tea time menu': 'Tea Time Menu',
  };
}
