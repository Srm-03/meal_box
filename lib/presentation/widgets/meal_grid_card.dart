import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:meal_box/core/constants/app_colour.dart';
import 'package:meal_box/domain/entitels/meal.dart';
import 'package:meal_box/presentation/widgets/favorite_button.dart';
import 'package:meal_box/presentation/widgets/shimmer_widget.dart';
import 'package:meal_box/presentation/widgets/tagchipcard.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MealGridCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final int index;

  const MealGridCard({
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
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: 'meal_image_${meal.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: meal.thumbnailUrl ?? '',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const ShimmerBox(
                          width: double.infinity,
                          height: double.infinity,
                          borderRadius: 0,
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.tagBg,
                          child: const Icon(
                            Icons.restaurant,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: FavoriteButton(
                        isFavorite: meal.isFavorite,
                        onTap: onFavoriteTap,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (meal.category != null) ...[
                    const SizedBox(height: 4),
                    TagChip(label: meal.category!),
                  ],
                ],
              ),
            ),
          ],
        ),
      )..animate().fadeIn(duration: 250.ms),
    );
  }
}
