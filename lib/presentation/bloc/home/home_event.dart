import 'package:equatable/equatable.dart';
import 'package:meal_box/domain/entitels/meal.dart';

abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitialized extends HomeEvent {}

class HomeFavoriteSynced extends HomeEvent {}

class HomeCategorySelected extends HomeEvent {
  final String category;
  HomeCategorySelected(this.category);
  @override
  List<Object?> get props => [category];
}

class HomeAreaSelected extends HomeEvent {
  final String area;
  HomeAreaSelected(this.area);
  @override
  List<Object?> get props => [area];
}

class HomeRefreshed extends HomeEvent {}

class HomeFavoriteToggled extends HomeEvent {
  final Meal meal;
  HomeFavoriteToggled(this.meal);
  @override
  List<Object?> get props => [meal.id];
}
