import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/proverb_model.dart';

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({super.key});

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<QuizResult> _proverbQuizzes = [];
  List<Map<String, dynamic>> _photoQuizzes = [];
  bool _isLoading = true;

  // Statistics
  int _totalQuizzes = 0;
  double _averageScore = 0.0;
  int _bestScore = 0;
  int _totalCorrect = 0;
  int _totalQuestions = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadQuizHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadQuizHistory() async {
    setState(() => _isLoading = true);

    final db = DatabaseService.instance;
    final proverbQuizzes = await db.getAllQuizResults();
    final photoQuizzes = await db.getAllPhotoQuizResults();

    // Calculate combined statistics
    int totalCorrect = 0;
    int totalQuestions = 0;
    int bestScore = 0;

    // Add proverb quiz stats
    for (var quiz in proverbQuizzes) {
      totalCorrect += quiz.correctAnswers;
      totalQuestions += quiz.totalQuestions;
      final score = ((quiz.correctAnswers / quiz.totalQuestions) * 100).round();
      if (score > bestScore) bestScore = score;
    }

    // Add photo quiz stats
    for (var quiz in photoQuizzes) {
      final correct = quiz['correctAnswers'] as int;
      final total = quiz['totalQuestions'] as int;
      totalCorrect += correct;
      totalQuestions += total;
      final score = ((correct / total) * 100).round();
      if (score > bestScore) bestScore = score;
    }

    final totalQuizCount = proverbQuizzes.length + photoQuizzes.length;
    final avgScore = totalQuestions > 0 ? (totalCorrect / totalQuestions) * 100 : 0.0;

    setState(() {
      _proverbQuizzes = proverbQuizzes;
      _photoQuizzes = photoQuizzes;
      _totalQuizzes = totalQuizCount;
      _averageScore = avgScore;
      _bestScore = bestScore;
      _totalCorrect = totalCorrect;
      _totalQuestions = totalQuestions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarihin Gwaje-gwaje'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black54,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: 'Karin Magana', icon: Icon(Icons.book, size: 20)),
            Tab(text: 'Hotuna', icon: Icon(Icons.image, size: 20)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Statistics Header
                _buildStatisticsHeader(),
                const Divider(height: 1),
                // Quiz History Tabs
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProverbQuizList(),
                      _buildPhotoQuizList(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatisticsHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Jimillar Gwaje-gwaje',
                  '$_totalQuizzes',
                  Icons.quiz,
                  Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Matsakaicin Maki',
                  '${_averageScore.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Mafi Girman Maki',
                  '$_bestScore%',
                  Icons.emoji_events,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Daidai',
                  '$_totalCorrect/$_totalQuestions',
                  Icons.check_circle,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProverbQuizList() {
    if (_proverbQuizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 80,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Ba ka yi gwajin karin magana tukuna',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Ka fara gwaji don ganin ci gaban ka!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _proverbQuizzes.length,
      itemBuilder: (context, index) {
        final quiz = _proverbQuizzes[_proverbQuizzes.length - 1 - index];
        return _buildProverbQuizCard(quiz, index);
      },
    );
  }

  Widget _buildProverbQuizCard(QuizResult quiz, int index) {
    final score = ((quiz.correctAnswers / quiz.totalQuestions) * 100).round();
    final date = DateFormat('MMM dd, yyyy - HH:mm').format(quiz.completedAt);

    Color scoreColor;
    IconData scoreIcon;
    String scoreLabel;

    if (score >= 80) {
      scoreColor = Colors.green;
      scoreIcon = Icons.emoji_events;
      scoreLabel = 'Maƙwarai!';
    } else if (score >= 60) {
      scoreColor = Colors.blue;
      scoreIcon = Icons.thumb_up;
      scoreLabel = 'Mai kyau!';
    } else if (score >= 40) {
      scoreColor = Colors.orange;
      scoreIcon = Icons.trending_up;
      scoreLabel = 'Ci gaba!';
    } else {
      scoreColor = Colors.red;
      scoreIcon = Icons.school;
      scoreLabel = 'Ka ƙara ƙoƙari!';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showQuizDetails(quiz),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Score Circle
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scoreColor.withValues(alpha: 0.2),
                  border: Border.all(color: scoreColor, width: 3),
                ),
                child: Center(
                  child: Text(
                    '$score%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Quiz Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(scoreIcon, color: scoreColor, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          scoreLabel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: scoreColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${quiz.correctAnswers} daidai daga ${quiz.totalQuestions}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoQuizList() {
    if (_photoQuizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 80,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Ba ka yi gwajin hotuna tukuna',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Ka fara gwaji don ganin ci gaban ka!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _photoQuizzes.length,
      itemBuilder: (context, index) {
        final quiz = _photoQuizzes[_photoQuizzes.length - 1 - index];
        return _buildPhotoQuizCard(quiz, index);
      },
    );
  }

  Widget _buildPhotoQuizCard(Map<String, dynamic> quiz, int index) {
    final correct = quiz['correctAnswers'] as int;
    final total = quiz['totalQuestions'] as int;
    final score = ((correct / total) * 100).round();
    final category = quiz['category'] as String;
    final timestamp = quiz['completedAt'] as String;
    final date = DateFormat('MMM dd, yyyy - HH:mm').format(DateTime.parse(timestamp));

    Color scoreColor;
    IconData scoreIcon;
    String scoreLabel;

    if (score >= 80) {
      scoreColor = Colors.green;
      scoreIcon = Icons.emoji_events;
      scoreLabel = 'Maƙwarai!';
    } else if (score >= 60) {
      scoreColor = Colors.blue;
      scoreIcon = Icons.thumb_up;
      scoreLabel = 'Mai kyau!';
    } else if (score >= 40) {
      scoreColor = Colors.orange;
      scoreIcon = Icons.trending_up;
      scoreLabel = 'Ci gaba!';
    } else {
      scoreColor = Colors.red;
      scoreIcon = Icons.school;
      scoreLabel = 'Ka ƙara ƙoƙari!';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showPhotoQuizDetails(quiz),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Score Circle
              Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scoreColor.withValues(alpha: 0.2),
                border: Border.all(color: scoreColor, width: 3),
              ),
              child: Center(
                child: Text(
                  '$score%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Quiz Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(scoreIcon, color: scoreColor, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        scoreLabel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$correct daidai daga $total ($category)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _showQuizDetails(QuizResult quiz) {
    final score = ((quiz.correctAnswers / quiz.totalQuestions) * 100).round();
    final date = DateFormat('MMMM dd, yyyy').format(quiz.completedAt);
    final time = DateFormat('HH:mm').format(quiz.completedAt);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cikakken Bayani'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Maki:', '$score%', score >= 70 ? Colors.green : Colors.orange),
            const Divider(),
            _buildDetailRow('Daidai:', '${quiz.correctAnswers}', Colors.green),
            _buildDetailRow('Kuskure:', '${quiz.totalQuestions - quiz.correctAnswers}', Colors.red),
            _buildDetailRow('Jimillar Tambayoyi:', '${quiz.totalQuestions}', Colors.blue),
            const Divider(),
            _buildDetailRow('Ranar:', date, Theme.of(context).primaryColor),
            _buildDetailRow('Lokaci:', time, Theme.of(context).primaryColor),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Rufe'),
          ),
        ],
      ),
    );
  }

  void _showPhotoQuizDetails(Map<String, dynamic> quiz) {
    final correct = quiz['correctAnswers'] as int;
    final total = quiz['totalQuestions'] as int;
    final category = quiz['category'] as String;
    final timestamp = quiz['completedAt'] as String;
    final score = ((correct / total) * 100).round();
    final dateTime = DateTime.parse(timestamp);
    final date = DateFormat('MMMM dd, yyyy').format(dateTime);
    final time = DateFormat('HH:mm').format(dateTime);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cikakken Bayani'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Maki:', '$score%', score >= 70 ? Colors.green : Colors.orange),
            const Divider(),
            _buildDetailRow('Daidai:', '$correct', Colors.green),
            _buildDetailRow('Kuskure:', '${total - correct}', Colors.red),
            _buildDetailRow('Jimillar Tambayoyi:', '$total', Colors.blue),
            const Divider(),
            _buildDetailRow('Nau\'i:', category, Colors.purple),
            const Divider(),
            _buildDetailRow('Ranar:', date, Theme.of(context).primaryColor),
            _buildDetailRow('Lokaci:', time, Theme.of(context).primaryColor),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Rufe'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}