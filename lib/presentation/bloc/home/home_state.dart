import 'package:equatable/equatable.dart';
import 'package:meal_box/core/utils/time_location_utils.dart';
import 'package:meal_box/domain/entitels/meal.dart';

enum FilterTab { categories, regions }

class HomeState extends Equatable {
  final List<MealCategory> categories;
  final List<String> areas; // ← regions list from API
  final List<Meal> meals;
  final String selectedCategory; // used for both category & area chips
  final String? localCuisine; // detected from GPS
  final MealTime mealTime;
  final FilterTab activeFilterTab;
  final bool isLoadingCategories;
  final bool isLoadingAreas;
  final bool isLoadingMeals;
  final String? categoriesError;
  final String? mealsError;
  final bool isOffline;
  final bool isCachedData;

  const HomeState({
    this.categories = const [],
    this.areas = const [],
    this.meals = const [],
    this.selectedCategory = '',
    this.localCuisine,
    this.mealTime = MealTime.lunch,
    this.activeFilterTab = FilterTab.categories,
    this.isLoadingCategories = false,
    this.isLoadingAreas = false,
    this.isLoadingMeals = false,
    this.categoriesError,
    this.mealsError,
    this.isOffline = false,
    this.isCachedData = false,
  });

  HomeState copyWith({
    List<MealCategory>? categories,
    List<String>? areas,
    List<Meal>? meals,
    String? selectedCategory,
    String? localCuisine,
    MealTime? mealTime,
    FilterTab? activeFilterTab,
    bool? isLoadingCategories,
    bool? isLoadingAreas,
    bool? isLoadingMeals,
    String? categoriesError,
    String? mealsError,
    bool? isOffline,
    bool? isCachedData,
    bool clearCategoriesError = false,
    bool clearMealsError = false,
  }) {
    return HomeState(
      categories: categories ?? this.categories,
      areas: areas ?? this.areas,
      meals: meals ?? this.meals,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      localCuisine: localCuisine ?? this.localCuisine,
      mealTime: mealTime ?? this.mealTime,
      activeFilterTab: activeFilterTab ?? this.activeFilterTab,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      isLoadingAreas: isLoadingAreas ?? this.isLoadingAreas,
      isLoadingMeals: isLoadingMeals ?? this.isLoadingMeals,
      categoriesError: clearCategoriesError
          ? null
          : (categoriesError ?? this.categoriesError),
      mealsError: clearMealsError ? null : (mealsError ?? this.mealsError),
      isOffline: isOffline ?? this.isOffline,
      isCachedData: isCachedData ?? this.isCachedData,
    );
  }

  @override
  List<Object?> get props => [
    categories,
    areas,
    meals,
    selectedCategory,
    localCuisine,
    mealTime,
    activeFilterTab,
    isLoadingCategories,
    isLoadingAreas,
    isLoadingMeals,
    categoriesError,
    mealsError,
    isOffline,
    isCachedData,
  ];
}
