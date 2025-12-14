import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants/api_constants.dart';
// Need a League Model. Using map for now or create simple model.

class League {
  final int id;
  final String name;
  final String logo;
  final String country;

  League({required this.id, required this.name, required this.logo, required this.country});

  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      id: json['id'],
      name: json['name'],
      logo: json['logo'] ?? '',
      country: json['country'] ?? '',
    );
  }
}

class CompetitionsService {
  Future<List<League>> getCompetitions() async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/api/competitions/all')); 
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['competitions'];
          return list.map((json) => League.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching competitions: $e');
    }
  }
}
