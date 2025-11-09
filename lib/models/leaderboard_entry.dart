// lib/models/leaderboard_entry.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user's entry on the leaderboard
class LeaderboardEntry {
  final String userId;
  final String username;
  final int totalScore; // Sum of all quiz scores (percentage-based)
  final int totalQuizzes; // Total number of quizzes completed
  final double averageScore; // Average quiz score percentage
  final String level; // User level (Mai Fara Koyo, Mai Himma, etc.)
  final DateTime lastUpdated;
  final int rank; // Computed rank (not stored in Firestore)

  LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.totalScore,
    required this.totalQuizzes,
    required this.averageScore,
    required this.level,
    required this.lastUpdated,
    this.rank = 0,
  });

  /// Create from Firestore document
  factory LeaderboardEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaderboardEntry(
      userId: doc.id,
      username: data['username'] ?? 'Unknown',
      totalScore: data['totalScore'] ?? 0,
      totalQuizzes: data['totalQuizzes'] ?? 0,
      averageScore: (data['averageScore'] ?? 0.0).toDouble(),
      level: data['level'] ?? 'Mai Fara Koyo',
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'totalScore': totalScore,
      'totalQuizzes': totalQuizzes,
      'averageScore': averageScore,
      'level': level,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  /// Create a copy with updated rank
  LeaderboardEntry copyWith({
    String? userId,
    String? username,
    int? totalScore,
    int? totalQuizzes,
    double? averageScore,
    String? level,
    DateTime? lastUpdated,
    int? rank,
  }) {
    return LeaderboardEntry(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      totalScore: totalScore ?? this.totalScore,
      totalQuizzes: totalQuizzes ?? this.totalQuizzes,
      averageScore: averageScore ?? this.averageScore,
      level: level ?? this.level,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rank: rank ?? this.rank,
    );
  }
}