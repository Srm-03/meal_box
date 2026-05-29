class AppConstants {
  AppConstants._();

  // TheMealDB API
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const String searchEndpoint = '$baseUrl/search.php';
  static const String categoriesEndpoint = '$baseUrl/categories.php';
  static const String filterEndpoint = '$baseUrl/filter.php';
  static const String lookupEndpoint = '$baseUrl/lookup.php';
  static const String randomEndpoint = '$baseUrl/random.php';
  static const String areasListEndpoint = '$baseUrl/list.php';

  // Hive Box Names
  static const String favoritesBox = 'favorites_box';
  static const String mealsBox = 'meals_cache_box';
  static const String categoriesBox = 'categories_cache_box';
  static const String settingsBox = 'settings_box';

  // Notification IDs
  static const int breakfastNotificationId = 1001;
  static const int lunchNotificationId = 1002;
  static const int dinnerNotificationId = 1003;

  // Debounce Duration
  static const Duration searchDebounce = Duration(milliseconds: 450);

  // Cache Duration (hours before re-fetching)
  static const int cacheDurationHours = 6;

  // Meal Time Windows (24h)
  static const int breakfastStartHour = 5;
  static const int breakfastEndHour = 11;
  static const int lunchStartHour = 11;
  static const int lunchEndHour = 16;
  static const int dinnerStartHour = 16;
  static const int dinnerEndHour = 23;

  // Notification Schedule
  static const int breakfastNotifHour = 8;
  static const int lunchNotifHour = 12;
  static const int dinnerNotifHour = 19;

  // Location → Cuisine Mapping
  static const Map<String, String> countryToCuisine = {
    'IN': 'India',
    'IT': 'Italian',
    'CN': 'Chinese',
    'JP': 'Japanese',
    'MX': 'Mexican',
    'FR': 'French',
    'TH': 'Thai',
    'US': 'American',
    'GB': 'British',
    'GR': 'Greek',
    'ES': 'Spanish',
    'MA': 'Moroccan',
    'TR': 'Turkish',
    'VN': 'Vietnamese',
    'EG': 'Egyptian',
    'PH': 'Filipino',
    'RU': 'Russian',
    'CA': 'Canadian',
    'AU': 'Australian',
    'JM': 'Jamaican',
    'PL': 'Polish',
    'NL': 'Dutch',
    'HR': 'Croatian',
    'KE': 'Kenyan',
    'NG': 'Nigerian',
    'TN': 'Tunisian',
    'UA': 'Ukrainian',
  };

  // Time-based category suggestions
  static const Map<String, List<String>> mealTimeSuggestions = {
    'breakfast': ['Breakfast', 'Miscellaneous', 'Vegan', 'Vegetarian'],
    'lunch': ['Chicken', 'Beef', 'Seafood', 'Pasta', 'Pork'],
    'dinner': ['Lamb', 'Goat', 'Seafood', 'Beef', 'Side'],
    'snack': ['Dessert', 'Starter', 'Miscellaneous'],
  };
}
