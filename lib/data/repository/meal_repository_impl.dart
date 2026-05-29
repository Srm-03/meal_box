import 'package:dartz/dartz.dart';
import 'package:meal_box/core/error/error.dart';
import 'package:meal_box/core/network/network_info.dart';
import 'package:meal_box/data/datasource/locals/meal_local_datasource.dart';
import 'package:meal_box/data/datasource/remote/meal_remote_datasource.dart';
import 'package:meal_box/data/models/meal_model.dart';
import 'package:meal_box/domain/entitels/meal.dart';
import 'package:meal_box/domain/repositories/repository_interface.dart';

class MealRepositoryImpl implements MealRepository {
  final MealRemoteDataSource remoteDataSource;
  final MealLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  MealRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Meal>>> searchMeals(String query) async {
    if (await networkInfo.isConnected) {
      try {
        final models = await remoteDataSource.searchMeals(query);
        final favIds = (await localDataSource.getFavorites())
            .map((f) => f.id)
            .toSet();
        return Right(
          models
              .map((m) => m.toEntity(favoriteOverride: favIds.contains(m.id)))
              .toList(),
        );
      } on Failure catch (f) {
        return Left(f);
      } catch (_) {
        return const Left(ServerFailure());
      }
    }
    return const Left(NetworkFailure());
  }
  @override
Future<Either<Failure, List<String>>> getAreas() async {
  if (await networkInfo.isConnected) {
    try {
      final areas = await remoteDataSource.getAreas();

      await localDataSource.cacheAreasList(areas);

      return Right(areas);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  final cached = await localDataSource.getCachedAreasList();

  if (cached != null) {
    return Right(cached);
  }

  return const Right([
    'Indian',
    'Italian',
    'Chinese',
    'Japanese',
  ]);
}

  @override
  Future<Either<Failure, List<Meal>>> getMealsByCategory(
    String category,
  ) async {
    final cacheKey = 'category_$category';

    if (await networkInfo.isConnected) {
      try {
        final models = await remoteDataSource.getMealsByCategory(category);
        await localDataSource.cacheMeals(cacheKey, models);
        final favIds = (await localDataSource.getFavorites())
            .map((f) => f.id)
            .toSet();
        return Right(
          models
              .map((m) => m.toEntity(favoriteOverride: favIds.contains(m.id)))
              .toList(),
        );
      } on Failure catch (f) {
        // Network failed — fall through to cache
        return await _tryCache(cacheKey, f);
      } catch (_) {
        return await _tryCache(cacheKey, const ServerFailure());
      }
    }

    // Offline path
    return await _tryCache(cacheKey, const NetworkFailure());
  }

  @override
  Future<Either<Failure, List<Meal>>> getMealsByArea(String area) async {
    final cacheKey = 'area_$area';

    if (await networkInfo.isConnected) {
      try {
        final models = await remoteDataSource.getMealsByArea(area);
        await localDataSource.cacheMeals(cacheKey, models);
        final favIds = (await localDataSource.getFavorites())
            .map((f) => f.id)
            .toSet();
        return Right(
          models
              .map((m) => m.toEntity(favoriteOverride: favIds.contains(m.id)))
              .toList(),
        );
      } on Failure catch (f) {
        return await _tryCache(cacheKey, f);
      } catch (_) {
        return await _tryCache(cacheKey, const ServerFailure());
      }
    }
    return await _tryCache(cacheKey, const NetworkFailure());
  }

  @override
  Future<Either<Failure, Meal>> getMealDetail(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final model = await remoteDataSource.getMealDetail(id);
        await localDataSource.cacheMealDetail(model);
        final fav = await localDataSource.isFavorite(id);
        return Right(model.toEntity(favoriteOverride: fav));
      } on Failure catch (f) {
        return await _tryCachedDetail(id, f);
      } catch (_) {
        return await _tryCachedDetail(id, const ServerFailure());
      }
    }
    return await _tryCachedDetail(id, const NetworkFailure());
  }

  @override
  Future<Either<Failure, List<MealCategory>>> getCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final models = await remoteDataSource.getCategories();
        await localDataSource.cacheCategories(models);
        return Right(models.map((m) => m.toEntity()).toList());
      } on Failure catch (f) {
        final cached = await localDataSource.getCachedCategories();
        if (cached != null) {
          return Right(cached.map((m) => m.toEntity()).toList());
        }
        return Left(f);
      } catch (_) {
        return const Left(ServerFailure());
      }
    }
    final cached = await localDataSource.getCachedCategories();
    if (cached != null) {
      return Right(cached.map((m) => m.toEntity()).toList());
    }
    return const Left(NetworkFailure());
  }

  @override
  Future<Either<Failure, Meal>> getRandomMeal() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final model = await remoteDataSource.getRandomMeal();
      final fav = await localDataSource.isFavorite(model.id);
      return Right(model.toEntity(favoriteOverride: fav));
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  // ── Favorites ──────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Meal>>> getFavorites() async {
    try {
      final models = await localDataSource.getFavorites();
      return Right(
        models.map((m) => m.toEntity(favoriteOverride: true)).toList(),
      );
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> toggleFavorite(Meal meal) async {
    try {
      final alreadyFav = await localDataSource.isFavorite(meal.id);
      if (alreadyFav) {
        await localDataSource.removeFavorite(meal.id);
        return const Right(false);
      } else {
        final model = MealModel.fromEntity(meal.copyWith(isFavorite: true));
        await localDataSource.saveFavorite(model);
        return const Right(true);
      }
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String mealId) async {
    try {
      final result = await localDataSource.isFavorite(mealId);
      return Right(result);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<Either<Failure, List<Meal>>> _tryCache(
    String key,
    Failure fallback,
  ) async {
    final cached = await localDataSource.getCachedMeals(key);
    if (cached != null && cached.isNotEmpty) {
      final favIds = (await localDataSource.getFavorites())
          .map((f) => f.id)
          .toSet();
      return Right(
        cached
            .map((m) => m.toEntity(favoriteOverride: favIds.contains(m.id)))
            .toList(),
      );
    }
    return Left(fallback);
  }

  Future<Either<Failure, Meal>> _tryCachedDetail(
    String id,
    Failure fallback,
  ) async {
    final cached = await localDataSource.getCachedMealDetail(id);
    if (cached != null) {
      final fav = await localDataSource.isFavorite(id);
      return Right(cached.toEntity(favoriteOverride: fav));
    }
    return Left(fallback);
  }
}
