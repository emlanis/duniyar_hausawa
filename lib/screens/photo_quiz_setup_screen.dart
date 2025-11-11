// lib/screens/photo_quiz_setup_screen.dart

import 'package:flutter/material.dart';
import '../models/photo_quiz_model.dart';
import 'photo_quiz_game_screen.dart';

class PhotoQuizSetupScreen extends StatelessWidget {
  final PhotoQuizCategory category;

  const PhotoQuizSetupScreen({
    super.key,
    required this.category,
  });

  void _startQuiz(BuildContext context, int questionCount) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoQuizGameScreen(
          category: category,
          questionCount: questionCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(category.hausaName),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category Header
            Card(
              color: const Color(0xFF1E1E1E),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Color(category.color),
                      Color(category.color).withValues(alpha:0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      category.icon,
                      style: const TextStyle(fontSize: 80),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      category.hausaName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'A zaɓi yawan tambayoyin da ake so',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFFFFB300),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Question Count Options
            _buildQuizOption(
              context,
              count: 5,
              title: 'Tambayoyi 5',
              subtitle: '~2 minti',
              icon: Icons.flash_on,
              color: Color(category.color),
            ),

            const SizedBox(height: 12),

            _buildQuizOption(
              context,
              count: 10,
              title: 'Tambayoyi 10',
              subtitle: '~3 minti',
              icon: Icons.timer,
              color: Color(category.color),
            ),

            const SizedBox(height: 12),

            _buildQuizOption(
              context,
              count: 20,
              title: 'Tambayoyi 20',
              subtitle: '~7 minti',
              icon: Icons.emoji_events,
              color: Color(category.color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizOption(
      BuildContext context, {
        required int count,
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
      }) {
    return Card(
      color: const Color(0xFF1E1E1E),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color.withValues(alpha:0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _startQuiz(context, count),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFFFFB300),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}