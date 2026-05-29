import 'package:hive/hive.dart';

class UserPreferencesService {
  static const String _nameKey = 'user_name';
  static const String _onboardedKey = 'is_onboarded';

  final Box<dynamic> _box;

  UserPreferencesService(this._box);

  // ── Name ──────────────────────────────────────────────────────────────────

  String? get userName => _box.get(_nameKey) as String?;

  Future<void> setUserName(String name) => _box.put(_nameKey, name.trim());

  // ── Onboarding ────────────────────────────────────────────────────────────

  bool get isOnboarded => _box.get(_onboardedKey, defaultValue: false) as bool;

  Future<void> completeOnboarding() => _box.put(_onboardedKey, true);
}
