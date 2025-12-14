class Team {
  final int id;
  final String name;
  final String? code;
  final String? logo;
  final String? country;
  final bool isNational;
  final int founded;
  final String? venueName;
  final String? venueCity;
  final int venueCapacity;

  Team({
    required this.id,
    required this.name,
    this.code,
    this.logo,
    this.country,
    this.isNational = false,
    this.founded = 0,
    this.venueName,
    this.venueCity,
    this.venueCapacity = 0,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      logo: json['logo'],
      country: json['country'],
      isNational: json['is_national'] == 1 || json['is_national'] == true,
      founded: json['founded'] ?? 0,
      venueName: json['venue_name'],
      venueCity: json['venue_city'],
      venueCapacity: json['venue_capacity'] ?? 0,
    );
  }
}
