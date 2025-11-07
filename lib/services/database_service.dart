// lib/services/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/proverb_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('duniyar_hausawa.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add indexes for performance
      await db.execute('CREATE INDEX IF NOT EXISTS idx_proverbs_firstLetter ON proverbs(firstLetter)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_proverbs_isFavorite ON proverbs(isFavorite)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_proverbs_difficulty ON proverbs(difficulty)');
    }

    if (oldVersion < 3) {
      // Add new tables for photo quiz results and favorite images
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';
      const intType = 'INTEGER NOT NULL';

      await db.execute('''
        CREATE TABLE IF NOT EXISTS photo_quiz_results (
          id $idType,
          category $textType,
          totalQuestions $intType,
          correctAnswers $intType,
          timeSpent $intType,
          completedAt $textType
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS favorite_images (
          id $idType,
          itemId $intType,
          category $textType,
          hausaName $textType,
          englishName $textType,
          imagePath $textType,
          addedAt $textType
        )
      ''');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const intType = 'INTEGER NOT NULL';

    // Proverbs table
    await db.execute('''
      CREATE TABLE proverbs (
        id $idType,
        hausa $textType,
        english $textTypeNullable,
        meaningHausa $textTypeNullable,
        meaningEnglish $textTypeNullable,
        categories $textTypeNullable,
        difficulty $textType,
        audioUrl $textTypeNullable,
        isFavorite $intType,
        firstLetter $textType
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_proverbs_firstLetter ON proverbs(firstLetter)');
    await db.execute('CREATE INDEX idx_proverbs_isFavorite ON proverbs(isFavorite)');
    await db.execute('CREATE INDEX idx_proverbs_difficulty ON proverbs(difficulty)');

    // Quiz results table
    await db.execute('''
      CREATE TABLE quiz_results (
        id $idType,
        totalQuestions $intType,
        correctAnswers $intType,
        timeSpent $intType,
        difficulty $textType,
        completedAt $textType
      )
    ''');

    // Photo quiz results table
    await db.execute('''
      CREATE TABLE photo_quiz_results (
        id $idType,
        category $textType,
        totalQuestions $intType,
        correctAnswers $intType,
        timeSpent $intType,
        completedAt $textType
      )
    ''');

    // Favorite images table
    await db.execute('''
      CREATE TABLE favorite_images (
        id $idType,
        itemId $intType,
        category $textType,
        hausaName $textType,
        englishName $textType,
        imagePath $textType,
        addedAt $textType
      )
    ''');

    // User preferences table
    await db.execute('''
      CREATE TABLE preferences (
        key $textType,
        value $textTypeNullable
      )
    ''');
  }

  // PROVERB OPERATIONS

  Future<int> insertProverb(Proverb proverb) async {
    final db = await database;
    return await db.insert('proverbs', proverb.toMap());
  }

  Future<List<int>> insertProverbs(List<Proverb> proverbs) async {
    final db = await database;
    final batch = db.batch();

    for (var proverb in proverbs) {
      batch.insert('proverbs', proverb.toMap());
    }

    // Use noResult and exclusive transaction for faster bulk inserts
    final results = await batch.commit(noResult: false, exclusive: true);
    return results.cast<int>();
  }

  Future<List<Proverb>> getAllProverbs() async {
    final db = await database;
    final result = await db.query('proverbs', orderBy: 'hausa ASC');
    return result.map((map) => Proverb.fromMap(map)).toList();
  }

  Future<Proverb?> getProverbById(int id) async {
    final db = await database;
    final maps = await db.query(
      'proverbs',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Proverb.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Proverb>> searchProverbs(String query) async {
    final db = await database;
    final result = await db.query(
      'proverbs',
      where: 'hausa LIKE ? OR english LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'hausa ASC',
    );
    return result.map((map) => Proverb.fromMap(map)).toList();
  }

  Future<List<Proverb>> getProverbsByLetter(String letter) async {
    final db = await database;
    final result = await db.query(
      'proverbs',
      where: 'firstLetter = ?',
      whereArgs: [letter],
      orderBy: 'hausa ASC',
    );
    return result.map((map) => Proverb.fromMap(map)).toList();
  }

  Future<List<Proverb>> getFavoriteProverbs() async {
    final db = await database;
    final result = await db.query(
      'proverbs',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'hausa ASC',
    );
    return result.map((map) => Proverb.fromMap(map)).toList();
  }

  Future<int> getFavoriteProverbsCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM proverbs WHERE isFavorite = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> updateProverb(Proverb proverb) async {
    final db = await database;
    return await db.update(
      'proverbs',
      proverb.toMap(),
      where: 'id = ?',
      whereArgs: [proverb.id],
    );
  }

  Future<int> toggleFavorite(int id, bool isFavorite) async {
    final db = await database;
    return await db.update(
      'proverbs',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Proverb>> getRandomProverbs(int count) async {
    final db = await database;
    final result = await db.query(
      'proverbs',
      orderBy: 'RANDOM()',
      limit: count,
    );
    return result.map((map) => Proverb.fromMap(map)).toList();
  }

  Future<int> getProverbCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM proverbs');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // QUIZ RESULTS OPERATIONS

  Future<int> insertQuizResult(QuizResult result) async {
    final db = await database;
    return await db.insert('quiz_results', result.toMap());
  }

  Future<List<QuizResult>> getAllQuizResults() async {
    final db = await database;
    final result = await db.query(
      'quiz_results',
      orderBy: 'completedAt DESC',
    );
    return result.map((map) => QuizResult.fromMap(map)).toList();
  }

  Future<QuizResult?> getBestScore() async {
    final db = await database;
    final result = await db.query(
      'quiz_results',
      orderBy: 'correctAnswers DESC, timeSpent ASC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return QuizResult.fromMap(result.first);
    }
    return null;
  }

  // PHOTO QUIZ RESULTS OPERATIONS

  Future<int> insertPhotoQuizResult(Map<String, dynamic> result) async {
    final db = await database;
    return await db.insert('photo_quiz_results', result);
  }

  Future<List<Map<String, dynamic>>> getAllPhotoQuizResults() async {
    final db = await database;
    return await db.query(
      'photo_quiz_results',
      orderBy: 'completedAt DESC',
    );
  }

  Future<int> getPhotoQuizResultsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM photo_quiz_results');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // FAVORITE IMAGES OPERATIONS

  Future<int> addFavoriteImage(Map<String, dynamic> image) async {
    final db = await database;
    return await db.insert('favorite_images', image);
  }

  Future<int> removeFavoriteImage(int itemId) async {
    final db = await database;
    return await db.delete(
      'favorite_images',
      where: 'itemId = ?',
      whereArgs: [itemId],
    );
  }

  Future<bool> isImageFavorite(int itemId) async {
    final db = await database;
    final result = await db.query(
      'favorite_images',
      where: 'itemId = ?',
      whereArgs: [itemId],
    );
    return result.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getAllFavoriteImages() async {
    final db = await database;
    return await db.query(
      'favorite_images',
      orderBy: 'addedAt DESC',
    );
  }

  Future<int> getFavoriteImagesCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM favorite_images');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalFavoritesCount() async {
    final favoriteProverbs = await getFavoriteProverbsCount();
    final favoriteImages = await getFavoriteImagesCount();
    return favoriteProverbs + favoriteImages;
  }

  // UTILITY

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('proverbs');
    await db.delete('quiz_results');
    await db.delete('photo_quiz_results');
    await db.delete('favorite_images');
    await db.delete('preferences');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}