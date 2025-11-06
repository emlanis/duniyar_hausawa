// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/database_service.dart';
import '../data/photo_quiz_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _totalProverbs = 0;
  int _favoriteProverbs = 0;
  int _quizzesTaken = 0;
  int _photoQuizzesTaken = 0;
  int _totalQuizzes = 0;
  int _averageScore = 0;
  int _totalPhotoQuizImages = 0;
  String _currentLevel = 'Mai Fara Koyo';
  double _experienceProgress = 0.0;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    final db = DatabaseService.instance;

    final totalProverbs = await db.getProverbCount();
    final favoriteProverbs = await db.getFavoriteProverbsCount();
    final quizResults = await db.getAllQuizResults();
    // TODO: Add photo quiz results from database when available
    // For now using placeholder
    final photoQuizResults = <dynamic>[];  // Will be populated later

    // Count total photo quiz images
    final allPhotoItems = PhotoQuizData.getAllItems();
    final totalPhotoImages = allPhotoItems.length;

    // Combine quiz scores from both types
    int totalScore = 0;
    int totalQuizCount = 0;

    // Add proverb quiz scores
    for (var result in quizResults) {
      totalScore += ((result.correctAnswers / result.totalQuestions) * 100).round();
      totalQuizCount++;
    }

    // Add photo quiz scores (when available)
    // for (var result in photoQuizResults) {
    //   totalScore += ((result.correctAnswers / result.totalQuestions) * 100).round();
    //   totalQuizCount++;
    // }

    // Calculate level and experience based on total activities
    final totalActivities = quizResults.length + photoQuizResults.length + favoriteProverbs;
    String currentLevel = _calculateLevel(totalActivities);
    double experienceProgress = _calculateExperienceProgress(totalActivities);

    setState(() {
      _totalProverbs = totalProverbs;
      _favoriteProverbs = favoriteProverbs;
      _quizzesTaken = quizResults.length;
      _photoQuizzesTaken = photoQuizResults.length;
      _totalQuizzes = totalQuizCount;
      _averageScore = totalQuizCount == 0 ? 0 : (totalScore / totalQuizCount).round();
      _totalPhotoQuizImages = totalPhotoImages;
      _currentLevel = currentLevel;
      _experienceProgress = experienceProgress;
    });
  }

  String _calculateLevel(int activities) {
    if (activities >= 100) return 'Gwani';
    if (activities >= 50) return 'Mai Ƙwarewa';
    if (activities >= 25) return 'Mai Ci Gaba';
    if (activities >= 10) return 'Mai Himma';
    return 'Mai Fara Koyo';
  }

  double _calculateExperienceProgress(int activities) {
    final levels = [0, 10, 25, 50, 100];
    for (int i = 0; i < levels.length - 1; i++) {
      if (activities >= levels[i] && activities < levels[i + 1]) {
        final progress = (activities - levels[i]) / (levels[i + 1] - levels[i]);
        return progress.clamp(0.0, 1.0);
      }
    }
    return 1.0; // Max level
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bayani'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black,
                        width: 3,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Barka Dai!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Mai Koyon Karin Magana',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tattaunawa',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Level Progress Card
                  Card(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.emoji_events,
                                    color: Theme.of(context).primaryColor,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Matsayinka',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        _currentLevel,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                '${(_experienceProgress * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: _experienceProgress,
                            backgroundColor: Colors.grey[800],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Content Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.book,
                          label: 'Karin Magana',
                          value: '$_totalProverbs',
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.photo_library,
                          label: 'Hotuna',
                          value: '$_totalPhotoQuizImages',
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.favorite,
                          label: 'Abubuwa da na fi so',
                          value: '$_favoriteProverbs',
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.quiz,
                          label: 'Gwaje-gwaje',
                          value: '$_totalQuizzes',
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.show_chart,
                          label: 'Matsakaicin Maki',
                          value: '$_averageScore%',
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.games,
                          label: 'Kacici-kacicin Karin Magana',
                          value: '$_quizzesTaken',
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.image,
                          label: 'Kacici-kacicin Hotuna',
                          value: '$_photoQuizzesTaken',
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(), // Empty space for symmetry
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Settings Section
                  Text(
                    'Saite-saite',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Card(
                    child: Column(
                      children: [
                        SwitchListTile(
                          secondary: const Icon(Icons.notifications),
                          title: const Text('Sanarwa'),
                          subtitle: const Text('Karɓi sanarwar yau da kullun'),
                          value: _notificationsEnabled,
                          activeThumbColor: Theme.of(context).primaryColor,
                          onChanged: (value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.language),
                          title: const Text('Yaare'),
                          subtitle: const Text('Hausa / English'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // TODO: Language settings
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.text_fields),
                          title: const Text('Girman Rubutu'),
                          subtitle: const Text('Matsakaici'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // TODO: Text size settings
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // About Section
                  Text(
                    'Game da Manhaja',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.info, color: Theme.of(context).primaryColor),
                          title: const Text('Game da Duniyar Hausawa'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _showAboutDialog(context),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.emoji_events, color: Theme.of(context).colorScheme.secondary),
                          title: const Text('Al\'adun Hausawa'),
                          subtitle: const Text('Koyi game da al\'adun Hausawa'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _showCultureInfo(context),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.share, color: Theme.of(context).colorScheme.tertiary),
                          title: const Text('Tura Manhaja'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _shareApp(),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.star, color: Colors.amber),
                          title: const Text('Bamu Maki'),
                          subtitle: const Text('Bayyana ra\'ayinka game da manhaja'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _rateApp(),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.feedback, color: Colors.orange),
                          title: const Text('Aika Sako'),
                          subtitle: const Text('Tuntube mu'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _sendFeedback(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Version Info
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.apps,
                          size: 48,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Duniyar Hausawa',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sigar 1.0.0',
                          style: TextStyle(
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '© 2025 Duniyar Hausawa',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'An gina da ❤️ don kare martabar al\'adun Hausawa',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Game da Duniyar Hausawa'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Duniyar Hausawa manhaja ce ta koyon al\'adun Hausawa mai ɗauke da:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildBulletPoint('Karin maganar Hausa sama da 2,000'),
              _buildBulletPoint('Ƙayataccen Kacici-kacici'),
              _buildBulletPoint('Hotuna da bayanai kan al\'adun Hausawa'),
              _buildBulletPoint('Damar ajiye abubuwan da kuka fi so'),
              const SizedBox(height: 12),
              const Text(
                'Manufar mu ita ce kare, tunatarwa, da inganta sanin al\'adun Hausawa ga kowane mutum.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
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

  void _showCultureInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(width: 8),
            const Text('Al\'adun Hausawa'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Yaren Hausa shi ne mafi yaren da aka fi yi a Najeriya da kuma yankunan Yammacin Afirka. A Ƙasar Saudia da sauran wasu ƙasashen dake tsakiyar gabashin Duniya, akwai miliyoyin mutanen dake yin yaren Hausa',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              const Text('Al\'adun Hausawa sun ƙunshi:'),
              const SizedBox(height: 8),
              _buildBulletPoint('Ciyayya - Al\'adar cin abinci tare da maƙwabta cikin annashuwa da taimakon juna'),
              _buildBulletPoint('Zance - Hanyar soyayya ta gargajiya tsakanin matasa da dare'),
              _buildBulletPoint('Budurcin \'yan mata da martabarta kafin aure da binciken al\'ada'),
              _buildBulletPoint('Auren haɗi ko na ɗan dangi don ƙarfafa zumunta da zaman lafiya'),
              _buildBulletPoint('Ilimi da masana'),
              _buildBulletPoint('Riƙe ɗabi\'u daga Maguzanci zuwa Musulunci'),
              _buildBulletPoint('Sana\'o\'i da kasuwanci cikin haɗin kai'),
              _buildBulletPoint('Tufafi na gargajiya da gine-gine na musamman'),
              _buildBulletPoint('Karin magana: "Naka naka ne ko ya ci namanka ba zai tauna ƙashin ba"'),
              _buildBulletPoint('Sauyin zamani: Daga al\'adun da zuwa na yanzu'),
              const SizedBox(height: 12),
              const Text(
                'Karin magana muhimman fanni ne na al\'ada da  ilimi dan ƙoyon hikima, ɗabi\'a, da fasahar rayuwa.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
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

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  void _shareApp() {
    const text = '''
🇳🇬 Duniyar Hausawa - Koyon Karin Magana

Ɗauko manhaja mai girma domin koyon karin maganar Hausawa!

✓ Sama da karin magana dubu biyu
✓ Kacici-kacici
✓ Bayanai kan al'adun Hausawa

Ɗauko yanzu!
''';

    Clipboard.setData(const ClipboardData(text: text));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An kwafa! Za ka iya yaɗawa a social media'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _rateApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bamu Maki'),
        content: const Text(
          'Ka yi amfani da Duniyar Hausawa?\n\nMuna so mu san ra\'ayinka! Bamu maki a cikin runbun manhaja wato app store.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Koma baya'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Open app store
            },
            child: const Text('Bamu Maki'),
          ),
        ],
      ),
    );
  }

  void _sendFeedback(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aika Saƙo'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Zamu so muji daga gareka!'),
            SizedBox(height: 12),
            Text('Tuntuɓe mu ta:'),
            SizedBox(height: 8),
            Text('📧 Email: hausatrends12@gmail.com'),
            SizedBox(height: 4),
            Text('🐦 Twitter/X: @HausaTrends'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Rufe'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              const email = 'hausatrends12@gmail.com';
              Clipboard.setData(const ClipboardData(text: email));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('An kwafi adireshin email!')),
              );
            },
            child: const Text('Kwafi Email'),
          ),
        ],
      ),
    );
  }
}