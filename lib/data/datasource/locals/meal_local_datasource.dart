import 'package:hive/hive.dart';
import 'package:meal_box/core/constants/app_constants.dart';
import 'package:meal_box/data/models/meal_model.dart';

abstract class MealLocalDataSource {
  // Favorites
  Future<List<MealModel>> getFavorites();
  Future<void> saveFavorite(MealModel meal);
  Future<void> removeFavorite(String mealId);
  Future<bool> isFavorite(String mealId);

  // Cache
  Future<void> cacheMeals(String key, List<MealModel> meals);
  Future<List<MealModel>?> getCachedMeals(String key);
  Future<void> cacheMealDetail(MealModel meal);
  Future<MealModel?> getCachedMealDetail(String id);
  Future<void> cacheCategories(List<MealCategoryModel> categories);
  Future<List<MealCategoryModel>?> getCachedCategories();
  Future<void> cacheAreasList(List<String> areas);

  Future<List<String>?> getCachedAreasList();
}

class MealLocalDataSourceImpl implements MealLocalDataSource {
  final Box<MealModel> favoritesBox;
  final Box<MealModel> mealsBox;
  final Box<MealCategoryModel> categoriesBox;
  final Box<dynamic> settingsBox;

  MealLocalDataSourceImpl({
    required this.favoritesBox,
    required this.mealsBox,
    required this.categoriesBox,
    required this.settingsBox,
  });

  // ── Favorites ─────────────────────────────────────────────────────────────

  @override
  Future<List<MealModel>> getFavorites() async {
    return favoritesBox.values.toList();
  }

  @override
  Future<void> saveFavorite(MealModel meal) async {
    await favoritesBox.put(meal.id, meal);
  }

  @override
  Future<void> removeFavorite(String mealId) async {
    await favoritesBox.delete(mealId);
  }

  @override
  Future<bool> isFavorite(String mealId) async {
    return favoritesBox.containsKey(mealId);
  }

  // ── Cache ──────────────────────────────────────────────────────────────────
  @override
  Future<void> cacheAreasList(List<String> areas) async {
    await settingsBox.put('cached_areas', areas);
  }

  @override
  Future<List<String>?> getCachedAreasList() async {
    final cached = settingsBox.get('cached_areas');

    if (cached is List) {
      return cached.cast<String>();
    }

    return null;
  }

  @override
  Future<void> cacheMeals(String key, List<MealModel> meals) async {
    for (final meal in meals) {
      await mealsBox.put('${key}_${meal.id}', meal);
    }
    await settingsBox.put(
      'cache_time_$key',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<MealModel>?> getCachedMeals(String key) async {
    final cacheTime = settingsBox.get('cache_time_$key') as int?;
    if (cacheTime == null) return null;

    final age = DateTime.now().millisecondsSinceEpoch - cacheTime;
    final maxAge = AppConstants.cacheDurationHours * 3600 * 1000;
    if (age > maxAge) return null; // stale

    final prefix = '${key}_';
    final meals = mealsBox.keys
        .where((k) => k.toString().startsWith(prefix))
        .map((k) => mealsBox.get(k))
        .whereType<MealModel>()
        .toList();

    return meals.isEmpty ? null : meals;
  }

  @override
  Future<void> cacheMealDetail(MealModel meal) async {
    await mealsBox.put('detail_${meal.id}', meal);
  }

  @override
  Future<MealModel?> getCachedMealDetail(String id) async {
    return mealsBox.get('detail_$id');
  }

  @override
  Future<void> cacheCategories(List<MealCategoryModel> categories) async {
    for (final cat in categories) {
      await categoriesBox.put(cat.id, cat);
    }
    await settingsBox.put(
      'cache_time_categories',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<MealCategoryModel>?> getCachedCategories() async {
    final cacheTime = settingsBox.get('cache_time_categories') as int?;
    if (cacheTime == null) return null;

    final age = DateTime.now().millisecondsSinceEpoch - cacheTime;
    final maxAge = AppConstants.cacheDurationHours * 3600 * 1000;
    if (age > maxAge) return null;

    final cats = categoriesBox.values.toList();
    return cats.isEmpty ? null : cats;
  }
}
