import 'package:json_annotation/json_annotation.dart';

part 'ingredient_model.g.dart';

/// Ingredient model
@JsonSerializable()
class Ingredient {
  final int id;
  final String name;
  final String category;

  @JsonKey(name: 'default_unit')
  final String? defaultUnit;

  Ingredient({
    required this.id,
    required this.name,
    required this.category,
    this.defaultUnit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) =>
      _$IngredientFromJson(json);
  Map<String, dynamic> toJson() => _$IngredientToJson(this);

  Ingredient copyWith({
    int? id,
    String? name,
    String? category,
    String? defaultUnit,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      defaultUnit: defaultUnit ?? this.defaultUnit,
    );
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ingredient && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Ingredient category list
class IngredientCategories {
  static const List<String> all = [
    'Protein',
    'Sayuran',
    'Susu',
    'Biji-Bijian',
    'Buah',
    'Bumbu & Saus',
    'Rempah',
    'Mineral',
  ];
}
