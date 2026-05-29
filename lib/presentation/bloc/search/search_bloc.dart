// ── Bloc ──────────────────────────────────────────────────────────────────────
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_box/core/constants/app_constants.dart';
import 'package:meal_box/domain/usecases/meal_usecases.dart';
import 'package:meal_box/presentation/bloc/search/search_event.dart';
import 'package:meal_box/presentation/bloc/search/search_state.dart';
import 'package:rxdart/rxdart.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchMeals searchMeals;
  final ToggleFavorite toggleFavorite;

  SearchBloc({required this.searchMeals, required this.toggleFavorite})
    : super(SearchInitial()) {
    on<SearchQueryChanged>(
      _onQueryChanged,
      transformer: (events, mapper) => events
          .debounceTime(AppConstants.searchDebounce)
          .distinct()
          .switchMap(mapper),
    );
    on<SearchCleared>(_onCleared);
    on<SearchFavoriteToggled>(_onFavoriteToggled);
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }
    emit(SearchLoading());

    final result = await searchMeals(query);
    result.fold((f) => emit(SearchError(f.message)), (meals) {
      if (meals.isEmpty) {
        emit(SearchEmpty(query));
      } else {
        emit(SearchSuccess(meals: meals, query: query));
      }
    });
  }

  Future<void> _onCleared(
    SearchCleared event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchInitial());
  }

  Future<void> _onFavoriteToggled(
    SearchFavoriteToggled event,
    Emitter<SearchState> emit,
  ) async {
    if (state is! SearchSuccess) return;
    final current = state as SearchSuccess;

    final result = await toggleFavorite(event.meal);
    result.fold((_) => null, (isFav) {
      final updated = current.meals.map((m) {
        if (m.id == event.meal.id) return m.copyWith(isFavorite: isFav);
        return m;
      }).toList();
      emit(SearchSuccess(meals: updated, query: current.query));
    });
  }
}
