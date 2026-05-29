import 'package:dio/dio.dart';
import 'package:meal_box/core/constants/app_constants.dart';
import 'package:meal_box/core/error/error.dart';
import 'package:meal_box/data/models/meal_model.dart';

abstract class MealRemoteDataSource {
  Future<List<MealModel>> searchMeals(String query);
  Future<List<MealModel>> getMealsByCategory(String category);
  Future<List<MealModel>> getMealsByArea(String area);
  Future<MealModel> getMealDetail(String id);
  Future<List<MealCategoryModel>> getCategories();
  Future<MealModel> getRandomMeal();
  Future<List<String>> getAreas();
  
}

class MealRemoteDataSourceImpl implements MealRemoteDataSource {
  final Dio dio;

  MealRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<MealModel>> searchMeals(String query) async {
    try {
      final response = await dio.get(
        AppConstants.searchEndpoint,
        queryParameters: {'s': query},
      );
      final data = response.data as Map<String, dynamic>;
      final meals = data['meals'] as List?;
      if (meals == null || meals.isEmpty) return [];
      return meals
          .cast<Map<String, dynamic>>()
          .map(MealModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<String>> getAreas() async {
    try {
      final response = await dio.get(
        AppConstants.areasListEndpoint,
        queryParameters: {'a': 'list'},
      );

      final data = response.data as Map<String, dynamic>;
      final meals = data['meals'] as List?;

      if (meals == null) return [];

      return meals
          .cast<Map<String, dynamic>>()
          .map((m) => m['strArea'] as String)
          .where((a) => a.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<MealModel>> getMealsByCategory(String category) async {
    try {
      final response = await dio.get(
        AppConstants.filterEndpoint,
        queryParameters: {'c': category},
      );
      final data = response.data as Map<String, dynamic>;
      final meals = data['meals'] as List?;
      if (meals == null || meals.isEmpty) return [];
      return meals
          .cast<Map<String, dynamic>>()
          .map(MealModel.fromListJson)
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<MealModel>> getMealsByArea(String area) async {
    try {
      final response = await dio.get(
        AppConstants.filterEndpoint,
        queryParameters: {'a': area},
      );
      final data = response.data as Map<String, dynamic>;
      final meals = data['meals'] as List?;
      if (meals == null || meals.isEmpty) return [];
      return meals
          .cast<Map<String, dynamic>>()
          .map(MealModel.fromListJson)
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<MealModel> getMealDetail(String id) async {
    try {
      final response = await dio.get(
        AppConstants.lookupEndpoint,
        queryParameters: {'i': id},
      );
      final data = response.data as Map<String, dynamic>;
      final meals = data['meals'] as List?;
      if (meals == null || meals.isEmpty) {
        throw const NotFoundFailure('Meal not found.');
      }
      return MealModel.fromJson(meals.first as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<MealCategoryModel>> getCategories() async {
    try {
      final response = await dio.get(AppConstants.categoriesEndpoint);
      final data = response.data as Map<String, dynamic>;
      final categories = data['categories'] as List?;
      if (categories == null) return [];
      return categories
          .cast<Map<String, dynamic>>()
          .map(MealCategoryModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<MealModel> getRandomMeal() async {
    try {
      final response = await dio.get(AppConstants.randomEndpoint);
      final data = response.data as Map<String, dynamic>;
      final meals = data['meals'] as List?;
      if (meals == null || meals.isEmpty) {
        throw const NotFoundFailure('No random meal found.');
      }
      return MealModel.fromJson(meals.first as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Failure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkFailure();
    }
    return ServerFailure(e.message ?? 'Server error.');
  }
}
