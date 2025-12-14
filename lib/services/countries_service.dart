import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants/api_constants.dart';
import '../data/models/country_model.dart';

class CountriesService {
  Future<List<Country>> getActiveCountries() async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/api/countries'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['countries'];
          return list.map((json) => Country.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching countries: $e');
    }
  }
}
