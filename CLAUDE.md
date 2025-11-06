# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Duniyar Hausawa** (The World of Hausa People) is a Flutter application for Hausa cultural learning, featuring proverbs, quizzes, and cultural content. The app provides an educational platform for learning and preserving Hausa language and culture.

## Common Commands

### Development
```bash
# Get dependencies
flutter pub get

# Run the app (development mode with hot reload)
flutter run

# Run on specific device
flutter run -d <device-id>

# List available devices
flutter devices

# Run with verbose logging
flutter run -v
```

### Building
```bash
# Build for Android
flutter build apk
flutter build appbundle  # For Play Store

# Build for iOS
flutter build ios

# Build for macOS
flutter build macos
```

### Testing & Analysis
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage

# Analyze code for issues
flutter analyze

# Format all Dart files
flutter format lib/ test/
```

### Cleaning
```bash
# Clean build artifacts
flutter clean

# Full refresh (clean + get dependencies)
flutter clean && flutter pub get
```

### Icons & Assets
```bash
# Generate launcher icons (after updating icon in assets/images/app_icon.png)
flutter pub run flutter_launcher_icons
```

## Code Architecture

### Directory Structure

```
lib/
├── main.dart          # App entry point
├── models/            # Data models (Proverb, Quiz, User progress, etc.)
├── screens/           # UI screens/pages
├── widgets/           # Reusable UI components
├── services/          # Business logic & external services
│                      # - Database service (SQLite)
│                      # - Audio service (audioplayers)
│                      # - Notification service
│                      # - Shared preferences service
├── data/              # Data layer (repositories, data sources)
└── utils/             # Utility functions & constants
```

### State Management

The app uses **Provider** for state management. When creating new features:
- Define state models in `models/` that extend `ChangeNotifier`
- Provide them at the appropriate level (app-wide in `main.dart` or screen-specific)
- Use `Consumer<T>` or `Provider.of<T>(context)` in widgets to access state

### Data Persistence

Two storage mechanisms are used:
1. **SharedPreferences** (`shared_preferences`) - For simple key-value pairs (user settings, preferences)
2. **SQLite** (`sqflite`) - For structured data (proverbs, quiz questions, user progress)

Database service should be initialized in `services/` and expose CRUD operations for data models.

### Assets Organization

```
assets/
├── data/      # JSON files with proverbs, quiz questions, cultural content
├── audio/     # Audio pronunciations, background music
└── images/    # App icon, illustrations, cultural images
```

When adding new assets, update `pubspec.yaml` if adding new asset directories.

### Key Dependencies

- **provider**: State management pattern
- **sqflite**: Local SQLite database
- **shared_preferences**: Key-value storage
- **audioplayers**: Audio playback for pronunciations
- **flutter_local_notifications**: Daily proverb reminders, quiz notifications
- **lottie**: Animations for engaging UI
- **google_fonts**: Custom typography for Hausa text
- **intl**: Internationalization and date formatting

## Development Guidelines

### Adding a New Screen

1. Create screen file in `lib/screens/` (e.g., `proverb_detail_screen.dart`)
2. Create associated widgets in `lib/widgets/` if reusable
3. Update navigation in main app or router
4. Create corresponding state model in `models/` if needed
5. Provide the model using Provider at appropriate level

### Working with Audio

Use the `audioplayers` package for Hausa pronunciation playback:
- Store audio files in `assets/audio/`
- Create an audio service in `lib/services/audio_service.dart`
- Handle audio player lifecycle (play, pause, stop, dispose)

### Database Schema

When implementing the SQLite database:
- Create database helper in `lib/services/database_service.dart`
- Define table schemas for: proverbs, quiz questions, user progress, favorites
- Implement migration strategy for schema updates
- Use repository pattern in `lib/data/` to abstract database operations

### Notifications

Implement local notifications for:
- Daily Hausa proverb reminders
- Quiz challenge notifications
- Cultural event reminders

Create notification service in `lib/services/notification_service.dart` and initialize in `main.dart`.

### Testing

- Widget tests are in `test/` directory
- Test files should mirror the structure of `lib/`
- Run tests before committing significant changes
- Focus on testing business logic in services and state models

### Platform Support

The app targets:
- Android (primary)
- iOS (primary)
- macOS, Linux, Web (secondary)

Platform-specific code should be isolated in services and use conditional imports or platform checks.
