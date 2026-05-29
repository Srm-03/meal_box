// ── Events ────────────────────────────────────────────────────────────────────
import 'package:equatable/equatable.dart';
import 'package:meal_box/domain/entitels/meal.dart';

abstract class SearchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  SearchQueryChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class SearchCleared extends SearchEvent {}

class SearchFavoriteToggled extends SearchEvent {
  final Meal meal;
  SearchFavoriteToggled(this.meal);
  @override
  List<Object?> get props => [meal.id];
}
 
// ── State ─────────────────────────────────────────────────────────────────────

 