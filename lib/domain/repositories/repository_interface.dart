import 'package:dartz/dartz.dart';
import 'package:meal_box/core/error/error.dart';
import 'package:meal_box/domain/entitels/meal.dart';

abstract class MealRepository {
  Future<Either<Failure, List<Meal>>> searchMeals(String query);
  Future<Either<Failure, List<Meal>>> getMealsByCategory(String category);
  Future<Either<Failure, List<Meal>>> getMealsByArea(String area);
  Future<Either<Failure, Meal>> getMealDetail(String id);
  Future<Either<Failure, List<MealCategory>>> getCategories();
  Future<Either<Failure, Meal>> getRandomMeal();
  Future<Either<Failure, List<String>>> getAreas();

  // Favorites (always local)
  Future<Either<Failure, List<Meal>>> getFavorites();
  Future<Either<Failure, bool>> toggleFavorite(Meal meal);
  Future<Either<Failure, bool>> isFavorite(String mealId);
}
