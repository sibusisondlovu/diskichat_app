import 'dart:convert';

import 'package:http/http.dart' as http;
import '../data/models/match_model.dart';
import '../data/models/lineup_model.dart';

import '../utils/constants/api_constants.dart';

class ApiService {
  // Get matches (mapped to /api/matches which now returns ALL)
  // API Methods removed as backend is deprecated. use Firestore.
  // Kept class for potential future external API calls if needed directly from app (though unlikely)
  // Get lineups
  Future<List<LineupModel>> getLineups(String fixtureId) async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/api/lineups/$fixtureId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> lineupsJson = data['lineups'];
          return lineupsJson.map((json) => LineupModel.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load lineups');
      }
    } catch (e) {
      throw Exception('Error fetching lineups: $e');
    }
  }
  // Submit feedback
  Future<void> submitFeedback({
    String? userId,
    required String type,
    required String description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/feedback'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'type': type,
          'description': description,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to submit feedback: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting feedback: $e');
    }
  }
}
