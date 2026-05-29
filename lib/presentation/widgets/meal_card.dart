import 'package:flutter/material.dart';
import 'package:meal_box/core/constants/app_colour.dart';
import 'package:meal_box/domain/entitels/meal.dart';
import 'package:meal_box/presentation/widgets/favorite_button.dart';
import 'package:meal_box/presentation/widgets/shimmer_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:meal_box/presentation/widgets/tagchipcard.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final int index;

  const MealCard({
    super.key,
    required this.meal,
    required this.onTap,
    required this.onFavoriteTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child:
          Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Hero image
                    Hero(
                      tag: 'meal_image_${meal.id}',
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          bottomLeft: Radius.circular(18),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: meal.thumbnailUrl ?? '',
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const ShimmerBox(
                            width: 110,
                            height: 110,
                            borderRadius: 0,
                          ),
                          errorWidget: (_, __, ___) => Container(
                            width: 110,
                            height: 110,
                            color: AppColors.tagBg,
                            child: const Icon(
                              Icons.restaurant,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: 'meal_name_${meal.id}',
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  meal.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (meal.category != null)
                              TagChip(label: meal.category!),
                            if (meal.area != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.place_outlined,
                                    size: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    meal.area!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    // Favorite button
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: FavoriteButton(
                        isFavorite: meal.isFavorite,
                        onTap: onFavoriteTap,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              )
              .animate(delay: Duration(milliseconds: index * 60))
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.15, end: 0, duration: 350.ms),
    );
  }
}
