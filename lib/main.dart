// lib/main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Mark today as visited (for streak tracking)
  await notificationService.markTodayAsVisited();

  runApp(const DuniyarHausawaApp());
}

class DuniyarHausawaApp extends StatelessWidget {
  const DuniyarHausawaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Duniyar Hausawa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.yellow,
        primaryColor: const Color(0xFFFFB300), // Rich Kano yellow
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFFFB300), // Rich yellow (Kano)
          secondary: const Color(0xFF81C784), // Light green
          tertiary: const Color(0xFF1565C0), // Deep blue
          surface: const Color(0xFF2A2A2A), // Slightly lighter for cards
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF1E1E1E), // Light black background

        // Typography using Google Fonts
        textTheme: GoogleFonts.nunitoTextTheme(
          ThemeData.dark().textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.nunito(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFFB300), // Yellow
          ),
          displayMedium: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFFB300), // Yellow
          ),
          titleLarge: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyLarge: GoogleFonts.nunito(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),

        // AppBar theme
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: const Color(0xFFFFB300), // Rich yellow
          foregroundColor: Colors.black,
          titleTextStyle: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        // Floating Action Button theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF81C784), // Light green
          foregroundColor: Colors.black,
        ),

        // Button themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFB300), // Yellow
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Card theme for dark mode
        cardTheme: const CardThemeData(
          color: Color(0xFF2A2A2A),
          elevation: 2,
        ),

        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}