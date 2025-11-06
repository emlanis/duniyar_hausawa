// lib/screens/proverb_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/proverb_model.dart';
import '../services/database_service.dart';

class ProverbDetailScreen extends StatefulWidget {
  final Proverb proverb;

  const ProverbDetailScreen({
    super.key,
    required this.proverb,
  });

  @override
  State<ProverbDetailScreen> createState() => _ProverbDetailScreenState();
}

class _ProverbDetailScreenState extends State<ProverbDetailScreen> {
  late Proverb _proverb;

  @override
  void initState() {
    super.initState();
    _proverb = widget.proverb;
  }

  Future<void> _toggleFavorite() async {
    final newFavoriteStatus = !_proverb.isFavorite;
    await DatabaseService.instance.toggleFavorite(
      _proverb.id,
      newFavoriteStatus,
    );

    setState(() {
      _proverb = _proverb.copyWith(isFavorite: newFavoriteStatus);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newFavoriteStatus
                ? 'An ƙara zuwa abubuwan da ka fi so'
                : 'An cire daga abubuwan da ka fi so',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _shareProverb() {
    Clipboard.setData(ClipboardData(text: _proverb.hausa));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('An kwafi karin magana!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _playAudio() {
    // TODO: Implement audio playback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sauraron murya yana zuwa nan gaba!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Karin Magana'),
        actions: [
          IconButton(
            icon: Icon(
              _proverb.isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
            onPressed: _toggleFavorite,
            tooltip: 'Ƙara zuwa abubuwan da ka fi so',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareProverb,
            tooltip: 'Raba',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main Proverb Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha:0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha:0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.format_quote,
                    size: 48,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _proverb.hausa,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Audio Button
                  ElevatedButton.icon(
                    onPressed: _playAudio,
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Saurara'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // English Translation (if available)
            if (_proverb.english != null) ...[
              _buildSection(
                context,
                icon: Icons.translate,
                title: 'Fassara (English)',
                content: _proverb.english!,
                color: Colors.blue,
              ),
            ],

            // Hausa Meaning (if available)
            if (_proverb.meaningHausa != null) ...[
              _buildSection(
                context,
                icon: Icons.info_outline,
                title: 'Ma\'ana (Hausa)',
                content: _proverb.meaningHausa!,
                color: Colors.green,
              ),
            ],

            // English Meaning (if available)
            if (_proverb.meaningEnglish != null) ...[
              _buildSection(
                context,
                icon: Icons.lightbulb_outline,
                title: 'Meaning (English)',
                content: _proverb.meaningEnglish!,
                color: Colors.orange,
              ),
            ],

            // Metadata
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bayani',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        icon: Icons.sort_by_alpha,
                        label: 'Harafi',
                        value: _proverb.firstLetter,
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        context,
                        icon: Icons.signal_cellular_alt,
                        label: 'Matsayi',
                        value: _getDifficultyText(_proverb.difficulty),
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        context,
                        icon: Icons.numbers,
                        label: 'Lamba',
                        value: '#${_proverb.id}',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String content,
        required Color color,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
      }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getDifficultyText(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return 'Sauƙi';
      case 'medium':
        return 'Matsakaici';
      case 'hard':
        return 'Wuya';
      default:
        return 'Matsakaici';
    }
  }
}