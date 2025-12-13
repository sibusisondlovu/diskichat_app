import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth State
  bool get isLoggedIn => _prefs.getBool('isLoggedIn') ?? false;
  
  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool('isLoggedIn', value);
  }

  // Onboarding State
  bool get isOnboardingDone => _prefs.getBool('onboardingDone') ?? false;

  Future<void> setOnboardingDone(bool value) async {
    await _prefs.setBool('onboardingDone', value);
  }
}
