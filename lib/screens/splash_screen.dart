// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../data/proverbs_data.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _statusMessage = 'Initializing...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _statusMessage = 'Setting up database...';
      });

      final db = DatabaseService.instance;

      // Check if proverbs are already loaded
      final count = await db.getProverbCount();

      if (count == 0) {
        setState(() {
          _statusMessage = 'Loading proverbs...';
        });

        // Load proverbs from asset file
        debugPrint('Loading proverbs from file...');
        final proverbs = await ProverbsData.loadProverbsFromAsset();

        if (proverbs.isNotEmpty) {
          setState(() {
            _statusMessage = 'Importing ${proverbs.length} proverbs...';
          });

          debugPrint('Importing ${proverbs.length} proverbs into database...');
          await db.insertProverbs(proverbs);
          debugPrint('Successfully imported ${proverbs.length} proverbs!');
        } else {
          setState(() {
            _statusMessage = 'Loading sample proverbs...';
          });

          // If loading failed, use sample data
          debugPrint('Using sample proverbs...');
          final sampleProverbs = ProverbsData.getSampleProverbs();
          await db.insertProverbs(sampleProverbs);
        }
      } else {
        debugPrint('Database already has $count proverbs');
      }

      setState(() {
        _statusMessage = 'Ready!';
      });

      // Small delay to show "Ready!" message
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to home screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      debugPrint('Error initializing app: $e');
      setState(() {
        _hasError = true;
        _statusMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon or Logo
            Icon(
              Icons.book_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),

            // App Title
            Text(
              'Duniyar Hausawa',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'The World of Hausa People',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white54,
                  ),
            ),
            const SizedBox(height: 48),

            // Loading indicator
            if (!_hasError) ...[
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
              ),
              const SizedBox(height: 24),
            ],

            // Status message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: _hasError ? Colors.red : Colors.white70,
                    ),
              ),
            ),

            // Retry button if error
            if (_hasError) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _statusMessage = 'Retrying...';
                  });
                  _initializeApp();
                },
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}