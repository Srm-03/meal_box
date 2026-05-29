import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_box/domain/usecases/meal_usecases.dart';
import 'package:meal_box/presentation/bloc/meal_detail/meal_detail_event.dart';
import 'package:meal_box/presentation/bloc/meal_detail/meal_detail_state.dart';

class MealDetailBloc extends Bloc<MealDetailEvent, MealDetailState> {
  final GetMealDetail getMealDetail;
  final ToggleFavorite toggleFavorite;

  MealDetailBloc({required this.getMealDetail, required this.toggleFavorite})
    : super(MealDetailInitial()) {
    on<MealDetailRequested>(_onRequested);
    on<MealDetailFavoriteToggled>(_onFavoriteToggled);
  }

  Future<void> _onRequested(
    MealDetailRequested event,
    Emitter<MealDetailState> emit,
  ) async {
    emit(MealDetailLoading());
    final result = await getMealDetail(event.mealId);
    result.fold(
      (f) => emit(MealDetailError(f.message)),
      (meal) => emit(MealDetailSuccess(meal)),
    );
  }

  Future<void> _onFavoriteToggled(
    MealDetailFavoriteToggled event,
    Emitter<MealDetailState> emit,
  ) async {
    if (state is! MealDetailSuccess) return;
    final current = (state as MealDetailSuccess).meal;
    final result = await toggleFavorite(current);
    result.fold(
      (_) => null,
      (isFav) => emit(MealDetailSuccess(current.copyWith(isFavorite: isFav))),
    );
  }
}
