import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_box/domain/usecases/meal_usecases.dart';
import 'package:meal_box/presentation/bloc/favorites/favorites_event.dart';
import 'package:meal_box/presentation/bloc/favorites/favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavorites getFavorites;
  final ToggleFavorite toggleFavorite;

  FavoritesBloc({required this.getFavorites, required this.toggleFavorite})
    : super(FavoritesInitial()) {
    on<FavoritesLoaded>(_onLoaded);
    on<FavoritesToggled>(_onToggled);
  }

  Future<void> _onLoaded(
    FavoritesLoaded event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
    final result = await getFavorites();
    result.fold(
      (f) => emit(FavoritesError(f.message)),
      (meals) => emit(FavoritesSuccess(meals)),
    );
  }

  Future<void> _onToggled(
    FavoritesToggled event,
    Emitter<FavoritesState> emit,
  ) async {
    final result = await toggleFavorite(event.meal);
    result.fold((_) => null, (_) => add(FavoritesLoaded()));
  }
}
