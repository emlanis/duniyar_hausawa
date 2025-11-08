import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tsarin Sirri / Privacy Policy'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),

            // Hausa Version
            _buildSectionTitle('📱 Tsarin Sirri (Hausa)'),
            const SizedBox(height: 12),
            _buildHausaContent(),

            const Divider(height: 48),

            // English Version
            _buildSectionTitle('📱 Privacy Policy (English)'),
            const SizedBox(height: 12),
            _buildEnglishContent(),

            const SizedBox(height: 32),

            // Last Updated
            Center(
              child: Text(
                'Last Updated: November 2025',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, color: Color(0xFF2E7D32), size: 32),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your privacy is important to us. This app stores all data locally on your device.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildHausaContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsection(
          '1. Tattara Bayanai',
          'Duniyar Hausawa ba ya tattara ko aika bayanan ku zuwa wani sabar. Duk bayananku suna adanawa a cikin na\'urar ku kawai.',
        ),
        _buildSubsection(
          '2. Bayanan da Ake Adanawa',
          'Muna adana:\n'
          '• Sakamakon gwaje-gwaje\n'
          '• Abubuwan da kuka fi so\n'
          '• Ci gaban koyo\n'
          '• Saitunan manhaja',
        ),
        _buildSubsection(
          '3. Raba Bayanai',
          'Ba ma raba bayananku da wani kamfani ko mutum. Duk bayanan suna a kan na\'urar ku kawai.',
        ),
        _buildSubsection(
          '4. Tsaro',
          'Bayananku suna cikin aminci saboda suna adanawa a cikin na\'urar ku. SQLite database da SharedPreferences sune muke amfani dasu.',
        ),
        _buildSubsection(
          '5. Hakkin ku',
          'Kuna da ikon share ko gyara duk bayanan da kuka adana ta hanyar share manhaja.',
        ),
        _buildSubsection(
          '6. Internet',
          'Wannan manhaja ba ya buƙatar internet. Duk ayyukan suna aiki ba tare da haɗi ba.',
        ),
      ],
    );
  }

  Widget _buildEnglishContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsection(
          '1. Data Collection',
          'Duniyar Hausawa does not collect or transmit any personal data to external servers. All your data is stored locally on your device only.',
        ),
        _buildSubsection(
          '2. Information We Store Locally',
          'We store the following on your device:\n'
          '• Quiz results and scores\n'
          '• Favorite proverbs and images\n'
          '• Learning progress and streaks\n'
          '• App preferences and settings',
        ),
        _buildSubsection(
          '3. Data Sharing',
          'We do not share, sell, or transmit your data to any third parties. Everything stays on your device.',
        ),
        _buildSubsection(
          '4. Data Security',
          'Your data is secure because it never leaves your device. We use standard mobile storage mechanisms (SQLite database and SharedPreferences).',
        ),
        _buildSubsection(
          '5. Your Rights',
          'You have complete control over your data. You can delete all stored data by uninstalling the app.',
        ),
        _buildSubsection(
          '6. Internet Connection',
          'This app works completely offline. No internet connection is required or used.',
        ),
        _buildSubsection(
          '7. Third-Party Services',
          'We do not use any third-party analytics, advertising, or tracking services.',
        ),
        _buildSubsection(
          '8. Children\'s Privacy',
          'This app is safe for all ages. We do not collect any personal information from anyone, including children.',
        ),
        _buildSubsection(
          '9. Changes to Privacy Policy',
          'Any updates to this privacy policy will be reflected in app updates.',
        ),
        _buildSubsection(
          '10. Contact',
          'For questions about privacy, contact the developer through the app store listing.',
        ),
      ],
    );
  }

  Widget _buildSubsection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}