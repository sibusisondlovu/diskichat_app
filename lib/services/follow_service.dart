import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants/api_constants.dart';
import '../data/models/team_model.dart';

class FollowService {
  // Get User Follows (and subscription status)
  Future<Map<String, dynamic>> getUserFollows(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/follows/$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      throw Exception('Failed to load follows');
    } catch (e) {
      throw Exception('Error fetching follows: $e');
    }
  }

  // Follow Team
  Future<void> followTeam(String userId, int teamId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/follows/team'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId, 'teamId': teamId}),
      );

      if (response.statusCode != 201) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to follow team');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Unfollow Team
  Future<void> unfollowTeam(String userId, int teamId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/follows/team/unfollow'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId, 'teamId': teamId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to unfollow team');
      }
    } catch (e) {
      throw Exception('Error unfollowing team: $e');
    }
  }

  // Follow League
  Future<void> followLeague(String userId, int leagueId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/follows/league'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId, 'leagueId': leagueId}),
      );

      if (response.statusCode != 201) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to follow league');
      }
    } catch (e) {
      rethrow;
    }
  }
}
