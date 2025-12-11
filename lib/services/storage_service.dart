import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyOnboardingDone = 'onboarding_done';
  
  // Singleton instance
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;

  // Initialize - call this in main or splash
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Onboarding Flag
  bool get isOnboardingDone => _prefs.getBool(_keyOnboardingDone) ?? false;

  Future<void> setOnboardingDone(bool value) async {
    await _prefs.setBool(_keyOnboardingDone, value);
  }
  
  // Clear all data (optional, for debugging/logout)
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
