import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: kDebugMode ? const Duration(minutes: 5) : const Duration(hours: 12),
      ));

      // Set default values
      await _remoteConfig.setDefaults(const {
        'show_new_feature': false,
        'welcome_message': 'Welcome to DiskiChat!',
      });

      await _fetchAndActivate();
    } catch (e) {
      debugPrint('Remote Config: Initialization failed: $e');
    }
  }

  Future<void> _fetchAndActivate() async {
    try {
      bool updated = await _remoteConfig.fetchAndActivate();
      if (updated) {
        debugPrint('Remote Config: Config updated from cloud.');
      } else {
        debugPrint('Remote Config: Config already up to date.');
      }
    } catch (e) {
      debugPrint('Remote Config: Fetch failed: $e');
    }
  }

  // Getters for specific flags
  bool get showNewFeature => _remoteConfig.getBool('show_new_feature');
  String get welcomeMessage => _remoteConfig.getString('welcome_message');
}
