import 'package:equatable/equatable.dart';

class Meal extends Equatable {
  final String id;
  final String name;
  final String? category;
  final String? area;
  final String? instructions;
  final String? thumbnailUrl;
  final String? youtubeUrl;
  final List<MealIngredient> ingredients;
  final String? tags;
  final bool isFavorite;

  const Meal({
    required this.id,
    required this.name,
    this.category,
    this.area,
    this.instructions,
    this.thumbnailUrl,
    this.youtubeUrl,
    this.ingredients = const [],
    this.tags,
    this.isFavorite = false,
  });

  Meal copyWith({
    String? id,
    String? name,
    String? category,
    String? area,
    String? instructions,
    String? thumbnailUrl,
    String? youtubeUrl,
    List<MealIngredient>? ingredients,
    String? tags,
    bool? isFavorite,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      area: area ?? this.area,
      instructions: instructions ?? this.instructions,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      ingredients: ingredients ?? this.ingredients,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [id, name, category, area, isFavorite];
}

class MealIngredient extends Equatable {
  final String name;
  final String measure;

  const MealIngredient({required this.name, required this.measure});

  @override
  List<Object?> get props => [name, measure];
}

class MealCategory extends Equatable {
  final String id;
  final String name;
  final String? thumbnailUrl;
  final String? description;

  const MealCategory({
    required this.id,
    required this.name,
    this.thumbnailUrl,
    this.description,
  });

  @override
  List<Object?> get props => [id, name];
}
