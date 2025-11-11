// lib/screens/leaderboard_screen.dart

import 'package:flutter/material.dart';
import '../models/leaderboard_entry.dart';
import '../services/leaderboard_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final LeaderboardService _leaderboardService = LeaderboardService();
  late Stream<List<LeaderboardEntry>> _leaderboardStream;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _leaderboardStream = _leaderboardService.streamLeaderboard(limit: 100);
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    final userId = await _leaderboardService.getUserId();
    setState(() {
      _currentUserId = userId;
    });
  }

  Future<void> _showUsernameDialog() async {
    final currentUsername = await _leaderboardService.getUsername();
    final controller = TextEditingController(text: currentUsername);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saita Sunan Ka'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Suna',
            hintText: 'Dan Hausa',
          ),
          maxLength: 20,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Soke'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await _leaderboardService.setUsername(controller.text.trim());
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('An aje sunan!')),
                  );
                }
              }
            },
            child: const Text('Ajiye'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teburin Gwanaye'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showUsernameDialog,
            tooltip: 'Aje Suna',
          ),
        ],
      ),
      body: StreamBuilder<List<LeaderboardEntry>>(
        stream: _leaderboardStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Kuskure: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _leaderboardStream = _leaderboardService.streamLeaderboard();
                    }),
                    child: const Text('Sake Gwadawa'),
                  ),
                ],
              ),
            );
          }

          final entries = snapshot.data ?? [];

          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Har yanzu ba\'a fafata a gasar tambayoyi ba!',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Fara shiga gasar dan yin na farko',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Find current user
          final currentUserEntry = entries.firstWhere(
            (e) => e.userId == _currentUserId,
            orElse: () => LeaderboardEntry(
              userId: '',
              username: '',
              totalScore: 0,
              totalQuizzes: 0,
              averageScore: 0,
              level: 'Mai Fara Koyo',
              lastUpdated: DateTime.now(),
            ),
          );

          return Column(
            children: [
              // Top 3 Podium
              if (entries.length >= 3) _buildPodium(entries.take(3).toList()),

              // Current User Card
              if (_currentUserId != null && currentUserEntry.userId.isNotEmpty)
                _buildCurrentUserCard(currentUserEntry),

              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Divider(),
              ),

              // All Rankings
              Expanded(
                child: ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final isCurrentUser = entry.userId == _currentUserId;
                    return _buildLeaderboardTile(entry, isCurrentUser);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> topThree) {
    // Ensure we have exactly 3 entries
    while (topThree.length < 3) {
      topThree.add(LeaderboardEntry(
        userId: '',
        username: '-',
        totalScore: 0,
        totalQuizzes: 0,
        averageScore: 0,
        level: '',
        lastUpdated: DateTime.now(),
      ));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          _buildPodiumPlace(
            entry: topThree[1],
            rank: 2,
            height: 100,
            color: Colors.grey,
          ),
          const SizedBox(width: 8),
          // 1st Place
          _buildPodiumPlace(
            entry: topThree[0],
            rank: 1,
            height: 140,
            color: const Color(0xFFFFB300), // Gold
          ),
          const SizedBox(width: 8),
          // 3rd Place
          _buildPodiumPlace(
            entry: topThree[2],
            rank: 3,
            height: 80,
            color: const Color(0xFFCD7F32), // Bronze
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace({
    required LeaderboardEntry entry,
    required int rank,
    required double height,
    required Color color,
  }) {
    String medal = '';
    if (rank == 1) medal = '🥇';
    if (rank == 2) medal = '🥈';
    if (rank == 3) medal = '🥉';

    return Column(
      children: [
        // User Info
        Container(
          width: 80,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                medal,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 4),
              Text(
                entry.username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${entry.averageScore.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Podium Block
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentUserCard(LeaderboardEntry entry) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB300), Color(0xFF81C784)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Matsayina',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '#${entry.rank}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Matsayi',
                    style: TextStyle(color: Colors.black87, fontSize: 12),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    '${entry.averageScore.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Matsakaici',
                    style: TextStyle(color: Colors.black87, fontSize: 12),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    '${entry.totalQuizzes}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Kacici-kacici',
                    style: TextStyle(color: Colors.black87, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTile(LeaderboardEntry entry, bool isCurrentUser) {
    Color? tileColor;
    if (isCurrentUser) {
      tileColor = Theme.of(context).primaryColor.withValues(alpha: 0.1);
    }

    String rankDisplay = '#${entry.rank}';
    Color rankColor = Colors.grey;

    if (entry.rank == 1) {
      rankDisplay = '🥇';
      rankColor = const Color(0xFFFFB300);
    } else if (entry.rank == 2) {
      rankDisplay = '🥈';
      rankColor = Colors.grey;
    } else if (entry.rank == 3) {
      rankDisplay = '🥉';
      rankColor = const Color(0xFFCD7F32);
    }

    return ListTile(
      tileColor: tileColor,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: rankColor.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: rankColor, width: 2),
        ),
        child: Center(
          child: Text(
            entry.rank <= 3 ? rankDisplay : '#${entry.rank}',
            style: TextStyle(
              color: rankColor,
              fontWeight: FontWeight.bold,
              fontSize: entry.rank <= 3 ? 20 : 16,
            ),
          ),
        ),
      ),
      title: Text(
        entry.username,
        style: TextStyle(
          fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text('${entry.level} • ${entry.totalQuizzes} kacici-kacici'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${entry.averageScore.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFB300),
            ),
          ),
          Text(
            '${entry.totalScore} maki',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}