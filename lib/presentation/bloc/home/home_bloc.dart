import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_box/core/utils/time_location_utils.dart';
import 'package:meal_box/domain/entitels/meal.dart';
import 'package:meal_box/domain/usecases/meal_usecases.dart';
import 'package:meal_box/presentation/bloc/home/home_event.dart';
import 'package:meal_box/presentation/bloc/home/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetCategories getCategories;
  final GetMealsByCategory getMealsByCategory;
  final GetMealsByArea getMealsByArea;
  final GetAreas getAreas;
  final ToggleFavorite toggleFavorite;

  HomeBloc({
    required this.getCategories,
    required this.getMealsByCategory,
    required this.getMealsByArea,
    required this.getAreas,
    required this.toggleFavorite,
  }) : super(const HomeState()) {
    on<HomeInitialized>(_onInitialized);
    on<HomeCategorySelected>(_onCategorySelected);
    on<HomeAreaSelected>(_onAreaSelected);
    on<HomeRefreshed>(_onRefreshed);
    on<HomeFavoriteToggled>(_onFavoriteToggled);
  }

  Future<void> _onInitialized(
    HomeInitialized event,
    Emitter<HomeState> emit,
  ) async {
    final mealTime = TimeUtils.currentMealTime();

    // Location runs concurrently — doesn't block UI
    final countryCode = await LocationUtils.getUserCountryCode();
    final localCuisine = LocationUtils.cuisineForCountryCode(countryCode);

    emit(
      state.copyWith(
        mealTime: mealTime,
        localCuisine: localCuisine,
        isLoadingCategories: true,
        isLoadingAreas: true,
      ),
    );

    // Fetch categories AND areas in parallel
    final results = await Future.wait([getCategories(), getAreas()]);

    final catResult = results[0] as dynamic;
    final areasResult = results[1] as dynamic;

    // Handle categories
    String initialCat = '';
    List<MealCategory> cats = [];
    catResult.fold(
      (f) => emit(
        state.copyWith(isLoadingCategories: false, categoriesError: f.message),
      ),
      (c) {
        cats = c as List<MealCategory>;
        final suggestions = TimeUtils.suggestedCategories(mealTime);
        initialCat =
            cats
                .map((cat) => cat.name)
                .where((n) => suggestions.contains(n))
                .firstOrNull ??
            cats.first.name;
      },
    );

    // Handle areas
    List<String> areaList = [];
    areasResult.fold((_) => null, (a) => areaList = a as List<String>);

    if (cats.isNotEmpty) {
      emit(
        state.copyWith(
          categories: cats,
          areas: areaList,
          isLoadingCategories: false,
          isLoadingAreas: false,
          selectedCategory: initialCat,
          clearCategoriesError: true,
        ),
      );
      add(HomeCategorySelected(initialCat));
    } else {
      emit(state.copyWith(areas: areaList, isLoadingAreas: false));
    }
  }

  Future<void> _onCategorySelected(
    HomeCategorySelected event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedCategory: event.category,
        activeFilterTab: FilterTab.categories,
        isLoadingMeals: true,
        clearMealsError: true,
      ),
    );

    final result = await getMealsByCategory(event.category);
    result.fold(
      (f) => emit(
        state.copyWith(
          isLoadingMeals: false,
          mealsError: f.message,
          isOffline: f.runtimeType.toString().contains('Network'),
        ),
      ),
      (meals) => emit(
        state.copyWith(meals: meals, isLoadingMeals: false, isOffline: false),
      ),
    );
  }

  Future<void> _onAreaSelected(
    HomeAreaSelected event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedCategory: event.area,
        activeFilterTab: FilterTab.regions,
        isLoadingMeals: true,
        clearMealsError: true,
      ),
    );

    final result = await getMealsByArea(event.area);
    result.fold(
      (f) => emit(
        state.copyWith(
          isLoadingMeals: false,
          mealsError: f.message,
          isOffline: f.runtimeType.toString().contains('Network'),
        ),
      ),
      (meals) => emit(
        state.copyWith(meals: meals, isLoadingMeals: false, isOffline: false),
      ),
    );
  }
  

  Future<void> _onRefreshed(
    HomeRefreshed event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeState());
    add(HomeInitialized());
  }

  Future<void> _onFavoriteToggled(
    HomeFavoriteToggled event,
    Emitter<HomeState> emit,
  ) async {
    final currentMeals = List<Meal>.from(state.meals);

    // Optimistic update
    final optimisticMeals = currentMeals.map((m) {
      if (m.id == event.meal.id) {
        return m.copyWith(isFavorite: !m.isFavorite);
      }
      return m;
    }).toList();

    emit(state.copyWith(meals: optimisticMeals));

    // Save to Hive
    final result = await toggleFavorite(event.meal);

    result.fold(
      // Revert on failure
      (_) {
        emit(state.copyWith(meals: currentMeals));
      },

      // Confirm actual DB value
      (isFav) {
        final confirmedMeals = optimisticMeals.map((m) {
          if (m.id == event.meal.id) {
            return m.copyWith(isFavorite: isFav);
          }
          return m;
        }).toList();

        emit(state.copyWith(meals: confirmedMeals));
      },
    );
  }
}
