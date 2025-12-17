import 'dart:convert';

import 'package:http/http.dart' as http;
import '../data/models/match_model.dart';
import '../data/models/lineup_model.dart';

import '../utils/constants/api_constants.dart';

class ApiService {
  // Get matches (mapped to /api/matches which now returns ALL)
  Future<List<MatchModel>> getLiveMatches() async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.matches}';
    print('ApiService: requesting $url');
    try {
      final response = await http.get(Uri.parse(url));

      print('ApiService: response status ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> matchesJson = data['matches'];
          print('ApiService: parsed ${matchesJson.length} matches');
          return matchesJson.map((json) => MatchModel.fromApi(json)).toList();
        } else {
          print('ApiService: API returned success=false');
          throw Exception('API returned success: false');
        }
      } else {
        print('ApiService: failed with ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load matches: ${response.statusCode}');
      }
    } catch (e) {
      print('ApiService Error: $e');
      throw Exception('Error connecting to Server: $e');
    }
  }
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
