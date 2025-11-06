// lib/screens/quiz_screen.dart

import 'package:flutter/material.dart';
import 'quiz_game_screen.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kacici-Kacici'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.quiz,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Gwajin Karin Magana',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Gwada sanin ku game da karin maganar Hausa',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Quick Quiz Options
            _buildQuizOptionCard(
              context,
              title: 'Gwaji Mai Sauri',
              subtitle: 'Tambayoyi 5',
              icon: Icons.flash_on,
              color: Theme.of(context).primaryColor, // Yellow
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuizGameScreen(questionCount: 5),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            _buildQuizOptionCard(
              context,
              title: 'Gwaji Matsakaici',
              subtitle: 'Tambayoyi 10',
              icon: Icons.sports_score,
              color: Theme.of(context).colorScheme.secondary, // Light green
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuizGameScreen(questionCount: 10),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            _buildQuizOptionCard(
              context,
              title: 'Gwaji Mai Tsanani',
              subtitle: 'Tambayoyi 20',
              icon: Icons.emoji_events,
              color: Theme.of(context).colorScheme.tertiary, // Deep blue
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuizGameScreen(questionCount: 20),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}