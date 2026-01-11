import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String username;
  final String? userTeam;
  final String? userTeamLogo;
  final String? userAvatar;
  final String content;
  final String? imageUrl;
  final String? videoUrl;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  bool isLiked;

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    this.userTeam, 
    this.userTeamLogo,
    this.userAvatar,
    required this.content,
    this.imageUrl,
    this.videoUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    this.isLiked = false,
  });

  // From Firestore
  factory PostModel.fromMap(Map<String, dynamic> map, String docId) {
    return PostModel(
      id: docId,
      userId: map['userId'] ?? '',
      username: map['username'] ?? 'Anonymous',
      userTeam: map['userTeam'],
      userTeamLogo: map['userTeamLogo'],
      userAvatar: map['userAvatar'],
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      videoUrl: map['videoUrl'],
      likesCount: map['likesCount'] ?? 0,
      commentsCount: map['commentsCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // Liked status usually requires a separate subcollection query or array check
      // We will handle 'isLiked' separately in the UI or service
      isLiked: false, 
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'userTeam': userTeam,
      'userTeamLogo': userTeamLogo,
      'userAvatar': userAvatar,
      'content': content,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': FieldValue.serverTimestamp(), // Use server timestamp on create
    };
  }

  // Legacy JSON support (if needed, or can be removed)
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'].toString(), // Convert MySQL int to String
      userId: json['user_id'],
      username: json['username'] ?? 'Anonymous',
      userAvatar: json['user_avatar'],
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
      videoUrl: json['video_url'],
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
  // copyWith for editing
  PostModel copyWith({
    String? content,
    String? imageUrl,
    String? videoUrl,
  }) {
    return PostModel(
      id: id,
      userId: userId,
      username: username,
      userTeam: userTeam,
      userTeamLogo: userTeamLogo,
      userAvatar: userAvatar,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      likesCount: likesCount,
      commentsCount: commentsCount,
      createdAt: createdAt,
      isLiked: isLiked,
    );
  }
}
