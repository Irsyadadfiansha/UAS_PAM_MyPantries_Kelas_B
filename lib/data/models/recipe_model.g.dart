// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeIngredient _$RecipeIngredientFromJson(Map<String, dynamic> json) =>
    RecipeIngredient(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      quantityNeeded: (json['quantity_needed'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? 'g',
      ingredientId: (json['ingredient_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RecipeIngredientToJson(RecipeIngredient instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'quantity_needed': instance.quantityNeeded,
      'unit': instance.unit,
      'ingredient_id': instance.ingredientId,
    };

Recipe _$RecipeFromJson(Map<String, dynamic> json) => Recipe(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num?)?.toInt(),
  title: json['title'] as String,
  description: json['description'] as String? ?? '',
  instructions: json['instructions'] as String? ?? '',
  cookingTime: (json['cooking_time'] as num?)?.toInt() ?? 0,
  servings: (json['servings'] as num?)?.toInt(),
  tools: json['tools'] as String?,
  categories: (json['categories'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  imageUrl: json['image_url'] as String?,
  ingredients: (json['ingredients'] as List<dynamic>?)
      ?.map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  matchPercentage: (json['match_percentage'] as num?)?.toInt(),
  canCook: json['can_cook'] as bool?,
  missingCount: (json['missing_count'] as num?)?.toInt(),
  ingredientCount: (json['ingredient_count'] as num?)?.toInt(),
);

Map<String, dynamic> _$RecipeToJson(Recipe instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'title': instance.title,
  'description': instance.description,
  'instructions': instance.instructions,
  'cooking_time': instance.cookingTime,
  'servings': instance.servings,
  'tools': instance.tools,
  'categories': instance.categories,
  'image_url': instance.imageUrl,
  'ingredients': instance.ingredients?.map((e) => e.toJson()).toList(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'match_percentage': instance.matchPercentage,
  'can_cook': instance.canCook,
  'missing_count': instance.missingCount,
  'ingredient_count': instance.ingredientCount,
};
