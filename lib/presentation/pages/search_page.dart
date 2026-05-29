import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_box/core/constants/app_colour.dart';
import 'package:meal_box/domain/entitels/meal.dart';
import 'package:meal_box/presentation/bloc/favorites/favorites_bloc.dart';
import 'package:meal_box/presentation/bloc/favorites/favorites_event.dart';
import 'package:meal_box/presentation/bloc/search/search_bloc.dart';
import 'package:meal_box/presentation/bloc/search/search_event.dart';
import 'package:meal_box/presentation/bloc/search/search_state.dart';
import 'package:meal_box/presentation/pages/meal_detail_page.dart';
import 'package:meal_box/presentation/widgets/emptystatewidget.dart';
import 'package:meal_box/presentation/widgets/meal_card.dart';
import 'package:meal_box/presentation/widgets/meal_card_shimmer.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _SearchBar(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: (q) =>
                  context.read<SearchBloc>().add(SearchQueryChanged(q)),
              onClear: () {
                _controller.clear();
                context.read<SearchBloc>().add(SearchCleared());
              },
            ),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchInitial) {
                    return const _SearchHint();
                  }
                  if (state is SearchLoading) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: 6,
                      itemBuilder: (_, __) => const MealCardShimmer(),
                    );
                  }
                  if (state is SearchError) {
                    return EmptyStateWidget(
                      title: 'Search Failed',
                      subtitle: state.message,
                      icon: Icons.wifi_off_rounded,
                    );
                  }
                  if (state is SearchEmpty) {
                    return EmptyStateWidget(
                      title: 'No Results',
                      subtitle: 'No recipes found for "${state.query}".',
                    );
                  }
                  if (state is SearchSuccess) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                          child: Text(
                            '${state.meals.length} results for "${state.query}"',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: state.meals.length,
                            itemBuilder: (context, i) {
                              final meal = state.meals[i];
                              return MealCard(
                                meal: meal,
                                index: i,
                                onTap: () => _openDetail(context, meal),
                                onFavoriteTap: () async {
                                  context.read<SearchBloc>().add(
                                    SearchFavoriteToggled(meal),
                                  );

                                  await Future.delayed(
                                    const Duration(milliseconds: 100),
                                  );

                                  context.read<FavoritesBloc>().add(
                                    FavoritesLoaded(),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
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

  void _openDetail(BuildContext context, Meal meal) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MealDetailPage(meal: meal)),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search Recipes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'e.g. pasta, chicken, sushi...',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
              ),
              suffixIcon: ListenableBuilder(
                listenable: controller,
                builder: (_, __) => controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: onClear,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchHint extends StatelessWidget {
  const _SearchHint();

  static const _suggestions = [
    '🍝  Pasta',
    '🍗  Chicken',
    '🥩  Beef',
    '🍣  Sushi',
    '🥗  Salad',
    '🍰  Dessert',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Searches',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _suggestions.map((s) {
              return ActionChip(
                label: Text(s),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                onPressed: () {
                  final q = s.split('  ').last;
                  // Use the text controller from parent via context
                  context.read<SearchBloc>().add(SearchQueryChanged(q));
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
