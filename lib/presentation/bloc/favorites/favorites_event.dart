import 'package:equatable/equatable.dart';
import 'package:meal_box/domain/entitels/meal.dart';

abstract class FavoritesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FavoritesLoaded extends FavoritesEvent {}

class FavoritesToggled extends FavoritesEvent {
  final Meal meal;
  FavoritesToggled(this.meal);
  @override
  List<Object?> get props => [meal.id];
}


