import 'package:equatable/equatable.dart';
import 'package:meal_box/domain/entitels/meal.dart';

abstract class SearchState extends Equatable {
  @override
  List<Object?> get props => [];
}
 
class SearchInitial extends SearchState {}
 
class SearchLoading extends SearchState {}
 
class SearchSuccess extends SearchState {
  final List<Meal> meals;
  final String query;
  SearchSuccess({required this.meals, required this.query});
  @override
  List<Object?> get props => [meals, query];
}
 
class SearchEmpty extends SearchState {
  final String query;
  SearchEmpty(this.query);
  @override
  List<Object?> get props => [query];
}
 
class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
  @override
  List<Object?> get props => [message];
}