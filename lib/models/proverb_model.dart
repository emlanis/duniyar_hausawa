// lib/models/proverb_model.dart

class Proverb {
  final int id;
  final String hausa;
  final String? english;
  final String? meaningHausa;
  final String? meaningEnglish;
  final List<String> categories;
  final String difficulty;
  final String? audioUrl;
  final bool isFavorite;
  final String firstLetter;

  Proverb({
    required this.id,
    required this.hausa,
    this.english,
    this.meaningHausa,
    this.meaningEnglish,
    this.categories = const [],
    this.difficulty = 'medium',
    this.audioUrl,
    this.isFavorite = false,
    required this.firstLetter,
  });

  // Convert Proverb to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hausa': hausa,
      'english': english,
      'meaningHausa': meaningHausa,
      'meaningEnglish': meaningEnglish,
      'categories': categories.join(','),
      'difficulty': difficulty,
      'audioUrl': audioUrl,
      'isFavorite': isFavorite ? 1 : 0,
      'firstLetter': firstLetter,
    };
  }

  // Create Proverb from Map (database query result)
  factory Proverb.fromMap(Map<String, dynamic> map) {
    return Proverb(
      id: map['id'] as int,
      hausa: map['hausa'] as String,
      english: map['english'] as String?,
      meaningHausa: map['meaningHausa'] as String?,
      meaningEnglish: map['meaningEnglish'] as String?,
      categories: map['categories'] != null
          ? (map['categories'] as String).split(',')
          : [],
      difficulty: map['difficulty'] as String? ?? 'medium',
      audioUrl: map['audioUrl'] as String?,
      isFavorite: (map['isFavorite'] as int?) == 1,
      firstLetter: map['firstLetter'] as String,
    );
  }

  // Create a copy of Proverb with some fields changed
  Proverb copyWith({
    int? id,
    String? hausa,
    String? english,
    String? meaningHausa,
    String? meaningEnglish,
    List<String>? categories,
    String? difficulty,
    String? audioUrl,
    bool? isFavorite,
    String? firstLetter,
  }) {
    return Proverb(
      id: id ?? this.id,
      hausa: hausa ?? this.hausa,
      english: english ?? this.english,
      meaningHausa: meaningHausa ?? this.meaningHausa,
      meaningEnglish: meaningEnglish ?? this.meaningEnglish,
      categories: categories ?? this.categories,
      difficulty: difficulty ?? this.difficulty,
      audioUrl: audioUrl ?? this.audioUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      firstLetter: firstLetter ?? this.firstLetter,
    );
  }

  // Get the first letter for alphabetical grouping
  static String getFirstLetter(String text) {
    if (text.isEmpty) return 'A';
    String firstChar = text[0].toUpperCase();

    // Hausa alphabet including special characters
    const hausaAlphabet = [
      'A', 'B', 'Ɓ', 'C', 'D', 'Ɗ', 'E', 'F', 'G', 'H', 'I', 'J',
      'K', 'Ƙ', 'L', 'M', 'N', 'O', 'R', 'S', 'SH', 'T', 'U',
      'W', 'Y', 'Ƴ', 'Z', "'"
    ];

    // Check for digraphs like 'SH'
    if (text.length >= 2 && text.substring(0, 2).toUpperCase() == 'SH') {
      return 'SH';
    }

    // Return the character if it's in Hausa alphabet, otherwise 'A'
    return hausaAlphabet.contains(firstChar) ? firstChar : 'A';
  }
}

// Quiz Question Model
class QuizQuestion {
  final int id;
  final Proverb proverb;
  final List<String> options;
  final int correctOptionIndex;
  final String questionType; // 'complete', 'first_word', 'last_word', 'missing_word'
  final String questionText;

  QuizQuestion({
    required this.id,
    required this.proverb,
    required this.options,
    required this.correctOptionIndex,
    this.questionType = 'complete',
    required this.questionText,
  });

  String get correctAnswer => options[correctOptionIndex];
}

// Quiz Result Model
class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final int timeSpent; // in seconds
  final String difficulty;
  final DateTime completedAt;

  QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeSpent,
    required this.difficulty,
    required this.completedAt,
  });

  double get scorePercentage => (correctAnswers / totalQuestions) * 100;

  Map<String, dynamic> toMap() {
    return {
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'timeSpent': timeSpent,
      'difficulty': difficulty,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      totalQuestions: map['totalQuestions'] as int,
      correctAnswers: map['correctAnswers'] as int,
      timeSpent: map['timeSpent'] as int,
      difficulty: map['difficulty'] as String,
      completedAt: DateTime.parse(map['completedAt'] as String),
    );
  }
}