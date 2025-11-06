// lib/screens/quiz_game_screen.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/proverb_model.dart';
import '../services/quiz_service.dart';
import '../services/database_service.dart';
import 'quiz_results_screen.dart';

class QuizGameScreen extends StatefulWidget {
  final int questionCount;

  const QuizGameScreen({
    super.key,
    required this.questionCount,
  });

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> with TickerProviderStateMixin {
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int _timeSpent = 0;
  int _questionTimeRemaining = 20;
  bool _isLoading = true;
  bool _answered = false;
  int? _selectedOptionIndex;
  Timer? _questionTimer;
  Timer? _totalTimer;
  late AnimationController _progressController;
  late AnimationController _feedbackController;
  late AnimationController _confettiController;

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Streak tracking
  int _currentStreak = 0;
  int _bestStreak = 0;
  bool _showStreakAnimation = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      final questions = await QuizService.instance.generateQuiz(
        questionCount: widget.questionCount,
      );

      setState(() {
        _questions = questions;
        _isLoading = false;
      });

      _startQuestionTimer();
      _startTotalTimer();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading quiz: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  void _startQuestionTimer() {
    _questionTimeRemaining = 20;
    _progressController.reset();
    _progressController.forward();

    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_questionTimeRemaining > 0) {
        setState(() {
          _questionTimeRemaining--;
        });
      } else {
        _timeUp();
      }
    });
  }

  void _startTotalTimer() {
    _totalTimer?.cancel();
    _totalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timeSpent++;
    });
  }

  void _timeUp() {
    if (!_answered) {
      _playTimeUpSound();
      HapticFeedback.vibrate();
      _answerQuestion(-1); // -1 means time up, no answer selected
    }
  }

  void _answerQuestion(int selectedIndex) {
    if (_answered) return;

    _questionTimer?.cancel();
    _progressController.stop();

    setState(() {
      _answered = true;
      _selectedOptionIndex = selectedIndex;
    });

    final isCorrect = selectedIndex == _questions[_currentQuestionIndex].correctOptionIndex;

    if (isCorrect) {
      _correctAnswers++;
      _currentStreak++;
      if (_currentStreak > _bestStreak) {
        _bestStreak = _currentStreak;
      }
      _playCorrectAnimation();
      _playCorrectSound();
      HapticFeedback.heavyImpact();

      // Show confetti for streak of 3 or more
      if (_currentStreak >= 3) {
        _confettiController.forward(from: 0);
        setState(() {
          _showStreakAnimation = true;
        });
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              _showStreakAnimation = false;
            });
          }
        });
      }
    } else {
      _currentStreak = 0; // Reset streak on wrong answer
      _playWrongAnimation();
      _playWrongSound();
      HapticFeedback.vibrate();
    }

    // Move to next question after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _playCorrectAnimation() {
    _feedbackController.forward().then((_) {
      _feedbackController.reverse();
    });
  }

  void _playWrongAnimation() {
    _feedbackController.forward().then((_) {
      _feedbackController.reverse();
    });
  }

  Future<void> _playCorrectSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/correct.mp3'));
    } catch (e) {
      // Silently fail if audio file doesn't exist yet
      debugPrint('Error playing correct sound: $e');
    }
  }

  Future<void> _playWrongSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/wrong.mp3'));
    } catch (e) {
      // Silently fail if audio file doesn't exist yet
      debugPrint('Error playing wrong sound: $e');
    }
  }

  Future<void> _playTimeUpSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/time_up.mp3'));
    } catch (e) {
      // Silently fail if audio file doesn't exist yet
      debugPrint('Error playing time up sound: $e');
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answered = false;
        _selectedOptionIndex = null;
      });
      _startQuestionTimer();
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    _questionTimer?.cancel();
    _totalTimer?.cancel();

    // Save result to database
    final result = QuizResult(
      totalQuestions: widget.questionCount,
      correctAnswers: _correctAnswers,
      timeSpent: _timeSpent,
      difficulty: 'mixed',
      completedAt: DateTime.now(),
    );

    DatabaseService.instance.insertQuizResult(result);

    // Navigate to results screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultsScreen(
          totalQuestions: widget.questionCount,
          correctAnswers: _correctAnswers,
          timeSpent: _timeSpent,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _totalTimer?.cancel();
    _progressController.dispose();
    _feedbackController.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kacici-Kacici')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Ana shirya tambayoyi...'),
            ],
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Bar gwaji?'),
            content: const Text('Ka tabbata kana son barin wannan gwaji?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('A\'a'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('I'),
              ),
            ],
          ),
        );

        if (shouldPop == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tambaya ${_currentQuestionIndex + 1}/${_questions.length}'),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '⏱️ $_questionTimeRemaining',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _questionTimeRemaining <= 5 ? Colors.red : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // Progress Bar
                LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
              minHeight: 8,
            ),

            // Timer Progress
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: 1 - _progressController.value,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _questionTimeRemaining <= 5 ? Colors.red : Colors.orange,
                  ),
                  minHeight: 4,
                );
              },
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Score Display
                    Card(
                      color: Theme.of(context).colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildScoreBadge(
                              icon: Icons.check_circle,
                              label: 'Daidai',
                              value: '$_correctAnswers',
                              color: const Color(0xFF81C784), // Light green
                            ),
                            _buildScoreBadge(
                              icon: Icons.cancel,
                              label: 'Kuskure',
                              value: '${_currentQuestionIndex - _correctAnswers}',
                              color: Colors.red,
                            ),
                            _buildScoreBadge(
                              icon: Icons.timer,
                              label: 'Lokaci',
                              value: '${_timeSpent}s',
                              color: const Color(0xFF1565C0), // Deep blue
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Streak Indicator
                    if (_currentStreak > 0)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: Card(
                          color: _currentStreak >= 3
                              ? const Color(0xFFFFB300).withValues(alpha:0.9)
                              : Theme.of(context).colorScheme.surface,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _currentStreak >= 5
                                      ? Icons.local_fire_department
                                      : Icons.whatshot,
                                  color: _currentStreak >= 3
                                      ? Colors.black
                                      : const Color(0xFFFFB300),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Ci gaba haka! $_currentStreak daidai a jere',
                                  style: TextStyle(
                                    color: _currentStreak >= 3
                                        ? Colors.black
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Question Card
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              currentQuestion.questionText,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Options
                    ...List.generate(
                      currentQuestion.options.length,
                          (index) => _buildOptionCard(
                        index,
                        currentQuestion.options[index],
                        currentQuestion.correctOptionIndex,
                      ),
                    ),
                  ],
                ),
              ),
            ),
              ],
            ),

            // Confetti Overlay
            if (_showStreakAnimation)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _confettiController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: ConfettiPainter(_confettiController.value),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBadge({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard(int index, String option, int correctIndex) {
    final isSelected = _selectedOptionIndex == index;
    final isCorrect = index == correctIndex;
    final showResult = _answered;

    Color? backgroundColor;
    Color? borderColor;
    Color? textColor;
    IconData? icon;

    if (showResult) {
      if (isCorrect) {
        backgroundColor = const Color(0xFF81C784); // Light green
        borderColor = const Color(0xFF81C784);
        textColor = Colors.black;
        icon = Icons.check_circle;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red[700];
        borderColor = Colors.red;
        textColor = Colors.white;
        icon = Icons.cancel;
      } else {
        backgroundColor = Theme.of(context).colorScheme.surface;
        borderColor = Colors.grey[700];
        textColor = Colors.white;
      }
    } else if (isSelected) {
      backgroundColor = Theme.of(context).primaryColor;
      borderColor = Theme.of(context).primaryColor;
      textColor = Colors.black;
    } else {
      backgroundColor = Theme.of(context).colorScheme.surface;
      borderColor = Colors.grey[700];
      textColor = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        elevation: isSelected ? 4 : 1,
        child: InkWell(
          onTap: _answered ? null : () => _answerQuestion(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor ?? Colors.grey[700]!,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: textColor == Colors.black
                        ? Colors.black.withValues(alpha:0.1)
                        : Colors.white.withValues(alpha:0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: icon != null
                        ? Icon(icon, color: textColor, size: 20)
                        : Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Confetti Painter for visual celebration
class ConfettiPainter extends CustomPainter {
  final double animationValue;
  final math.Random random = math.Random(42); // Fixed seed for consistent pattern

  ConfettiPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Generate 50 confetti pieces
    for (int i = 0; i < 50; i++) {
      final x = (i * 37) % size.width; // Spread across width
      final startY = -50.0 - (i * 10 % 100); // Start above screen
      final y = startY + (size.height + 100) * animationValue; // Fall down

      // Skip if not visible
      if (y < -20 || y > size.height + 20) continue;

      // Rotate confetti
      final rotation = (i * 0.5 + animationValue * 4) % (2 * math.pi);

      // Different colors
      final colors = [
        const Color(0xFFFFB300), // Yellow
        const Color(0xFF81C784), // Green
        const Color(0xFF1565C0), // Blue
        Colors.red,
        Colors.purple,
        Colors.pink,
      ];
      paint.color = colors[i % colors.length];

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      // Draw confetti shape (small rectangle)
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: 8,
        height: 12,
      );
      canvas.drawRect(rect, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}