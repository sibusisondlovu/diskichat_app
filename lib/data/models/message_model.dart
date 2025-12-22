import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String matchId;
  final String userId;
  final String message;
  final String messageType; // comment, goal, card, reaction, system
  final int votes;
  final bool isPinned;
  final DateTime createdAt;

  // User info (denormalized for display)
  final String? imageUrl;
  final String? videoUrl;
  final String? thumbnailUrl;
  final Map<String, String> reactions; // UserId -> Emoji

  MessageModel({
    required this.id,
    required this.matchId,
    required this.userId,
    required this.message,
    this.messageType = 'comment',
    this.votes = 0,
    this.isPinned = false,
    required this.createdAt,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.userRank,
    this.imageUrl,
    this.videoUrl,
    this.thumbnailUrl,
    this.reactions = const {},
  });

  // From Firestore
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      matchId: map['matchId'] ?? '',
      userId: map['userId'] ?? '',
      message: map['message'] ?? '',
      messageType: map['messageType'] ?? 'comment',
      votes: map['votes'] ?? 0,
      isPinned: map['isPinned'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      username: map['username'],
      displayName: map['displayName'],
      avatarUrl: map['avatarUrl'],
      userRank: map['userRank'],
      imageUrl: map['imageUrl'],
      videoUrl: map['videoUrl'],
      thumbnailUrl: map['thumbnailUrl'],
      reactions: Map<String, String>.from(map['reactions'] ?? {}),
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'matchId': matchId,
      'userId': userId,
      'message': message,
      'messageType': messageType,
      'votes': votes,
      'isPinned': isPinned,
      'createdAt': Timestamp.fromDate(createdAt),
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'userRank': userRank,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'reactions': reactions,
    };
  }

  // Copy with
  MessageModel copyWith({
    String? id,
    String? matchId,
    String? userId,
    String? message,
    String? messageType,
    int? votes,
    bool? isPinned,
    DateTime? createdAt,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? userRank,
    String? imageUrl,
    String? videoUrl,
    String? thumbnailUrl,
    Map<String, String>? reactions,
  }) {
    return MessageModel(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      messageType: messageType ?? this.messageType,
      votes: votes ?? this.votes,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      userRank: userRank ?? this.userRank,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      reactions: reactions ?? this.reactions,
    );
  }

  // Helpers
  bool get isComment => messageType == 'comment';
  bool get isReaction => messageType == 'reaction';
  bool get isGoal => messageType == 'goal';
  bool get isCard => messageType == 'card';
  bool get isSystem => messageType == 'system';
  bool get hasMedia => imageUrl != null || videoUrl != null;
  bool get isImage => imageUrl != null;
  bool get isVideo => videoUrl != null;
}