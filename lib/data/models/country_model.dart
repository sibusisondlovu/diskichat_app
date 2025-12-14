class Country {
  final int id;
  final String name;
  final String code;
  final String? flag;

  Country({
    required this.id,
    required this.name,
    required this.code,
    this.flag,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      name: json['name'],
      code: json['code'] ?? '',
      flag: json['flag'],
    );
  }
}
