// lib/data/proverbs_data.dart

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import '../models/proverb_model.dart';

class ProverbsData {
  static Future<List<Proverb>> loadProverbsFromAsset() async {
    try {
      // Load the text file from assets
      final String proverbsText = await rootBundle.loadString('assets/data/hausa_proverbs.txt');

      // Split into lines and filter empty ones
      final List<String> lines = proverbsText
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      // Convert each line to a Proverb object
      List<Proverb> proverbs = [];

      for (int i = 0; i < lines.length; i++) {
        final String hausaText = lines[i];

        // Get first letter for grouping
        final String firstLetter = Proverb.getFirstLetter(hausaText);

        // Create proverb object
        final proverb = Proverb(
          id: i + 1,
          hausa: hausaText,
          firstLetter: firstLetter,
          difficulty: _determineDifficulty(hausaText),
        );

        proverbs.add(proverb);
      }

      return proverbs;
    } catch (e) {
      debugPrint('Error loading proverbs: $e');
      return [];
    }
  }

  // Determine difficulty based on proverb length
  static String _determineDifficulty(String text) {
    final wordCount = text.split(' ').length;

    if (wordCount <= 5) {
      return 'easy';
    } else if (wordCount <= 10) {
      return 'medium';
    } else {
      return 'hard';
    }
  }

  // Get Hausa alphabet for navigation
  static List<String> getHausaAlphabet() {
    return [
      'A', 'B', 'Ɓ', 'C', 'D', 'Ɗ', 'E', 'F', 'G', 'H', 'I', 'J',
      'K', 'Ƙ', 'L', 'M', 'N', 'O', 'R', 'S', 'SH', 'T', 'U',
      'W', 'Y', 'Ƴ', 'Z', "'"
    ];
  }

  // Sample proverbs for testing (if file is not available)
  static List<Proverb> getSampleProverbs() {
    return [
      Proverb(
        id: 1,
        hausa: 'A kwana a tashi, gobe ya yi',
        english: 'Sleep and wake, tomorrow comes',
        meaningHausa: 'Kowane abu yana da lokaci, kada ka yi sauri',
        meaningEnglish: 'Everything has its time, don\'t rush',
        firstLetter: 'A',
        difficulty: 'easy',
      ),
      Proverb(
        id: 2,
        hausa: 'Abin da bai kai gindin rijiya ba, ba ya sha ruwa',
        english: 'What doesn\'t reach the bottom of the well doesn\'t drink water',
        meaningHausa: 'Dole ka yi ƙoƙari sosai kafin ka samu nasara',
        meaningEnglish: 'You must try hard to succeed',
        firstLetter: 'A',
        difficulty: 'medium',
      ),
      Proverb(
        id: 3,
        hausa: 'Ƙarfin gwiwa, ba kasuwa',
        english: 'Strength of the arm is not a market',
        meaningHausa: 'Ƙarfi kadai bai isa ba, kana buƙatar hikima',
        meaningEnglish: 'Strength alone is not enough, you need wisdom',
        firstLetter: 'Ƙ',
        difficulty: 'medium',
      ),
    ];
  }
}