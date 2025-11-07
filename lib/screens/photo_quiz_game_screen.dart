// lib/screens/photo_quiz_game_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/photo_quiz_model.dart';
import '../services/photo_quiz_service.dart';
import 'photo_quiz_results_screen.dart';

class PhotoQuizGameScreen extends StatefulWidget {
  final PhotoQuizCategory category;
  final int questionCount;

  const PhotoQuizGameScreen({
    super.key,
    required this.category,
    required this.questionCount,
  });

  @override
  State<PhotoQuizGameScreen> createState() => _PhotoQuizGameScreenState();
}

class _PhotoQuizGameScreenState extends State<PhotoQuizGameScreen> with TickerProviderStateMixin {
  List<PhotoQuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int _currentStreak = 0;
  int _maxStreak = 0;
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
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _showConfetti = false;

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
      duration: const Duration(milliseconds: 1500),
    );
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      final questions = await PhotoQuizService.instance.generatePhotoQuiz(
        category: widget.category.id,
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
          SnackBar(content: Text('Kuskure wajen ɗora gwaji: $e')),
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
      _playSound('time_up');
      HapticFeedback.mediumImpact();
      _answerQuestion(-1);
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
      if (_currentStreak > _maxStreak) {
        _maxStreak = _currentStreak;
      }

      _playSound('correct');
      HapticFeedback.heavyImpact();
      _playCorrectAnimation();

      // Show confetti on 3+ streak
      if (_currentStreak >= 3) {
        setState(() => _showConfetti = true);
        _confettiController.forward().then((_) {
          setState(() => _showConfetti = false);
          _confettiController.reset();
        });
      }
    } else {
      _currentStreak = 0;
      _playSound('wrong');
      HapticFeedback.mediumImpact();
      _playWrongAnimation();
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _playSound(String sound) async {
    try {
      await _audioPlayer.play(AssetSource('audio/$sound.mp3'));
    } catch (e) {
      // Sound file might not exist, continue silently
    }
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

    final result = PhotoQuizResult(
      category: widget.category.id,
      totalQuestions: widget.questionCount,
      correctAnswers: _correctAnswers,
      timeSpent: _timeSpent,
      completedAt: DateTime.now(),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoQuizResultsScreen(
          result: result,
          category: widget.category,
          maxStreak: _maxStreak,
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
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(widget.category.hausaName),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFFFFB300)),
              SizedBox(height: 16),
              Text(
                'Ana shirya tambayoyi...',
                style: TextStyle(color: Colors.white70),
              ),
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
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text('Bar gwaji?', style: TextStyle(color: Color(0xFFFFB300))),
            content: const Text(
              'Ka tabbata kana son barin wannan gwaji?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('A\'a', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('I', style: TextStyle(color: Color(0xFFFFB300))),
              ),
            ],
          ),
        );

        if (shouldPop == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            'Tambaya ${_currentQuestionIndex + 1}/${_questions.length}',
            style: const TextStyle(color: Color(0xFFFFB300)),
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '⏱️ $_questionTimeRemaining',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _questionTimeRemaining <= 5
                        ? Colors.red
                        : const Color(0xFFFFB300),
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
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(widget.category.color),
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
                        _questionTimeRemaining <= 5 ? Colors.red : const Color(0xFFFFB300),
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
                        Row(
                          children: [
                            Expanded(
                              child: _buildScoreBadge(
                                icon: Icons.check_circle,
                                label: 'Daidai',
                                value: '$_correctAnswers',
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildScoreBadge(
                                icon: Icons.cancel,
                                label: 'Kuskure',
                                value: '${_currentQuestionIndex - _correctAnswers}',
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),

                        // Streak Indicator
                        if (_currentStreak >= 3) ...[
                          const SizedBox(height: 12),
                          Card(
                            color: const Color(0xFFFFB300).withValues(alpha:0.2),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _currentStreak >= 5 ? '🔥🔥' : '🔥',
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Ci gaba haka! $_currentStreak daidai a jere',
                                    style: const TextStyle(
                                      color: Color(0xFFFFB300),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Image Card
                        Card(
                          color: const Color(0xFF1E1E1E),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              height: 280,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Actual Image - Try multiple formats
                                  _buildImageWithFallback(currentQuestion.correctItem.imagePath),

                                  // Gradient overlay for better text visibility
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 80,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withValues(alpha: 0.7),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Question number badge
                                  Positioned(
                                    bottom: 16,
                                    left: 16,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(widget.category.color),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        '#${currentQuestion.id}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Question Text
                        Text(
                          'Mene ne sunan wannan?',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xFFFFB300),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
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

            // Confetti Animation
            if (_showConfetti)
              AnimatedBuilder(
                animation: _confettiController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(
                      MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height,
                    ),
                    painter: ConfettiPainter(_confettiController.value),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // Build image with multiple format fallbacks
  Widget _buildImageWithFallback(String imagePath) {
    // imagePath already contains full path like 'assets/images/animals/ram.jpg'
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // If the main path fails, show fallback
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(widget.category.color).withValues(alpha: 0.3),
                Color(widget.category.color).withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.category.icon,
                  style: const TextStyle(fontSize: 120),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hoton ba ya samuwa',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreBadge({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
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
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(int index, String option, int correctIndex) {
    final isSelected = _selectedOptionIndex == index;
    final isCorrect = index == correctIndex;
    final showResult = _answered;

    Color? backgroundColor;
    Color? borderColor;
    IconData? icon;

    if (showResult) {
      if (isCorrect) {
        backgroundColor = Colors.green.withValues(alpha:0.2);
        borderColor = Colors.green;
        icon = Icons.check_circle;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.withValues(alpha:0.2);
        borderColor = Colors.red;
        icon = Icons.cancel;
      }
    } else if (isSelected) {
      backgroundColor = const Color(0xFFFFB300).withValues(alpha:0.2);
      borderColor = const Color(0xFFFFB300);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: backgroundColor ?? const Color(0xFF1E1E1E),
        elevation: isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: borderColor ?? Colors.grey[700]!,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: _answered ? null : () => _answerQuestion(index),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (borderColor ?? Colors.grey[700])!.withValues(alpha:0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: icon != null
                        ? Icon(icon, color: borderColor, size: 24)
                        : Text(
                      String.fromCharCode(65 + index),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: borderColor ?? const Color(0xFFFFB300),
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: showResult && isCorrect
                          ? Colors.green
                          : Colors.white,
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

// Confetti Painter
class ConfettiPainter extends CustomPainter {
  final double progress;

  ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final colors = [
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.red,
      Colors.purple,
      Colors.pink,
    ];

    for (int i = 0; i < 50; i++) {
      final x = (i * 37) % size.width;
      final y = progress * size.height - (i * 23) % 200;

      if (y > 0 && y < size.height) {
        paint.color = colors[i % colors.length];
        canvas.drawCircle(
          Offset(x, y),
          5 + (i % 3) * 2,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}