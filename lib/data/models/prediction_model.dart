class PredictionModel {
  final String matchId;
  final String predictedWinner; // home, away, draw
  final String predictedScore;
  final double confidence;
  final List<String> keyFactors;
  final String? starPlayer;
  final DateTime createdAt;

  PredictionModel({
    required this.matchId,
    required this.predictedWinner,
    required this.predictedScore,
    required this.confidence,
    required this.keyFactors,
    this.starPlayer,
    required this.createdAt,
  });

  factory PredictionModel.fromMap(Map<String, dynamic> map) {
    return PredictionModel(
      matchId: map['matchId'] ?? '',
      predictedWinner: map['predictedWinner'] ?? '',
      predictedScore: map['predictedScore'] ?? '',
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      keyFactors: List<String>.from(map['keyFactors'] ?? []),
      starPlayer: map['starPlayer'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'matchId': matchId,
      'predictedWinner': predictedWinner,
      'predictedScore': predictedScore,
      'confidence': confidence,
      'keyFactors': keyFactors,
      'starPlayer': starPlayer,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}