import 'package:dartz/dartz.dart';
import 'package:meal_box/core/error/error.dart';
import 'package:meal_box/domain/entitels/meal.dart';
import 'package:meal_box/domain/repositories/repository_interface.dart';

class SearchMeals {
  final MealRepository repository;
  SearchMeals(this.repository);

  Future<Either<Failure, List<Meal>>> call(String query) =>
      repository.searchMeals(query);
}

class GetMealsByCategory {
  final MealRepository repository;
  GetMealsByCategory(this.repository);

  Future<Either<Failure, List<Meal>>> call(String category) =>
      repository.getMealsByCategory(category);
}

class GetMealsByArea {
  final MealRepository repository;
  GetMealsByArea(this.repository);

  Future<Either<Failure, List<Meal>>> call(String area) =>
      repository.getMealsByArea(area);
}

class GetMealDetail {
  final MealRepository repository;
  GetMealDetail(this.repository);

  Future<Either<Failure, Meal>> call(String id) => repository.getMealDetail(id);
}

class GetCategories {
  final MealRepository repository;
  GetCategories(this.repository);

  Future<Either<Failure, List<MealCategory>>> call() =>
      repository.getCategories();
}

class GetRandomMeal {
  final MealRepository repository;
  GetRandomMeal(this.repository);

  Future<Either<Failure, Meal>> call() => repository.getRandomMeal();
}

class GetAreas {
  final MealRepository repository;

  GetAreas(this.repository);

  Future<Either<Failure, List<String>>> call() {
    return repository.getAreas();
  }
}

class ToggleFavorite {
  final MealRepository repository;
  ToggleFavorite(this.repository);

  Future<Either<Failure, bool>> call(Meal meal) =>
      repository.toggleFavorite(meal);
}

class GetFavorites {
  final MealRepository repository;
  GetFavorites(this.repository);

  Future<Either<Failure, List<Meal>>> call() => repository.getFavorites();
}

class IsFavorite {
  final MealRepository repository;
  IsFavorite(this.repository);

  Future<Either<Failure, bool>> call(String mealId) =>
      repository.isFavorite(mealId);
}
