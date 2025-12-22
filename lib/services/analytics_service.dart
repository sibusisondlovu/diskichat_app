import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
      debugPrint('Analytics: Logged event $name with params $parameters');
    } catch (e) {
      debugPrint('Analytics: Failed to log event $name: $e');
    }
  }

  Future<void> logScreenView({required String screenName}) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
      debugPrint('Analytics: Logged screen view $screenName');
    } catch (e) {
      debugPrint('Analytics: Failed to log screen view: $e');
    }
  }

  // Pre-defined business events
  Future<void> logSignUp() async {
    await logEvent(name: 'sign_up_click');
  }

  Future<void> logUpgradeClick({String? fromScreen}) async {
    await logEvent(name: 'upgrade_click', parameters: {'source': fromScreen ?? 'unknown'});
  }
}
