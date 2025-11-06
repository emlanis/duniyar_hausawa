// lib/models/photo_quiz_model.dart

class PhotoQuizItem {
  final int id;
  final String category;
  final String hausaName;
  final String englishName;
  final String imagePath;
  final String? description;
  final String? culturalNote;

  PhotoQuizItem({
    required this.id,
    required this.category,
    required this.hausaName,
    required this.englishName,
    required this.imagePath,
    this.description,
    this.culturalNote,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'hausaName': hausaName,
      'englishName': englishName,
      'imagePath': imagePath,
      'description': description,
      'culturalNote': culturalNote,
    };
  }

  factory PhotoQuizItem.fromMap(Map<String, dynamic> map) {
    return PhotoQuizItem(
      id: map['id'] as int,
      category: map['category'] as String,
      hausaName: map['hausaName'] as String,
      englishName: map['englishName'] as String,
      imagePath: map['imagePath'] as String,
      description: map['description'] as String?,
      culturalNote: map['culturalNote'] as String?,
    );
  }
}

class PhotoQuizQuestion {
  final int id;
  final PhotoQuizItem correctItem;
  final List<String> options;
  final int correctOptionIndex;
  final String category;

  PhotoQuizQuestion({
    required this.id,
    required this.correctItem,
    required this.options,
    required this.correctOptionIndex,
    required this.category,
  });

  String get correctAnswer => options[correctOptionIndex];
}

class PhotoQuizCategory {
  final String id;
  final String hausaName;
  final String englishName;
  final String icon;
  final int color;
  final String description;

  PhotoQuizCategory({
    required this.id,
    required this.hausaName,
    required this.englishName,
    required this.icon,
    required this.color,
    required this.description,
  });

  static List<PhotoQuizCategory> getAllCategories() {
    return [
      PhotoQuizCategory(
        id: 'cities',
        hausaName: 'Biranen Hausawa',
        englishName: 'Hausa Cities',
        icon: '🏙️',
        color: 0xFF2196F3,
        description: 'Gano biranen Hausawa masu tarihi',
      ),
      PhotoQuizCategory(
        id: 'animals',
        hausaName: 'Dabbobi',
        englishName: 'Animals',
        icon: '🐑',
        color: 0xFF4CAF50,
        description: 'Koyi sunayen dabbobi cikin Hausa',
      ),
      PhotoQuizCategory(
        id: 'food',
        hausaName: 'Abinci',
        englishName: 'Food',
        icon: '🍲',
        color: 0xFFF44336,
        description: 'Abincin gargajiyar Hausawa',
      ),
      PhotoQuizCategory(
        id: 'traditional',
        hausaName: 'Kayan Gargajiya',
        englishName: 'Traditional Items',
        icon: '🎭',
        color: 0xFF9C27B0,
        description: 'Kayan al\'adun Hausawa na dā',
      ),
      PhotoQuizCategory(
        id: 'plants',
        hausaName: 'Tsire-tsire',
        englishName: 'Plants',
        icon: '🌳',
        color: 0xFF009688,
        description: 'Tsire-tsire da \'ya\'yan itatuwa',
      ),
    ];
  }

  static PhotoQuizCategory? getCategoryById(String id) {
    try {
      return getAllCategories().firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }
}

class PhotoQuizResult {
  final String category;
  final int totalQuestions;
  final int correctAnswers;
  final int timeSpent;
  final DateTime completedAt;

  PhotoQuizResult({
    required this.category,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeSpent,
    required this.completedAt,
  });

  double get scorePercentage => (correctAnswers / totalQuestions) * 100;

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'timeSpent': timeSpent,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory PhotoQuizResult.fromMap(Map<String, dynamic> map) {
    return PhotoQuizResult(
      category: map['category'] as String,
      totalQuestions: map['totalQuestions'] as int,
      correctAnswers: map['correctAnswers'] as int,
      timeSpent: map['timeSpent'] as int,
      completedAt: DateTime.parse(map['completedAt'] as String),
    );
  }
}