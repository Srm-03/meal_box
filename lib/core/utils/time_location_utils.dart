import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meal_box/core/constants/app_constants.dart';

enum MealTime { breakfast, lunch, dinner, snack }

class TimeUtils {
  TimeUtils._();

  static MealTime currentMealTime() {
    final hour = DateTime.now().hour;
    if (hour >= AppConstants.breakfastStartHour &&
        hour < AppConstants.breakfastEndHour) {
      return MealTime.breakfast;
    } else if (hour >= AppConstants.lunchStartHour &&
        hour < AppConstants.lunchEndHour) {
      return MealTime.lunch;
    } else if (hour >= AppConstants.dinnerStartHour) {
      return MealTime.dinner;
    }
    return MealTime.snack;
  }

  static int notificationId(MealTime time) {
    switch (time) {
      case MealTime.breakfast:
        return AppConstants.breakfastNotificationId;
      case MealTime.lunch:
        return AppConstants.lunchNotificationId;
      case MealTime.dinner:
        return AppConstants.dinnerNotificationId;
      case MealTime.snack:
        return AppConstants
            .breakfastNotificationId; // snack has no dedicated slot, reuse or add one
    }
  }

  static int notificationHour(MealTime time) {
    switch (time) {
      case MealTime.breakfast:
        return AppConstants.breakfastNotifHour;
      case MealTime.lunch:
        return AppConstants.lunchNotifHour;
      case MealTime.dinner:
        return AppConstants.dinnerNotifHour;
      case MealTime.snack:
        return AppConstants.lunchNotifHour; // no snack hour defined, fallback
    }
  }

  static int notificationMinute(MealTime time) {
    return 0; // all notifications fire on the hour
  }

  static String mealTimeLabel(MealTime time) {
    switch (time) {
      case MealTime.breakfast:
        return 'Breakfast';
      case MealTime.lunch:
        return 'Lunch';
      case MealTime.dinner:
        return 'Dinner';
      case MealTime.snack:
        return 'Snack';
    }
  }

  static String mealTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning! 🌅';
    if (hour < 17) return 'Good Afternoon! ☀️';
    return 'Good Evening! 🌙';
  }

  static List<String> suggestedCategories(MealTime time) {
    switch (time) {
      case MealTime.breakfast:
        return AppConstants.mealTimeSuggestions['breakfast']!;
      case MealTime.lunch:
        return AppConstants.mealTimeSuggestions['lunch']!;
      case MealTime.dinner:
        return AppConstants.mealTimeSuggestions['dinner']!;
      case MealTime.snack:
        return AppConstants.mealTimeSuggestions['snack']!;
    }
  }

  static String mealTimeEmoji(MealTime time) {
    switch (time) {
      case MealTime.breakfast:
        return '🍳';
      case MealTime.lunch:
        return '🥗';
      case MealTime.dinner:
        return '🍽️';
      case MealTime.snack:
        return '🍰';
    }
  }
}

class LocationUtils {
  LocationUtils._();

  static Future<String?> getUserCountryCode() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          return null;
        }
      }
      if (permission == LocationPermission.deniedForever) return null;

      // final position = await Geolocator.getCurrentPosition(
      //   locationSettings: const LocationSettings(
      //     accuracy: LocationAccuracy.low,
      //     timeLimit: Duration(seconds: 10),
      //   ),
      // );

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(const Duration(seconds: 10));

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        return placemarks.first.isoCountryCode;
      }
    } catch (_) {
      // Silently return null — permission or service error
    }
    return null;
  }

  static String? cuisineForCountryCode(String? code) {
    if (code == null) return null;
    return AppConstants.countryToCuisine[code.toUpperCase()];
  }
}

class DeviceTimezone {
  static const _channel = MethodChannel('com.mealbox/timezone');

  static Future<String> getLocalTimezone() async {
    try {
      final String timezone = await _channel.invokeMethod('getTimezone');
      return timezone;
    } catch (_) {
      return 'UTC';
    }
  }
}
