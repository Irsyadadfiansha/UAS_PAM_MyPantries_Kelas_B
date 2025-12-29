// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ingredient _$IngredientFromJson(Map<String, dynamic> json) => Ingredient(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  category: json['category'] as String,
  defaultUnit: json['default_unit'] as String?,
);

Map<String, dynamic> _$IngredientToJson(Ingredient instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'default_unit': instance.defaultUnit,
    };
