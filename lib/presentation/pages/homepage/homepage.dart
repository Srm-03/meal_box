import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_box/core/constants/app_colour.dart';
import 'package:meal_box/domain/entitels/meal.dart';
import 'package:meal_box/presentation/bloc/favorites/favorites_bloc.dart';
import 'package:meal_box/presentation/bloc/favorites/favorites_event.dart';
import 'package:meal_box/presentation/bloc/home/home_bloc.dart';
import 'package:meal_box/presentation/bloc/home/home_event.dart';
import 'package:meal_box/presentation/bloc/home/home_state.dart';
import 'package:meal_box/presentation/pages/homepage/widget/filterchip.dart';
import 'package:meal_box/presentation/pages/homepage/widget/filtertab.dart';
import 'package:meal_box/presentation/pages/homepage/widget/greetingheader.dart';
import 'package:meal_box/presentation/pages/homepage/widget/region.dart';
import 'package:meal_box/presentation/pages/meal_detail_page.dart';
import 'package:meal_box/presentation/widgets/emptystatewidget.dart';
import 'package:meal_box/presentation/widgets/meal_grid_card.dart';
import 'package:meal_box/presentation/widgets/mealgrid_shimmer.dart';
import 'package:meal_box/presentation/widgets/nointernet.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => context.read<HomeBloc>().add(HomeRefreshed()),
          child: CustomScrollView(
            slivers: [
              // ── Greeting header ──────────────────────────────────────────
              SliverToBoxAdapter(child: GreetingHeader(state: state)),

              // ── Cuisine / Region horizontal strip ────────────────────────
              SliverToBoxAdapter(child: RegionStrip(state: state)),

              // ── Filter tabs: Categories | Regions ────────────────────────
              SliverToBoxAdapter(child: FilterTabs(state: state)),

              // ── Chips row (changes based on active tab) ───────────────────
              SliverToBoxAdapter(child: FilterChipsRow(state: state)),

              // ── Meals grid ───────────────────────────────────────────────
              if (state.isLoadingMeals)
                const SliverToBoxAdapter(child: MealGridShimmer())
              else if (state.mealsError != null && state.meals.isEmpty)
                SliverFillRemaining(
                  child: state.isOffline
                      ? NoInternetWidget(
                          onRetry: () =>
                              context.read<HomeBloc>().add(HomeRefreshed()),
                        )
                      : const CircularProgressIndicator(),
                )
              else if (state.meals.isEmpty && !state.isLoadingMeals)
                const SliverFillRemaining(
                  child: EmptyStateWidget(
                    title: 'No recipes found',
                    subtitle: 'Try another category or region.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, i) {
                      final meal = state.meals[i];
                      return MealGridCard(
                        // KEY is critical — forces rebuild when isFavorite changes
                        key: ValueKey('grid_${meal.id}_${meal.isFavorite}'),
                        meal: meal,
                        index: i,
                        onTap: () => _openDetail(context, meal),
                        onFavoriteTap: () async {
                          context.read<HomeBloc>().add(
                            HomeFavoriteToggled(meal),
                          );

                          await Future.delayed(
                            const Duration(milliseconds: 100),
                          );

                          context.read<FavoritesBloc>().add(FavoritesLoaded());
                        },
                      );
                    }, childCount: state.meals.length),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.76,
                        ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _openDetail(BuildContext context, Meal meal) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MealDetailPage(meal: meal)),
    );
  }
}
