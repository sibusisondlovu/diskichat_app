import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String userId;
  final String username;
  final String userEmail;
  final String type; // e.g. "Bug", "Feature Request", "General"
  final String description;
  final DateTime createdAt;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userEmail,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'userEmail': userEmail,
      'type': type,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
