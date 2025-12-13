import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/match_model.dart';
import '../data/models/message_model.dart';
import '../data/models/post_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== MATCHES ==========

  // Get all matches
  Stream<List<MatchModel>> getMatches() {
    return _firestore
        .collection('matches')
        .orderBy('matchDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MatchModel.fromMap(doc.data()))
        .toList());
  }

  // Get live matches
  Stream<List<MatchModel>> getLiveMatches() {
    return _firestore
        .collection('matches')
        .where('status', isEqualTo: 'live')
        .orderBy('matchDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MatchModel.fromMap(doc.data()))
        .toList());
  }

  // Get matches by date
  Stream<List<MatchModel>> getMatchesByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('matches')
        .where('matchDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('matchDate', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('matchDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MatchModel.fromMap(doc.data()))
        .toList());
  }

  // Get matches by competition
  Stream<List<MatchModel>> getMatchesByCompetition(String competitionId) {
    return _firestore
        .collection('matches')
        .where('competitionId', isEqualTo: competitionId)
        .orderBy('matchDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MatchModel.fromMap(doc.data()))
        .toList());
  }

  // Get single match
  Stream<MatchModel?> getMatch(String matchId) {
    return _firestore
        .collection('matches')
        .doc(matchId)
        .snapshots()
        .map((doc) => doc.exists ? MatchModel.fromMap(doc.data()!) : null);
  }

  // Add match (admin only - for testing)
  Future<void> addMatch(MatchModel match) async {
    await _firestore.collection('matches').doc(match.id).set(match.toMap());
  }

  // Update match score
  Future<void> updateMatchScore(String matchId, int homeScore, int awayScore) async {
    await _firestore.collection('matches').doc(matchId).update({
      'scoreHome': homeScore,
      'scoreAway': awayScore,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update match status
  Future<void> updateMatchStatus(String matchId, String status) async {
    await _firestore.collection('matches').doc(matchId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ========== MESSAGES ==========

  // Get messages for a match
  Stream<List<MessageModel>> getMatchMessages(String matchId, {int limit = 50}) {
    return _firestore
        .collection('matches')
        .doc(matchId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MessageModel.fromMap(doc.data()))
        .toList()
        .reversed
        .toList());
  }

  // Send message
  Future<void> sendMessage(String matchId, MessageModel message) async {
    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());
  }

  // Update message votes
  Future<void> updateMessageVotes(String matchId, String messageId, int votes) async {
    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('messages')
        .doc(messageId)
        .update({
      'votes': votes,
    });
  }

  // Vote on message
  Future<void> voteMessage({
    required String matchId,
    required String messageId,
    required String userId,
    required String voteType, // 'up' or 'down'
  }) async {
    final voteRef = _firestore
        .collection('matches')
        .doc(matchId)
        .collection('messages')
        .doc(messageId)
        .collection('votes')
        .doc(userId);

    final voteDoc = await voteRef.get();

    if (voteDoc.exists) {
      // User already voted, remove vote or change vote
      final existingVote = voteDoc.data()?['type'];
      if (existingVote == voteType) {
        // Same vote, remove it
        await voteRef.delete();
        await _updateVoteCount(matchId, messageId, voteType == 'up' ? -1 : 1);
      } else {
        // Different vote, change it
        await voteRef.update({'type': voteType});
        await _updateVoteCount(matchId, messageId, voteType == 'up' ? 2 : -2);
      }
    } else {
      // New vote
      await voteRef.set({
        'type': voteType,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _updateVoteCount(matchId, messageId, voteType == 'up' ? 1 : -1);
    }
  }

  Future<void> _updateVoteCount(String matchId, String messageId, int change) async {
    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('messages')
        .doc(messageId)
        .update({
      'votes': FieldValue.increment(change),
    });
  }

  // Get user's vote on a message
  Future<String?> getUserVote(String matchId, String messageId, String userId) async {
    final voteDoc = await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('messages')
        .doc(messageId)
        .collection('votes')
        .doc(userId)
        .get();

    if (voteDoc.exists) {
        final data = voteDoc.data();
        if (data != null) {
             return data['type'];
        }
    }
    return null;
  }

  // ========== ROOM ACTIVITY ==========

  // Join room
  Future<void> joinRoom(String matchId, String userId, {bool checkLimit = true}) async {
    final activeUsersRef = _firestore
        .collection('matches')
        .doc(matchId)
        .collection('activeUsers');

    if (checkLimit) {
      // Check count first
      final countQuery = await activeUsersRef.count().get();
      final count = countQuery.count ?? 0;

      if (count >= 100) {
        throw Exception('Room is full (100/100 users). Try again later.');
      }
    }

    await activeUsersRef.doc(userId).set({
      'userId': userId,
      'joinedAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // Merge to prevent overwriting joinedAt if needed
  }

  // Update last active
  Future<void> updateLastActive(String matchId, String userId) async {
    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('activeUsers')
        .doc(userId)
        .update({
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  // Leave room
  Future<void> leaveRoom(String matchId, String userId) async {
    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('activeUsers')
        .doc(userId)
        .delete();
  }

  // Get active users count
  Stream<int> getActiveUsersCount(String matchId) {
    return _firestore
        .collection('matches')
        .doc(matchId)
        .collection('activeUsers')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Clean up inactive users (older than 5 minutes)
  Future<void> cleanupInactiveUsers(String matchId) async {
    final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));

    final snapshot = await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('activeUsers')
        .where('lastActive', isLessThan: Timestamp.fromDate(fiveMinutesAgo))
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
  // ========== SOCIAL FEED ==========

  // Get Feed Stream
  Stream<List<PostModel>> getFeed() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PostModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Create Post
  Future<void> createPost(PostModel post) async {
    // We let Firestore generate ID, so we use collection.add or set with custom ID?
    // PostModel ID is locally generated? No, let's use add().
    // We passed a PostModel, but we should probably just pass the Map or ignore ID.
    await _firestore.collection('posts').add(post.toMap());
  }

  // Like Post
  Future<void> likePost(String postId, String userId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final likeRef = postRef.collection('likes').doc(userId);

    final likeDoc = await likeRef.get();
    if (likeDoc.exists) {
      // Unlike
      await likeRef.delete();
      await postRef.update({'likesCount': FieldValue.increment(-1)});
    } else {
      // Like
      await likeRef.set({
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await postRef.update({'likesCount': FieldValue.increment(1)});
    }
  }

  // Check if User Liked Post
  Future<bool> hasUserLikedPost(String postId, String userId) async {
    final likeDoc = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(userId)
        .get();
    return likeDoc.exists;
  }
}