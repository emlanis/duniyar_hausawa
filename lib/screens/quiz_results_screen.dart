// lib/screens/quiz_results_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/quiz_service.dart';
import 'quiz_game_screen.dart';

class QuizResultsScreen extends StatefulWidget {
  final int totalQuestions;
  final int correctAnswers;
  final int timeSpent;

  const QuizResultsScreen({
    super.key,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeSpent,
  });

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late QuizStats _stats;

  @override
  void initState() {
    super.initState();

    _stats = QuizService.instance.calculateStats(
      totalQuestions: widget.totalQuestions,
      correctAnswers: widget.correctAnswers,
      timeSpent: widget.timeSpent,
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _shareResults() {
    final text = '''
🇳🇬 Duniyar Hausawa - Kacici-Kacici

Tambayoyi: ${_stats.totalQuestions}
Daidai: ${_stats.correctAnswers} ✅
Kuskure: ${_stats.wrongAnswers} ❌
Maki: ${_stats.percentage}%
Daraja: ${_stats.grade}

${_stats.message}
''';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('An kwafi sakamakon!')),
    );
  }

  void _retryQuiz() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizGameScreen(
          questionCount: widget.totalQuestions,
        ),
      ),
    );
  }

  void _goHome() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final isExcellent = _stats.percentage >= 80;
    final isGood = _stats.percentage >= 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sakamakon Gwaji'),
        automaticallyImplyLeading: false,
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
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isExcellent
                          ? [Colors.green, Colors.green.shade700]
                          : isGood
                          ? [Colors.blue, Colors.blue.shade700]
                          : [Colors.orange, Colors.orange.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      // Grade
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
                    color: Colors.blue,
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

            _buildStatCard(
              icon: Icons.speed,
              label: 'Matsakaicin Lokaci kowace Tambaya',
              value: '${_stats.averageTime}s',
              color: Colors.purple,
            ),

            const SizedBox(height: 32),

            // Action Buttons
            ElevatedButton.icon(
              onPressed: _retryQuiz,
              icon: const Icon(Icons.refresh),
              label: const Text('Sake Gwadawa'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.black,
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _shareResults,
              icon: const Icon(Icons.share),
              label: const Text('Tura Sakamako'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 12),

            TextButton.icon(
              onPressed: _goHome,
              icon: const Icon(Icons.home),
              label: const Text('Koma Gida'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 24),

            // Motivational Message
            Card(
              color: isExcellent
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).colorScheme.secondary,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      isExcellent ? Icons.emoji_events : Icons.psychology,
                      size: 48,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getMotivationalMessage(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
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
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[400],
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
      return 'Kai ƙwaro! Ka ƙware sosai a karin magana!';
    } else if (_stats.percentage >= 80) {
      return 'Masha Allah! Ka yi ƙoƙari sosai! Ci gaba da haka!';
    } else if (_stats.percentage >= 70) {
      return 'Ka yi ƙoƙari! Amma in kana da kyau to ka ƙara da wanka !';
    } else if (_stats.percentage >= 60) {
      return 'Ba laifi! Amma zaka iya abinda ya fi haka!';
    } else if (_stats.percentage >= 50) {
      return 'Ka fi wani wani ya fi ka! Amma ƙara yin nazari za ka yi nasara sosai!';
    } else {
      return 'Kar ka damu! Ka ƙara gwadawa!';
    }
  }
}