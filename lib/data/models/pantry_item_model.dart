import 'package:json_annotation/json_annotation.dart';
import 'ingredient_model.dart';

part 'pantry_item_model.g.dart';

@JsonSerializable()
class PantryItem {
  final int id;

  @JsonKey(name: 'user_id')
  final int? userId;

  @JsonKey(name: 'ingredient_id')
  final int? ingredientId;

  final Ingredient? ingredient;
  final double quantity;
  final String unit;
  final double? price;

  @JsonKey(name: 'price_per_100g')
  final double? pricePer100g;

  @JsonKey(name: 'expiry_date')
  final DateTime? expiryDate;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @JsonKey(name: 'price_trend')
  final String? priceTrend;

  @JsonKey(name: 'is_expiring_soon')
  final bool? isExpiringSoonFromApi;

  @JsonKey(name: 'days_until_expiry')
  final int? daysUntilExpiryFromApi;

  PantryItem({
    required this.id,
    this.userId,
    this.ingredientId,
    this.ingredient,
    required this.quantity,
    required this.unit,
    this.price,
    this.pricePer100g,
    this.expiryDate,
    required this.createdAt,
    required this.updatedAt,
    this.priceTrend,
    this.isExpiringSoonFromApi,
    this.daysUntilExpiryFromApi,
  });

  factory PantryItem.fromJson(Map<String, dynamic> json) =>
      _$PantryItemFromJson(json);
  Map<String, dynamic> toJson() => _$PantryItemToJson(this);

 
  bool get isExpiringSoon {
    if (isExpiringSoonFromApi != null) return isExpiringSoonFromApi!;
    if (expiryDate == null) return false;
    final daysUntil = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntil <= 7 && daysUntil >= 0;
  }


  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }


  int get daysUntilExpiry {
    if (daysUntilExpiryFromApi != null) return daysUntilExpiryFromApi!;
    if (expiryDate == null) return 0;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

 
  String get formattedQuantity =>
      '${quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 1)} $unit';

  
  String? get formattedPricePer100g {
    if (pricePer100g == null) return null;
    return 'Rp ${pricePer100g!.toStringAsFixed(0)}/100g';
  }

  
  String get ingredientName => ingredient?.name ?? 'Unknown';

  
  String get ingredientCategory => ingredient?.category ?? 'Unknown';

  PantryItem copyWith({
    int? id,
    int? userId,
    int? ingredientId,
    Ingredient? ingredient,
    double? quantity,
    String? unit,
    double? price,
    double? pricePer100g,
    DateTime? expiryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? priceTrend,
  }) {
    return PantryItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      ingredientId: ingredientId ?? this.ingredientId,
      ingredient: ingredient ?? this.ingredient,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      pricePer100g: pricePer100g ?? this.pricePer100g,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      priceTrend: priceTrend ?? this.priceTrend,
    );
  }
}


class PantryUnits {
  static const List<String> all = [
    'g',
    'kg',
    'ml',
    'L',
    'piece',
    'pcs',
    'cup',
    'tbsp',
    'tsp',
    'cloves',
  ];
}
