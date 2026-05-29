import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_box/core/constants/app_colour.dart';
import 'package:meal_box/core/di/injection_container.dart';
import 'package:meal_box/domain/entitels/meal.dart';
import 'package:meal_box/domain/usecases/meal_usecases.dart';
import 'package:meal_box/presentation/bloc/favorites/favorites_bloc.dart';
import 'package:meal_box/presentation/bloc/favorites/favorites_event.dart';
import 'package:meal_box/presentation/bloc/meal_detail/meal_detail_bloc.dart';
import 'package:meal_box/presentation/bloc/meal_detail/meal_detail_event.dart';
import 'package:meal_box/presentation/bloc/meal_detail/meal_detail_state.dart';
import 'package:meal_box/presentation/widgets/favorite_button.dart';
import 'package:meal_box/presentation/widgets/shimmer_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class MealDetailPage extends StatelessWidget {
  final Meal meal; // lightweight meal from list

  const MealDetailPage({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MealDetailBloc(
        getMealDetail: sl<GetMealDetail>(),
        toggleFavorite: sl<ToggleFavorite>(),
      )..add(MealDetailRequested(meal.id)),
      child: _MealDetailView(previewMeal: meal),
    );
  }
}

class _MealDetailView extends StatelessWidget {
  final Meal previewMeal;
  const _MealDetailView({required this.previewMeal});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MealDetailBloc, MealDetailState>(
      builder: (context, state) {
        final currentMeal = state is MealDetailSuccess
            ? state.meal
            : previewMeal;
        final isLoading = state is MealDetailLoading;

        return SafeArea(
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: CustomScrollView(
              slivers: [
                // ── Hero Image App Bar ─────────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  leading: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: BlocBuilder<MealDetailBloc, MealDetailState>(
                        builder: (context, state) {
                          final meal = state is MealDetailSuccess
                              ? state.meal
                              : previewMeal;
                          return FavoriteButton(
                            isFavorite: meal.isFavorite,
                            onTap: () {
                              context.read<MealDetailBloc>().add(
                                MealDetailFavoriteToggled(),
                              );
                              // Also refresh favorites tab
                              context.read<FavoritesBloc>().add(
                                FavoritesLoaded(),
                              );
                            },
                            size: 26,
                          );
                        },
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Hero(
                      tag: 'meal_image_${previewMeal.id}',
                      child: CachedNetworkImage(
                        imageUrl: currentMeal.thumbnailUrl ?? '',
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppColors.tagBg,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.tagBg,
                          child: const Icon(
                            Icons.restaurant,
                            size: 80,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Content ────────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Hero(
                                tag: 'meal_name_${previewMeal.id}',
                                child: Material(
                                  color: Colors.transparent,
                                  child: Text(
                                    currentMeal.name,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Meta chips
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (currentMeal.category != null)
                                    _MetaChip(
                                      icon: Icons.category_outlined,
                                      label: currentMeal.category!,
                                    ),
                                  if (currentMeal.area != null)
                                    _MetaChip(
                                      icon: Icons.place_outlined,
                                      label: currentMeal.area!,
                                    ),
                                  if (currentMeal.tags != null)
                                    ...currentMeal.tags!
                                        .split(',')
                                        .take(3)
                                        .map(
                                          (t) => _MetaChip(
                                            icon: Icons.label_outline,
                                            label: t.trim(),
                                          ),
                                        ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const Divider(height: 32),

                        // ── Ingredients ────────────────────────────────────────
                        if (isLoading) ...[
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const ShimmerBox(width: 140, height: 22),
                                const SizedBox(height: 16),
                                ...List.generate(
                                  6,
                                  (_) => const Padding(
                                    padding: EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        ShimmerBox(width: 32, height: 32),
                                        SizedBox(width: 12),
                                        ShimmerBox(width: 180, height: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (currentMeal.ingredients.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ingredients',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                ...currentMeal.ingredients.map(
                                  (ing) => _IngredientRow(ingredient: ing),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 32),
                        ],

                        // ── Instructions ───────────────────────────────────────
                        if (currentMeal.instructions != null) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Instructions',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  currentMeal.instructions!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.7,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // ── YouTube CTA ────────────────────────────────────────
                        if (currentMeal.youtubeUrl != null &&
                            currentMeal.youtubeUrl!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _launchYouTube(
                                  context,
                                  currentMeal.youtubeUrl!,
                                ),
                                icon: const Icon(Icons.play_circle_outline),
                                label: const Text('Watch on YouTube'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF0000),
                                ),
                              ),
                            ),
                          ),
                        ] else
                          const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchYouTube(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open YouTube.')),
        );
      }
    }
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.tagBg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.tagText),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.tagText,
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final MealIngredient ingredient;
  const _IngredientRow({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.tagBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ingredient.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            ingredient.measure,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
