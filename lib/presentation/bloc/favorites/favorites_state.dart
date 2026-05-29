import 'package:equatable/equatable.dart';
import 'package:meal_box/domain/entitels/meal.dart';

abstract class FavoritesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesSuccess extends FavoritesState {
  final List<Meal> meals;
  FavoritesSuccess(this.meals);
  @override
  List<Object?> get props => [meals];
}

class FavoritesError extends FavoritesState {
  final String message;
  FavoritesError(this.message);
  @override
  List<Object?> get props => [message];
}
