// lib/screens/photo_quiz_results_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/photo_quiz_model.dart';
import '../services/photo_quiz_service.dart';
import '../services/database_service.dart';
import 'photo_quiz_game_screen.dart';

class PhotoQuizResultsScreen extends StatefulWidget {
  final PhotoQuizResult result;
  final PhotoQuizCategory category;
  final int maxStreak;

  const PhotoQuizResultsScreen({
    super.key,
    required this.result,
    required this.category,
    required this.maxStreak,
  });

  @override
  State<PhotoQuizResultsScreen> createState() => _PhotoQuizResultsScreenState();
}

class _PhotoQuizResultsScreenState extends State<PhotoQuizResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late PhotoQuizStats _stats;

  @override
  void initState() {
    super.initState();

    _stats = PhotoQuizService.instance.calculateStats(
      totalQuestions: widget.result.totalQuestions,
      correctAnswers: widget.result.correctAnswers,
      timeSpent: widget.result.timeSpent,
      category: widget.result.category,
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();

    // Save photo quiz result to database
    _saveResultToDatabase();
  }

  Future<void> _saveResultToDatabase() async {
    try {
      await DatabaseService.instance.insertPhotoQuizResult({
        'category': widget.result.category,
        'totalQuestions': widget.result.totalQuestions,
        'correctAnswers': widget.result.correctAnswers,
        'timeSpent': widget.result.timeSpent,
        'completedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Silently fail - don't disrupt user experience
      debugPrint('Failed to save photo quiz result: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _shareResults() {
    final text = '''
📸 Duniyar Hausawa - ${widget.category.hausaName}

Tambayoyi: ${_stats.totalQuestions}
Daidai: ${_stats.correctAnswers} ✅
Kuskure: ${_stats.wrongAnswers} ❌
Maki: ${_stats.percentage}%
Daraja: ${_stats.grade}
Jere mafi girma: ${widget.maxStreak} 🔥

${_stats.message}
''';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('An kwafi sakamakon!'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _retryQuiz() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoQuizGameScreen(
          category: widget.category,
          questionCount: widget.result.totalQuestions,
        ),
      ),
    );
  }

  void _goHome() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Sakamakon Gwaji',
          style: TextStyle(color: Color(0xFFFFB300)),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Animated Result Card
            ScaleTransition(
              scale: _scaleAnimation,
              child: Card(
                color: const Color(0xFF1E1E1E),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(widget.category.color),
                        Color(widget.category.color).withValues(alpha:0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Text(
                        widget.category.icon,
                        style: const TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 16),

                      // Grade Circle
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha:0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _stats.grade,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Score Percentage
                      Text(
                        '${_stats.percentage}%',
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Message
                      Text(
                        _stats.message,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.check_circle,
                    label: 'Daidai',
                    value: '${_stats.correctAnswers}',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.cancel,
                    label: 'Kuskure',
                    value: '${_stats.wrongAnswers}',
                    color: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.quiz,
                    label: 'Tambayoyi',
                    value: '${_stats.totalQuestions}',
                    color: const Color(0xFFFFB300),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.timer,
                    label: 'Lokaci',
                    value: _formatTime(_stats.timeSpent),
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Max Streak Card
            if (widget.maxStreak >= 3)
              _buildStatCard(
                icon: Icons.local_fire_department,
                label: 'Jere mafi girma',
                value: '${widget.maxStreak} ${widget.maxStreak >= 5 ? "🔥🔥" : "🔥"}',
                color: const Color(0xFFFF6F00),
              ),

            const SizedBox(height: 32),

            // Action Buttons
            ElevatedButton.icon(
              onPressed: _retryQuiz,
              icon: const Icon(Icons.refresh),
              label: const Text('Sake Gwadawa'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Color(widget.category.color),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _shareResults,
              icon: const Icon(Icons.share),
              label: const Text('Raba Sakamako'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                side: const BorderSide(color: Color(0xFFFFB300)),
                foregroundColor: const Color(0xFFFFB300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextButton.icon(
              onPressed: _goHome,
              icon: const Icon(Icons.home),
              label: const Text('Koma Gida'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(16),
                foregroundColor: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            // Category Info Card
            Card(
              color: const Color(0xFF1E1E1E),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      widget.category.icon,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.category.hausaName,
                      style: const TextStyle(
                        color: Color(0xFFFFB300),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getMotivationalMessage(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    }
    return '${seconds}s';
  }

  String _getMotivationalMessage() {
    if (_stats.percentage >= 90) {
      return 'Kai! Ƙa ƙware sosai wajen ${widget.category.hausaName}!';
    } else if (_stats.percentage >= 80) {
      return 'Ƙwarai! Ka sani ${widget.category.hausaName} sosai!';
    } else if (_stats.percentage >= 70) {
      return 'Ka yi kyau! Ƙara nazari ${widget.category.hausaName}!';
    } else if (_stats.percentage >= 60) {
      return 'Ba kwa lafiya! Ci gaba da koyon ${widget.category.hausaName}!';
    } else {
      return 'Ƙara ƙoƙari! Za ka ƙware ${widget.category.hausaName}!';
    }
  }
}