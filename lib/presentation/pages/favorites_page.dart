import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_box/core/constants/app_colour.dart';
import 'package:meal_box/presentation/bloc/favorites/favorites_bloc.dart';
import 'package:meal_box/presentation/bloc/favorites/favorites_event.dart';
import 'package:meal_box/presentation/bloc/favorites/favorites_state.dart';
import 'package:meal_box/presentation/pages/meal_detail_page.dart';
import 'package:meal_box/presentation/widgets/emptystatewidget.dart';
import 'package:meal_box/presentation/widgets/meal_card.dart';
import 'package:meal_box/presentation/widgets/meal_card_shimmer.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<FavoritesBloc>().add(FavoritesLoaded());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Text(
                '❤️ My Favorites',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                'Available offline anytime',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
            Expanded(
              child: BlocConsumer<FavoritesBloc, FavoritesState>(
                listener: (context, state) {
                  if (state is FavoritesError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is FavoritesLoading) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 5,
                      itemBuilder: (_, __) => const MealCardShimmer(),
                    );
                  }

                  if (state is FavoritesSuccess) {
                    if (state.meals.isEmpty) {
                      return const EmptyStateWidget(
                        title: 'No Favorites Yet',
                        subtitle:
                            'Tap the ❤️ on any recipe to save it for offline viewing.',
                        icon: Icons.favorite_border_rounded,
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.meals.length,
                      itemBuilder: (context, i) {
                        final meal = state.meals[i];
                        return MealCard(
                          meal: meal,
                          index: i,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MealDetailPage(meal: meal),
                              ),
                            );
                          },
                          onFavoriteTap: () {
                            context.read<FavoritesBloc>().add(
                              FavoritesToggled(meal),
                            );
                          },
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
