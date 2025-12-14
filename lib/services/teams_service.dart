import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants/api_constants.dart';
import '../data/models/team_model.dart';

class TeamsService {
  Future<List<Team>> getTeams({String? country}) async {
    try {
      // Assuming endpoint GET /api/teams exists and returns all seeded teams
      // Or we can add search params later. For MVP/Seeding, we probably just get all or by league
      // But the endpoint we built earlier was a sync service... 
      // Wait, we need a GET endpoint on backend to purely "list" teams for the app selection.
      // I only have `GET /api/teams` which probably calls `fetchTeams` (the sync).
      // I need to check `teams.routes.js`.
      
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/teams').replace(
        queryParameters: country != null ? {'country': country} : null,
      );
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> teamsJson = data['teams'];
          return teamsJson.map((json) => Team.fromJson(json)).toList();
        }
      }
      return []; // Return empty if failed or no data
    } catch (e) {
      throw Exception('Error fetching teams: $e');
    }
  }
}
