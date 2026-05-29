import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meal_box/core/constants/app_constants.dart';
import 'package:meal_box/core/network/network_info.dart';
import 'package:meal_box/core/services/notification_service.dart';
import 'package:meal_box/data/datasource/locals/meal_local_datasource.dart';
import 'package:meal_box/data/datasource/remote/meal_remote_datasource.dart';
import 'package:meal_box/data/models/meal_model.dart';
import 'package:meal_box/data/models/meal_model.g.dart';
import 'package:meal_box/data/repository/meal_repository_impl.dart';
import 'package:meal_box/domain/repositories/repository_interface.dart';
import 'package:meal_box/domain/usecases/meal_usecases.dart';
import 'package:meal_box/user_pref/userpref.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── Hive ───────────────────────────────────────────────────────────────────
  await Hive.initFlutter();
  Hive.registerAdapter(MealModelAdapter());
  Hive.registerAdapter(MealCategoryModelAdapter());

  final favoritesBox = await Hive.openBox<MealModel>(AppConstants.favoritesBox);
  final mealsBox = await Hive.openBox<MealModel>(AppConstants.mealsBox);
  final categoriesBox = await Hive.openBox<MealCategoryModel>(
    AppConstants.categoriesBox,
  );
  final settingsBox = await Hive.openBox<dynamic>(AppConstants.settingsBox);

  sl.registerLazySingleton<UserPreferencesService>(
    () => UserPreferencesService(settingsBox),
  );

  // ── External ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (obj) => null, // silent in production
      ),
    );
    return dio;
  });

  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => NotificationService());
  sl.registerLazySingleton(() => GetAreas(sl()));

  // ── Core ───────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<Connectivity>()),
  );

  // ── Data ───────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<MealRemoteDataSource>(
    () => MealRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<MealLocalDataSource>(
    () => MealLocalDataSourceImpl(
      favoritesBox: favoritesBox,
      mealsBox: mealsBox,
      categoriesBox: categoriesBox,
      settingsBox: settingsBox,
    ),
  );

  sl.registerLazySingleton<MealRepository>(
    () => MealRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // ── Use Cases ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => SearchMeals(sl()));
  sl.registerLazySingleton(() => GetMealsByCategory(sl()));
  sl.registerLazySingleton(() => GetMealsByArea(sl()));
  sl.registerLazySingleton(() => GetMealDetail(sl()));
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => GetRandomMeal(sl()));
  sl.registerLazySingleton(() => ToggleFavorite(sl()));
  sl.registerLazySingleton(() => GetFavorites(sl()));
  sl.registerLazySingleton(() => IsFavorite(sl()));
}
