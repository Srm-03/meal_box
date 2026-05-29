# Meal Box 🍱

Meal Box is a modern Flutter recipe discovery application that helps users explore meals based on categories, cuisine regions, and religion preferences. The app also supports offline favorites, local caching, and scheduled meal notifications.

---

# Features ✨

## Splash Experience

* Animated video splash screen on app startup.
* Smooth transition into onboarding flow.

## Onboarding

* User enters their name during first launch.
* Name is stored locally using local storage.
* Personalized greeting on home screen.

Example:

```text
Good Evening, Soumya 👋
```

---

# Home Screen 🏠

The home screen provides multiple ways to discover meals:

## Filter by Category

Users can browse meals by categories such as:

* Seafood
* Chicken
* Dessert
* Vegetarian
* Beef
* Pasta
* Breakfast

# Search Functionality 🔍

* Real-time recipe searching.
* Search meals by:

  * Meal name
  * Category
  * Cuisine area
  * Region

---

# Favorites ❤️

Users can:

* Save favorite meals locally.
* Access favorites without internet connection.
* Favorites are cached using local storage/database.

Offline support ensures users can still view saved meals anytime.

---

# Offline Cache 📦

Meal Box caches recipe data locally for improved performance and offline access.

Cached meals can still be viewed when:

* Internet is unavailable
* API is temporarily unreachable

---

# Daily Meal Notifications 🔔

The app automatically sends scheduled meal reminders:

| Meal      | Time     |
| --------- | -------- |
| Breakfast | 8:00 AM  |
| Lunch     | 12:00 PM |
| Dinner    | 7:00 PM  |

Notifications include:

* Meal reminder title
* Notification sound
* Custom notification icon

---

# Architecture 🏗️

The project follows Clean Architecture principles.

## Layers

### Presentation Layer

* Flutter UI
* Bloc State Management

### Domain Layer

* Business Logic
* Use Cases
* Repository Contracts

### Data Layer

* API Services
* Local Cache
* Repository Implementations

---

# State Management ⚡

The app uses:

* flutter_bloc
* Bloc Pattern

Benefits:

* Predictable state management
* Scalable architecture
* Separation of concerns

---

# Local Storage 💾

Used technologies:

* SharedPreferences
* Local caching system

Stores:

* User name
* Favorites
* Cached meals

---

# API Integration 🌐

The app integrates with a public recipe API for:

* Meal categories
* Meal details
* Cuisine regions
* Search functionality

---

# CI/CD Pipeline 🚀

GitHub Actions is configured for automatic CI/CD.

Pipeline automatically:

1. Runs `flutter analyze`
2. Runs `flutter test`
3. Builds Release APK
4. Uploads APK to GitHub Releases

---

# How to Trigger CI/CD

Push code to the `main` branch:

```bash
git add .
git commit -m "Updated project"
git push origin main
```

GitHub Actions will automatically start.

---

# Run Project Locally 🛠️

## Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
```

## Install Dependencies

```bash
flutter pub get
```

## Run App

```bash
flutter run
```

---

# Build APK 📱

```bash
flutter build apk --release
```

Generated APK location:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

# Technologies Used 🧩

* Flutter
* Dart
* flutter_bloc
* SharedPreferences
* Video Player
* Local Notifications
* GitHub Actions

---

# Future Improvements 🚀

* Firebase Authentication
* AI Meal Recommendations
* Dark Mode
* Meal Planner
* Voice Search
* Multi-language Support

---

# Author 👨‍💻

Soumya Ranjan Mishra
