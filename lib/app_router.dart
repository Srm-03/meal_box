import 'package:flutter/widgets.dart';
import 'package:meal_box/core/di/injection_container.dart';
import 'package:meal_box/spalsh/splash.dart';
import 'package:meal_box/spalsh/vediosplash.dart';
import 'package:meal_box/user_pref/userpref.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final isOnboarded = sl<UserPreferencesService>().isOnboarded;
    return isOnboarded ? const SplashPage() : const VideoSplashPage();
  }
}
