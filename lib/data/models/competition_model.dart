import 'package:cloud_firestore/cloud_firestore.dart';

class CompetitionModel {
  final String id;
  final String name;
  final String code;
  final String? country;
  final String? logoUrl;
  final bool isActive;
  final DateTime createdAt;

  CompetitionModel({
    required this.id,
    required this.name,
    required this.code,
    this.country,
    this.logoUrl,
    this.isActive = true,
    required this.createdAt,
  });

  factory CompetitionModel.fromMap(Map<String, dynamic> map) {
    return CompetitionModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      country: map['country'],
      logoUrl: map['logoUrl'],
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'country': country,
      'logoUrl': logoUrl,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}