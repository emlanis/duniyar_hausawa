// lib/services/leaderboard_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/leaderboard_entry.dart';
import 'database_service.dart';
import 'dart:math';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'leaderboard';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';

  /// Get or generate a unique user ID
  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(_userIdKey);

    if (userId == null) {
      // Generate a unique ID
      userId = _generateUserId();
      await prefs.setString(_userIdKey, userId);
    }

    return userId;
  }

  /// Get the stored username
  Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey) ?? 'Dan Hausa'; // Default username
  }

  /// Set the username
  Future<void> setUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);

    // Update Firestore entry if exists
    final userId = await getUserId();
    await _firestore.collection(_collectionName).doc(userId).update({
      'username': username,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  /// Generate a random user ID
  String _generateUserId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNum = random.nextInt(999999);
    return 'user_${timestamp}_$randomNum';
  }

  /// Calculate user level based on total activity
  String _calculateLevel(int totalActivity) {
    if (totalActivity >= 100) return 'Gwani';
    if (totalActivity >= 50) return 'Mai Ƙwarewa';
    if (totalActivity >= 25) return 'Mai Ci Gaba';
    if (totalActivity >= 10) return 'Mai Himma';
    return 'Mai Fara Koyo';
  }

  /// Update user score on the leaderboard
  Future<void> updateUserScore({
    required int totalScore,
    required int totalQuizzes,
    required double averageScore,
  }) async {
    try {
      final userId = await getUserId();
      final username = await getUsername();
      final level = _calculateLevel(totalQuizzes);

      final entry = LeaderboardEntry(
        userId: userId,
        username: username,
        totalScore: totalScore,
        totalQuizzes: totalQuizzes,
        averageScore: averageScore,
        level: level,
        lastUpdated: DateTime.now(),
      );

      await _firestore
          .collection(_collectionName)
          .doc(userId)
          .set(entry.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      print('Error updating leaderboard: $e');
      rethrow;
    }
  }

  /// Get top N users from the leaderboard
  Future<List<LeaderboardEntry>> getTopPlayers({int limit = 100}) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('averageScore', descending: true)
          .orderBy('totalQuizzes', descending: true)
          .limit(limit)
          .get();

      final entries = snapshot.docs
          .map((doc) => LeaderboardEntry.fromFirestore(doc))
          .toList();

      // Assign ranks
      for (int i = 0; i < entries.length; i++) {
        entries[i] = entries[i].copyWith(rank: i + 1);
      }

      return entries;
    } catch (e) {
      print('Error fetching leaderboard: $e');
      return [];
    }
  }

  /// Get the current user's leaderboard entry
  Future<LeaderboardEntry?> getCurrentUserEntry() async {
    try {
      final userId = await getUserId();
      final doc = await _firestore
          .collection(_collectionName)
          .doc(userId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return LeaderboardEntry.fromFirestore(doc);
    } catch (e) {
      print('Error fetching user entry: $e');
      return null;
    }
  }

  /// Get the current user's rank
  Future<int> getCurrentUserRank() async {
    try {
      final userEntry = await getCurrentUserEntry();
      if (userEntry == null) return 0;

      // Count users with higher average score
      final higherScoreCount = await _firestore
          .collection(_collectionName)
          .where('averageScore', isGreaterThan: userEntry.averageScore)
          .get()
          .then((snapshot) => snapshot.size);

      // Count users with same average but more quizzes
      final sameScoreCount = await _firestore
          .collection(_collectionName)
          .where('averageScore', isEqualTo: userEntry.averageScore)
          .where('totalQuizzes', isGreaterThan: userEntry.totalQuizzes)
          .get()
          .then((snapshot) => snapshot.size);

      return higherScoreCount + sameScoreCount + 1;
    } catch (e) {
      print('Error fetching user rank: $e');
      return 0;
    }
  }

  /// Stream of real-time leaderboard updates
  Stream<List<LeaderboardEntry>> streamLeaderboard({int limit = 100}) {
    return _firestore
        .collection(_collectionName)
        .orderBy('averageScore', descending: true)
        .orderBy('totalQuizzes', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final entries = snapshot.docs
          .map((doc) => LeaderboardEntry.fromFirestore(doc))
          .toList();

      // Assign ranks
      for (int i = 0; i < entries.length; i++) {
        entries[i] = entries[i].copyWith(rank: i + 1);
      }

      return entries;
    });
  }

  /// Check if user has set their username
  Future<bool> hasUsername() async {
    final username = await getUsername();
    return username != 'Dan Hausa'; // Not the default
  }

  /// Sync quiz statistics from local database to Firebase
  /// Call this after each quiz completion
  Future<void> syncFromLocalDatabase() async {
    try {
      final dbService = DatabaseService.instance;

      // Get all quiz results
      final quizResults = await dbService.getAllQuizResults();
      final photoQuizResults = await dbService.getAllPhotoQuizResults();

      if (quizResults.isEmpty && photoQuizResults.isEmpty) {
        return; // No data to sync
      }

      // Calculate total score and average
      int totalScore = 0;
      int totalQuestions = 0;

      // Process proverb quiz results
      for (final result in quizResults) {
        final percentage = (result.correctAnswers / result.totalQuestions * 100).round();
        totalScore += percentage;
        totalQuestions++;
      }

      // Process photo quiz results
      for (final result in photoQuizResults) {
        final correct = result['correctAnswers'] as int;
        final total = result['totalQuestions'] as int;
        final percentage = (correct / total * 100).round();
        totalScore += percentage;
        totalQuestions++;
      }

      final averageScore = totalQuestions > 0 ? totalScore / totalQuestions : 0.0;

      // Update leaderboard
      await updateUserScore(
        totalScore: totalScore,
        totalQuizzes: totalQuestions,
        averageScore: averageScore,
      );
    } catch (e) {
      print('Error syncing to leaderboard: $e');
      // Don't throw - we don't want to break quiz flow if sync fails
    }
  }
}