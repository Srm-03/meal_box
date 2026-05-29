import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:meal_box/core/di/injection_container.dart';
import 'package:meal_box/core/services/notification_service.dart';
import 'package:meal_box/presentation/pages/dashboardpage.dart';
import 'package:meal_box/spalsh/onboarding_page.dart';
import 'package:meal_box/user_pref/userpref.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _startSequence();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  Future<void> _startSequence() async {
    // Run permissions + minimum display time in parallel
    await Future.wait([
      _requestPermissions(),
      Future.delayed(const Duration(milliseconds: 2800)),
    ]);
    _navigate();
  }

  Future<void> _requestPermissions() async {
    // Location permission
    try {
      final locStatus = await Permission.locationWhenInUse.status;
      if (locStatus.isDenied) {
        await Permission.locationWhenInUse.request();
      }
    } catch (e) {
      log('Location permission error: $e', name: 'SplashPage');
    }

    // Notification permission
    try {
      final notifService = sl<NotificationService>();
      await notifService.requestPermission();
    } catch (e) {
      log('Notification permission error: $e', name: 'SplashPage');
    }
  }

  void _navigate() {
    if (!mounted) return;
    final prefs = sl<UserPreferencesService>();
    final route = prefs.isOnboarded
        ? MaterialPageRoute(builder: (_) => const DashboardPage())
        : MaterialPageRoute(builder: (_) => const OnboardingPage());

    Navigator.pushReplacement(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const Spacer(),

              // ── Lottie Animation ─────────────────────────────────────────────
              Lottie.asset(
                // Public food/cooking Lottie from LottieFiles (replace with
                // your local asset: Lottie.asset('assets/animations/splash.json'))
                'assets/animations/mealbox.json',
                controller: _lottieController,
                width: 280,
                height: 280,
                fit: BoxFit.contain,

                onLoaded: (composition) {
                  _lottieController
                    ..duration = composition.duration
                    ..repeat();
                },
                // Fallback when Lottie can't load (no network on first launch)
                errorBuilder: (_, __, ___) => const _FallbackSplashIcon(),
              ),

              const SizedBox(height: 24),

              // ── App name ─────────────────────────────────────────────────────
              const Text(
                'Recipe Discovery',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFF6B35),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Discover what to cook, wherever you are',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // ── Loading indicator ─────────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: _PulsingDots(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Fallback icon (shown if Lottie fails to load) ─────────────────────────────
class _FallbackSplashIcon extends StatelessWidget {
  const _FallbackSplashIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 280,
      alignment: Alignment.center,
      child: const Text('🍽️', style: TextStyle(fontSize: 100)),
    );
  }
}

// ── Animated loading dots ──────────────────────────────────────────────────────
class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 600 + i * 180),
      )..repeat(reverse: true),
    );

    _anims = _controllers
        .map(
          (c) => Tween<double>(
            begin: 0.3,
            end: 1.0,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)),
        )
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _anims[i],
          builder: (_, __) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF6B35).withValues(alpha: _anims[i].value),
            ),
          ),
        );
      }),
    );
  }
}
