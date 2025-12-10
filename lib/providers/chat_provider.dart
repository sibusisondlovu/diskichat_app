import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../data/models/message_model.dart';
import '../utils/constants/app_constants.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  List<MessageModel> _messages = [];
  int _activeUsersCount = 0;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, String?> _userVotes = {}; // messageId -> voteType

  // Getters
  List<MessageModel> get messages => _messages;
  int get activeUsersCount => _activeUsersCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load messages for a match
  void loadMessages(String matchId) {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getMatchMessages(matchId).listen(
          (messages) {
        _messages = messages;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Load active users count
  void loadActiveUsersCount(String matchId) {
    _firestoreService.getActiveUsersCount(matchId).listen(
          (count) {
        _activeUsersCount = count;
        notifyListeners();
      },
    );
  }

  // Send message
  Future<bool> sendMessage({
    required String matchId,
    required String message,
    String messageType = 'comment',
  }) async {
    final user = _authService.currentUser;
    if (user == null) return false;

    try {
      final messageModel = MessageModel(
        id: const Uuid().v4(),
        matchId: matchId,
        userId: user.uid,
        message: message,
        messageType: messageType,
        votes: 0,
        createdAt: DateTime.now(),
      );

      await _firestoreService.sendMessage(matchId, messageModel);

      // Award points for sending message
      await _authService.updateUserPoints(
        user.uid,
        AppConstants.pointsPerMessage,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Vote on message
  Future<void> voteMessage({
    required String matchId,
    required String messageId,
    required String voteType,
  }) async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      await _firestoreService.voteMessage(
        matchId: matchId,
        messageId: messageId,
        userId: user.uid,
        voteType: voteType,
      );

      // Update local vote state
      _userVotes[messageId] = voteType;
      notifyListeners();

      // Award/deduct points
      if (voteType == 'up') {
        await _authService.updateUserPoints(
          user.uid,
          AppConstants.pointsPerUpvote,
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Get user's vote on a message
  String? getUserVote(String messageId) {
    return _userVotes[messageId];
  }

  // Join room
  Future<void> joinRoom(String matchId) async {
    final user = _authService.currentUser;
    if (user == null) return;

    await _firestoreService.joinRoom(matchId, user.uid);
  }

  // Leave room
  Future<void> leaveRoom(String matchId) async {
    final user = _authService.currentUser;
    if (user == null) return;

    await _firestoreService.leaveRoom(matchId, user.uid);
  }

  // Update last active
  Future<void> updateLastActive(String matchId) async {
    final user = _authService.currentUser;
    if (user == null) return;

    await _firestoreService.updateLastActive(matchId, user.uid);
  }

  // Clear messages
  void clearMessages() {
    _messages = [];
    _activeUsersCount = 0;
    _userVotes.clear();
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}