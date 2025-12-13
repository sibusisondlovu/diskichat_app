class EventModel {
  final int id;
  final String player; // Player name
  final String player2; // Assist or Sub-In name (often in 'detail' or 'assist')
  final String type; // Goal, Card, subst, Var
  final String detail; // Normal Goal, Yellow Card, etc.
  final int time; // Minutes
  final String? extraTime; // +3 etc.
  final int teamId;
  final String teamName; // Helps if mapped

  EventModel({
    required this.id,
    required this.player,
    this.player2 = '',
    required this.type,
    required this.detail,
    required this.time,
    this.extraTime,
    required this.teamId,
    this.teamName = '',
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    // API-Football structure often stored in DB:
    // { fixture_id, team_id, player, type, detail, minutes, extra }
    // Or if joined in API response: { ... }
    
    return EventModel(
      id: json['id'] ?? 0,
      player: json['player'] ?? 'Unknown',
      type: json['type'] ?? '',
      detail: json['detail'] ?? '',
      time: json['minutes'] ?? 0,
      extraTime: json['extra'],
      teamId: json['team_id'] ?? 0,
      // teamName often not in event table, might need lookup if vital, 
      // but usually we check if teamId == homeTeamId to align UI.
    );
  }
}
