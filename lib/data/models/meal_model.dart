import 'package:hive/hive.dart';
import 'package:meal_box/domain/entitels/meal.dart';

@HiveType(typeId: 0)
class MealModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? category;
  @HiveField(3)
  final String? area;
  @HiveField(4)
  final String? instructions;
  @HiveField(5)
  final String? thumbnailUrl;
  @HiveField(6)
  final String? youtubeUrl;
  @HiveField(7)
  final List<String> ingredientNames;
  @HiveField(8)
  final List<String> ingredientMeasures;
  @HiveField(9)
  final String? tags;
  @HiveField(10)
  final bool isFavorite;

  MealModel({
    required this.id,
    required this.name,
    this.category,
    this.area,
    this.instructions,
    this.thumbnailUrl,
    this.youtubeUrl,
    this.ingredientNames = const [],
    this.ingredientMeasures = const [],
    this.tags,
    this.isFavorite = false,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    final ingredientNames = <String>[];
    final ingredientMeasures = <String>[];

    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'] as String?;
      final measure = json['strMeasure$i'] as String?;
      if (ingredient != null && ingredient.trim().isNotEmpty) {
        ingredientNames.add(ingredient.trim());
        ingredientMeasures.add(measure?.trim() ?? '');
      }
    }

    return MealModel(
      id: json['idMeal'] as String,
      name: json['strMeal'] as String,
      category: json['strCategory'] as String?,
      area: json['strArea'] as String?,
      instructions: json['strInstructions'] as String?,
      thumbnailUrl: json['strMealThumb'] as String?,
      youtubeUrl: json['strYoutube'] as String?,
      ingredientNames: ingredientNames,
      ingredientMeasures: ingredientMeasures,
      tags: json['strTags'] as String?,
    );
  }

  /// Light model from filter/search lists (no ingredients)
  factory MealModel.fromListJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['idMeal'] as String,
      name: json['strMeal'] as String,
      thumbnailUrl: json['strMealThumb'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'idMeal': id,
    'strMeal': name,
    'strCategory': category,
    'strArea': area,
    'strInstructions': instructions,
    'strMealThumb': thumbnailUrl,
    'strYoutube': youtubeUrl,
    'strTags': tags,
    'strIngredient1': ingredientNames.isNotEmpty ? ingredientNames[0] : null,
    'strMeasure1': ingredientMeasures.isNotEmpty ? ingredientMeasures[0] : null,
  };

  Meal toEntity({bool? favoriteOverride}) {
    final ingredients = List.generate(
      ingredientNames.length,
      (i) => MealIngredient(
        name: ingredientNames[i],
        measure: i < ingredientMeasures.length ? ingredientMeasures[i] : '',
      ),
    );
    return Meal(
      id: id,
      name: name,
      category: category,
      area: area,
      instructions: instructions,
      thumbnailUrl: thumbnailUrl,
      youtubeUrl: youtubeUrl,
      ingredients: ingredients,
      tags: tags,
      isFavorite: favoriteOverride ?? isFavorite,
    );
  }

  static MealModel fromEntity(Meal meal) => MealModel(
    id: meal.id,
    name: meal.name,
    category: meal.category,
    area: meal.area,
    instructions: meal.instructions,
    thumbnailUrl: meal.thumbnailUrl,
    youtubeUrl: meal.youtubeUrl,
    ingredientNames: meal.ingredients.map((e) => e.name).toList(),
    ingredientMeasures: meal.ingredients.map((e) => e.measure).toList(),
    tags: meal.tags,
    isFavorite: meal.isFavorite,
  );
}

@HiveType(typeId: 1)
class MealCategoryModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? thumbnailUrl;
  @HiveField(3)
  final String? description;

  MealCategoryModel({
    required this.id,
    required this.name,
    this.thumbnailUrl,
    this.description,
  });

  factory MealCategoryModel.fromJson(Map<String, dynamic> json) =>
      MealCategoryModel(
        id: json['idCategory'] as String,
        name: json['strCategory'] as String,
        thumbnailUrl: json['strCategoryThumb'] as String?,
        description: json['strCategoryDescription'] as String?,
      );

  MealCategory toEntity() => MealCategory(
    id: id,
    name: name,
    thumbnailUrl: thumbnailUrl,
    description: description,
  );
}
