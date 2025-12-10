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
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? userRank;

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
    );
  }

  // Helpers
  bool get isComment => messageType == 'comment';
  bool get isReaction => messageType == 'reaction';
  bool get isGoal => messageType == 'goal';
  bool get isCard => messageType == 'card';
  bool get isSystem => messageType == 'system';
}