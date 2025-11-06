// lib/services/quiz_service.dart

import 'dart:math';
import '../models/proverb_model.dart';
import 'database_service.dart';

class QuizService {
  static final QuizService instance = QuizService._init();
  QuizService._init();

  final Random _random = Random();

  /// Generate quiz questions from the proverb database
  Future<List<QuizQuestion>> generateQuiz({
    required int questionCount,
    String difficulty = 'mixed',
  }) async {
    final db = DatabaseService.instance;

    // Get random proverbs for questions
    final proverbs = await db.getRandomProverbs(questionCount * 4);

    if (proverbs.length < questionCount) {
      throw Exception('Not enough proverbs to generate quiz');
    }

    List<QuizQuestion> questions = [];

    for (int i = 0; i < questionCount; i++) {
      final correctProverb = proverbs[i];
      final questionType = _getRandomQuestionType();

      // Get wrong options (other proverbs)
      final wrongProverbs = proverbs
          .where((p) => p.id != correctProverb.id)
          .toList()
        ..shuffle();

      final question = _createQuestion(
        id: i + 1,
        proverb: correctProverb,
        wrongProverbs: wrongProverbs.take(3).toList(),
        questionType: questionType,
      );

      questions.add(question);
    }

    return questions;
  }

  /// Create a quiz question based on type
  QuizQuestion _createQuestion({
    required int id,
    required Proverb proverb,
    required List<Proverb> wrongProverbs,
    required String questionType,
  }) {
    switch (questionType) {
      case 'complete':
        return _createCompleteProverbQuestion(id, proverb, wrongProverbs);
      case 'first_word':
        return _createFirstWordQuestion(id, proverb, wrongProverbs);
      case 'last_word':
        return _createLastWordQuestion(id, proverb, wrongProverbs);
      case 'missing_word':
        return _createMissingWordQuestion(id, proverb, wrongProverbs);
      default:
        return _createCompleteProverbQuestion(id, proverb, wrongProverbs);
    }
  }

  /// Question Type: Complete the proverb
  QuizQuestion _createCompleteProverbQuestion(
      int id,
      Proverb proverb,
      List<Proverb> wrongProverbs,
      ) {
    final words = proverb.hausa.split(' ');

    // Show first half, complete second half
    final splitPoint = (words.length / 2).ceil();
    final firstHalf = words.take(splitPoint).join(' ');
    final secondHalf = words.skip(splitPoint).join(' ');

    // Create options
    List<String> options = [secondHalf];

    // Add wrong options (second half of other proverbs)
    for (var wrongProverb in wrongProverbs) {
      final wrongWords = wrongProverb.hausa.split(' ');
      final wrongSplitPoint = (wrongWords.length / 2).ceil();
      final wrongSecondHalf = wrongWords.skip(wrongSplitPoint).join(' ');
      options.add(wrongSecondHalf);
    }

    options.shuffle();
    final correctIndex = options.indexOf(secondHalf);

    return QuizQuestion(
      id: id,
      proverb: proverb,
      options: options,
      correctOptionIndex: correctIndex,
      questionType: 'complete',
      questionText: 'Kammala karin magana: "$firstHalf..."',
    );
  }

  /// Question Type: What's the first word?
  QuizQuestion _createFirstWordQuestion(
      int id,
      Proverb proverb,
      List<Proverb> wrongProverbs,
      ) {
    final words = proverb.hausa.split(' ');
    final firstWord = words.first;
    final restOfProverb = words.skip(1).join(' ');

    // Create options
    List<String> options = [firstWord];

    for (var wrongProverb in wrongProverbs) {
      final wrongWords = wrongProverb.hausa.split(' ');
      if (wrongWords.isNotEmpty) {
        options.add(wrongWords.first);
      }
    }

    options.shuffle();
    final correctIndex = options.indexOf(firstWord);

    return QuizQuestion(
      id: id,
      proverb: proverb,
      options: options,
      correctOptionIndex: correctIndex,
      questionType: 'first_word',
      questionText: 'Wace kalma ce ta farko?\n"___ $restOfProverb"',
    );
  }

  /// Question Type: What's the last word?
  QuizQuestion _createLastWordQuestion(
      int id,
      Proverb proverb,
      List<Proverb> wrongProverbs,
      ) {
    final words = proverb.hausa.split(' ');
    final lastWord = words.last;
    final restOfProverb = words.take(words.length - 1).join(' ');

    // Create options
    List<String> options = [lastWord];

    for (var wrongProverb in wrongProverbs) {
      final wrongWords = wrongProverb.hausa.split(' ');
      if (wrongWords.isNotEmpty) {
        options.add(wrongWords.last);
      }
    }

    options.shuffle();
    final correctIndex = options.indexOf(lastWord);

    return QuizQuestion(
      id: id,
      proverb: proverb,
      options: options,
      correctOptionIndex: correctIndex,
      questionType: 'last_word',
      questionText: 'Wace kalma ce ta ƙarshe?\n"$restOfProverb ___"',
    );
  }

  /// Question Type: Fill in missing word (middle of proverb)
  QuizQuestion _createMissingWordQuestion(
      int id,
      Proverb proverb,
      List<Proverb> wrongProverbs,
      ) {
    final words = proverb.hausa.split(' ');

    if (words.length < 3) {
      // Fall back to complete question if proverb too short
      return _createCompleteProverbQuestion(id, proverb, wrongProverbs);
    }

    // Pick a word from the middle
    final missingWordIndex = _random.nextInt(words.length - 2) + 1;
    final missingWord = words[missingWordIndex];

    // Create question with blank
    words[missingWordIndex] = '___';
    final questionProverb = words.join(' ');

    // Create options
    List<String> options = [missingWord];

    for (var wrongProverb in wrongProverbs) {
      final wrongWords = wrongProverb.hausa.split(' ');
      if (wrongWords.length > missingWordIndex) {
        options.add(wrongWords[missingWordIndex]);
      }
    }

    options.shuffle();
    final correctIndex = options.indexOf(missingWord);

    return QuizQuestion(
      id: id,
      proverb: proverb,
      options: options,
      correctOptionIndex: correctIndex,
      questionType: 'missing_word',
      questionText: 'Cika gurbin da ya ɓace:\n"$questionProverb"',
    );
  }

  /// Get random question type
  String _getRandomQuestionType() {
    const types = ['complete', 'first_word', 'last_word', 'missing_word'];
    return types[_random.nextInt(types.length)];
  }

  /// Calculate quiz score and statistics
  QuizStats calculateStats({
    required int totalQuestions,
    required int correctAnswers,
    required int timeSpent,
  }) {
    final percentage = (correctAnswers / totalQuestions * 100).round();
    final averageTime = (timeSpent / totalQuestions).round();

    String grade;
    String message;

    if (percentage >= 90) {
      grade = 'A+';
      message = 'Kai! Ƙwararre ne!';
    } else if (percentage >= 80) {
      grade = 'A';
      message = 'Mai kyau sosai!';
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
      message = 'Ƙara ƙoƙari! Za ka iya!';
    }

    return QuizStats(
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

/// Quiz Statistics Model
class QuizStats {
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int percentage;
  final int timeSpent;
  final int averageTime;
  final String grade;
  final String message;

  QuizStats({
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