import 'package:equatable/equatable.dart';
import 'package:meal_box/domain/entitels/meal.dart';

abstract class MealDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MealDetailInitial extends MealDetailState {}

class MealDetailLoading extends MealDetailState {}

class MealDetailSuccess extends MealDetailState {
  final Meal meal;
  MealDetailSuccess(this.meal);
  @override
  List<Object?> get props => [meal];
}

class MealDetailError extends MealDetailState {
  final String message;
  MealDetailError(this.message);
  @override
  List<Object?> get props => [message];
}
