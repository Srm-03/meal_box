import 'package:equatable/equatable.dart';

abstract class MealDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class MealDetailRequested extends MealDetailEvent {
  final String mealId;
  MealDetailRequested(this.mealId);
  @override
  List<Object?> get props => [mealId];
}

class MealDetailFavoriteToggled extends MealDetailEvent {}
