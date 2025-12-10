import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  final String id;
  final String? competitionId;
  final String competitionName;
  final String homeTeam;
  final String awayTeam;
  final String? homeLogo;
  final String? awayLogo;
  final DateTime matchDate;
  final String status; // upcoming, live, halftime, finished, postponed
  final int scoreHome;
  final int scoreAway;
  final String? venue;
  final String? apiMatchId;
  final Map<String, dynamic>? aiPrediction;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MatchModel({
    required this.id,
    this.competitionId,
    this.competitionName = 'Football',
    required this.homeTeam,
    required this.awayTeam,
    this.homeLogo,
    this.awayLogo,
    required this.matchDate,
    this.status = 'upcoming',
    this.scoreHome = 0,
    this.scoreAway = 0,
    this.venue,
    this.apiMatchId,
    this.aiPrediction,
    required this.createdAt,
    this.updatedAt,
  });

  // From Firestore
  factory MatchModel.fromMap(Map<String, dynamic> map) {
    return MatchModel(
      id: map['id'] ?? '',
      competitionId: map['competitionId'],
      competitionName: map['competitionName'] ?? 'Football',
      homeTeam: map['homeTeam'] ?? '',
      awayTeam: map['awayTeam'] ?? '',
      homeLogo: map['homeLogo'],
      awayLogo: map['awayLogo'],
      matchDate: (map['matchDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'upcoming',
      scoreHome: map['scoreHome'] ?? 0,
      scoreAway: map['scoreAway'] ?? 0,
      venue: map['venue'],
      apiMatchId: map['apiMatchId'],
      aiPrediction: map['aiPrediction'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'competitionId': competitionId,
      'competitionName': competitionName,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'homeLogo': homeLogo,
      'awayLogo': awayLogo,
      'matchDate': Timestamp.fromDate(matchDate),
      'status': status,
      'scoreHome': scoreHome,
      'scoreAway': scoreAway,
      'venue': venue,
      'apiMatchId': apiMatchId,
      'aiPrediction': aiPrediction,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Copy with
  MatchModel copyWith({
    String? id,
    String? competitionId,
    String? competitionName,
    String? homeTeam,
    String? awayTeam,
    String? homeLogo,
    String? awayLogo,
    DateTime? matchDate,
    String? status,
    int? scoreHome,
    int? scoreAway,
    String? venue,
    String? apiMatchId,
    Map<String, dynamic>? aiPrediction,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MatchModel(
      id: id ?? this.id,
      competitionId: competitionId ?? this.competitionId,
      competitionName: competitionName ?? this.competitionName,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      homeLogo: homeLogo ?? this.homeLogo,
      awayLogo: awayLogo ?? this.awayLogo,
      matchDate: matchDate ?? this.matchDate,
      status: status ?? this.status,
      scoreHome: scoreHome ?? this.scoreHome,
      scoreAway: scoreAway ?? this.scoreAway,
      venue: venue ?? this.venue,
      apiMatchId: apiMatchId ?? this.apiMatchId,
      aiPrediction: aiPrediction ?? this.aiPrediction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helpers
  bool get isLive => status == 'live';
  bool get isUpcoming => status == 'upcoming';
  bool get isFinished => status == 'finished';

  String get scoreDisplay => '$scoreHome - $scoreAway';

  String get statusDisplay {
    switch (status) {
      case 'live':
        return 'LIVE';
      case 'halftime':
        return 'HT';
      case 'finished':
        return 'FT';
      case 'postponed':
        return 'Postponed';
      default:
        return 'Upcoming';
    }
  }
}