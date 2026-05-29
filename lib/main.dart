import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_box/app_router.dart';
import 'package:meal_box/core/constants/app_colour.dart';
import 'package:meal_box/core/di/injection_container.dart';
import 'package:meal_box/core/di/injection_container.dart' as di;
import 'package:meal_box/core/services/notification_service.dart';
import 'package:meal_box/domain/usecases/meal_usecases.dart';
import 'package:meal_box/presentation/bloc/favorites/favorites_bloc.dart';
import 'package:meal_box/presentation/bloc/home/home_bloc.dart';
import 'package:meal_box/presentation/bloc/home/home_state.dart';
import 'package:meal_box/presentation/bloc/search/search_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await di.initDependencies();

  // Initialize notifications
  final notifService = sl<NotificationService>();

  await notifService.initialize();

  // Request permission
  await notifService.requestPermission();

  //await notifService.testScheduledNotification();
  await notifService.scheduleAllMealNotifications(
    breakfastRecipeName: 'Pasta',
    lunchRecipeName: 'Rice',
    dinnerRecipeName: 'Pizza',
  );

  // await notifService.showImmediateNotification(
  //   id: 999,
  //   title: 'Test Notification',
  //   body: 'Notification is working',
  // );

  runApp(const RecipeDiscoveryApp());
}

class RecipeDiscoveryApp extends StatelessWidget {
  const RecipeDiscoveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (_) => HomeBloc(
            getCategories: sl<GetCategories>(),
            getMealsByCategory: sl<GetMealsByCategory>(),
            getMealsByArea: sl<GetMealsByArea>(),
            getAreas: sl<GetAreas>(),
            toggleFavorite: sl<ToggleFavorite>(),
          ),
        ),
        BlocProvider<SearchBloc>(
          create: (_) => SearchBloc(
            searchMeals: sl<SearchMeals>(),
            toggleFavorite: sl<ToggleFavorite>(),
          ),
        ),
        BlocProvider<FavoritesBloc>(
          create: (_) => FavoritesBloc(
            getFavorites: sl<GetFavorites>(),
            toggleFavorite: sl<ToggleFavorite>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Meal Box',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        // Always start at SplashPage; it decides routing
        home: const AppRouter(),
        builder: (context, child) => _ConnectivityListener(child: child!),
      ),
    );
  }
}

class _ConnectivityListener extends StatelessWidget {
  final Widget child;
  const _ConnectivityListener({required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (prev, curr) => prev.isOffline != curr.isOffline,
      listener: (context, state) {
        final msg = state.isOffline
            ? '📶 No internet — showing cached content'
            : '✅ Back online!';
        final color = state.isOffline
            ? Colors.red.shade700
            : Colors.green.shade700;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(msg, style: const TextStyle(color: Colors.white)),
              backgroundColor: color,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
      },
      child: child,
    );
  }
}
