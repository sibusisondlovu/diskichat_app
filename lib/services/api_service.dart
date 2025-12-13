import 'dart:convert';

import 'package:http/http.dart' as http;
import '../data/models/match_model.dart';
import '../data/models/lineup_model.dart';

import '../utils/constants/api_constants.dart';

class ApiService {
  // Get live matches
  Future<List<MatchModel>> getLiveMatches() async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.liveMatches}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> matchesJson = data['matches'];
          return matchesJson.map((json) => MatchModel.fromApi(json)).toList();
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load matches: ${response.statusCode}');
      }
    } catch (e) {
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
}
