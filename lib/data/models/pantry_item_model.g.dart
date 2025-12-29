// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pantry_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PantryItem _$PantryItemFromJson(Map<String, dynamic> json) => PantryItem(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num?)?.toInt(),
  ingredientId:
      (json['ingredient_id'] as num?)?.toInt() ??
      json['ingredient']?['id'] as int?,
  ingredient: json['ingredient'] == null
      ? null
      : Ingredient.fromJson(json['ingredient'] as Map<String, dynamic>),
  quantity: (json['quantity'] as num).toDouble(),
  unit: json['unit'] as String,
  price: (json['price'] as num?)?.toDouble(),
  pricePer100g: (json['price_per_100g'] as num?)?.toDouble(),
  expiryDate: json['expiry_date'] == null
      ? null
      : DateTime.parse(json['expiry_date'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  priceTrend: json['price_trend'] as String?,
  isExpiringSoonFromApi: json['is_expiring_soon'] as bool?,
  daysUntilExpiryFromApi: (json['days_until_expiry'] as num?)?.toInt(),
);

Map<String, dynamic> _$PantryItemToJson(PantryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'ingredient_id': instance.ingredientId,
      'ingredient': instance.ingredient?.toJson(),
      'quantity': instance.quantity,
      'unit': instance.unit,
      'price': instance.price,
      'price_per_100g': instance.pricePer100g,
      'expiry_date': instance.expiryDate?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'price_trend': instance.priceTrend,
      'is_expiring_soon': instance.isExpiringSoonFromApi,
      'days_until_expiry': instance.daysUntilExpiryFromApi,
    };
