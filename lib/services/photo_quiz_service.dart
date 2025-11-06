// lib/services/photo_quiz_service.dart

import '../models/photo_quiz_model.dart';
import '../data/photo_quiz_data.dart';

class PhotoQuizService {
  static final PhotoQuizService instance = PhotoQuizService._init();
  PhotoQuizService._init();

  /// Generate photo quiz questions for a specific category
  Future<List<PhotoQuizQuestion>> generatePhotoQuiz({
    required String category,
    required int questionCount,
  }) async {
    // Get all items for this category
    final categoryItems = PhotoQuizData.getItemsByCategory(category);

    if (categoryItems.length < questionCount) {
      throw Exception('Ba isassun hotuna ba don wannan nau\'in gwaji');
    }

    // Shuffle and select items for questions
    final shuffledItems = List<PhotoQuizItem>.from(categoryItems)..shuffle();
    final selectedItems = shuffledItems.take(questionCount).toList();

    List<PhotoQuizQuestion> questions = [];

    for (int i = 0; i < selectedItems.length; i++) {
      final correctItem = selectedItems[i];

      // Get wrong options from same category
      final wrongItems = categoryItems
          .where((item) => item.id != correctItem.id)
          .toList()
        ..shuffle();

      final wrongOptions = wrongItems
          .take(3)
          .map((item) => item.hausaName)
          .toList();

      // Create options list with correct answer
      final options = [...wrongOptions, correctItem.hausaName]..shuffle();
      final correctIndex = options.indexOf(correctItem.hausaName);

      questions.add(
        PhotoQuizQuestion(
          id: i + 1,
          correctItem: correctItem,
          options: options,
          correctOptionIndex: correctIndex,
          category: category,
        ),
      );
    }

    return questions;
  }

  /// Calculate statistics for photo quiz
  PhotoQuizStats calculateStats({
    required int totalQuestions,
    required int correctAnswers,
    required int timeSpent,
    required String category,
  }) {
    final percentage = (correctAnswers / totalQuestions * 100).round();
    final averageTime = (timeSpent / totalQuestions).round();

    String grade;
    String message;

    if (percentage >= 90) {
      grade = 'A+';
      message = 'Kai! Ƙa ƙware sosai!';
    } else if (percentage >= 80) {
      grade = 'A';
      message = 'Mai kyau ƙwarai!';
    } else if (percentage >= 70) {
      grade = 'B';
      message = 'Ƙwarai! Ka yi kyau!';
    } else if (percentage >= 60) {
      grade = 'C';
      message = 'Ba kwa lafiya! Ci gaba!';
    } else if (percentage >= 50) {
      grade = 'D';
      message = 'Ka yi ƙoƙari!';
    } else {
      grade = 'F';
      message = 'Ƙara nazari! Za ka iya!';
    }

    return PhotoQuizStats(
      category: category,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      wrongAnswers: totalQuestions - correctAnswers,
      percentage: percentage,
      timeSpent: timeSpent,
      averageTime: averageTime,
      grade: grade,
      message: message,
    );
  }
}

/// Photo Quiz Statistics Model
class PhotoQuizStats {
  final String category;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int percentage;
  final int timeSpent;
  final int averageTime;
  final String grade;
  final String message;

  PhotoQuizStats({
    required this.category,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.percentage,
    required this.timeSpent,
    required this.averageTime,
    required this.grade,
    required this.message,
  });
}