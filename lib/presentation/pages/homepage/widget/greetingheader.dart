import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:meal_box/core/constants/app_colour.dart';
import 'package:meal_box/core/di/injection_container.dart';
import 'package:meal_box/core/utils/time_location_utils.dart';
import 'package:meal_box/presentation/bloc/home/home_state.dart';
import 'package:meal_box/presentation/pages/homepage/widget/headerwaveclipper.dart';
import 'package:meal_box/user_pref/userpref.dart';

class GreetingHeader extends StatelessWidget {
  final HomeState state;
  const GreetingHeader({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final userName = sl<UserPreferencesService>().userName ?? 'Chef';

    final emoji = TimeUtils.mealTimeEmoji(state.mealTime);
    final greeting = TimeUtils.mealTimeGreeting();
    final mealLabel = TimeUtils.mealTimeLabel(state.mealTime);

    return Stack(
      children: [
        // ── Gradient background ──────────────────────────────────────
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF9A5C), Color(0xFFFFBD80)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: greeting text + avatar/cached badge ────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(emoji, style: const TextStyle(fontSize: 26)),
                            ],
                          )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: -0.05, end: 0),
                    ],
                  ),
                  const Spacer(),

                  // Avatar circle
                ],
              ),

              const SizedBox(height: 16),

              // ── Bottom row: meal-time chip + cached badge ───────────
              Row(
                children: [
                  // Meal-time chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.restaurant_menu_rounded,
                          color: Colors.white,
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$mealLabel ideas, just for you',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.isCachedData) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text(
                        '📦 Cached',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // ── Curved bottom clip ───────────────────────────────────────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ClipPath(
            clipper: HeaderWaveClipper(),
            child: Container(height: 28, color: AppColors.background),
          ),
        ),
      ],
    );
  }
}
