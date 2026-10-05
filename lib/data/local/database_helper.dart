import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/accessibility_preferences.dart';
import '../models/adaptive_ui_settings.dart';
import '../models/diagnostic_data.dart';
import '../models/user_profile.dart';

/// Central SQLite Database Helper managing local offline persistence
/// for GabEye's User_Profile, Diagnostic_Data, Adaptive_UI_Settings,
/// and Accessibility_Preferences tables.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const String _dbName = 'gabeye.db';
  static const int _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enforce foreign key constraints across all tables
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. User_Profile Table
    await db.execute('''
      CREATE TABLE User_Profile (
        _id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    // 2. Diagnostic_Data Table
    await db.execute('''
      CREATE TABLE Diagnostic_Data (
        user_id INTEGER PRIMARY KEY,
        has_taken_test INTEGER NOT NULL DEFAULT 0,
        cvd_type TEXT,
        severity TEXT,
        test_date TEXT,
        FOREIGN KEY (user_id) REFERENCES User_Profile (_id) ON DELETE CASCADE
      );
    ''');

    // 3. Adaptive_UI_Settings Table
    await db.execute('''
      CREATE TABLE Adaptive_UI_Settings (
        user_id INTEGER PRIMARY KEY,
        applied_theme TEXT NOT NULL DEFAULT 'Default',
        color_agnostic_mode INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES User_Profile (_id) ON DELETE CASCADE
      );
    ''');

    // 4. Accessibility_Preferences Table
    await db.execute('''
      CREATE TABLE Accessibility_Preferences (
        user_id INTEGER PRIMARY KEY,
        tts_enabled INTEGER NOT NULL DEFAULT 0,
        tts_speech_rate REAL DEFAULT 0.5,
        FOREIGN KEY (user_id) REFERENCES User_Profile (_id) ON DELETE CASCADE
      );
    ''');

    // Seed default local profile (_id: 1)
    final now = DateTime.now().toIso8601String();
    await db.insert('User_Profile', {
      '_id': 1,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('Diagnostic_Data', {
      'user_id': 1,
      'has_taken_test': 0,
      'cvd_type': null,
      'severity': null,
      'test_date': null,
    });

    await db.insert('Adaptive_UI_Settings', {
      'user_id': 1,
      'applied_theme': 'Default',
      'color_agnostic_mode': 0,
    });

    await db.insert('Accessibility_Preferences', {
      'user_id': 1,
      'tts_enabled': 0,
      'tts_speech_rate': 0.5,
    });
  }

  // ---------------------------------------------------------------------------
  // User_Profile Operations
  // ---------------------------------------------------------------------------

  Future<UserProfile?> getUserProfile([int userId = 1]) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'User_Profile',
      where: '_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateUserProfileTimestamp([int userId = 1]) async {
    final db = await database;
    await db.update(
      'User_Profile',
      {'updated_at': DateTime.now().toIso8601String()},
      where: '_id = ?',
      whereArgs: [userId],
    );
  }

  // ---------------------------------------------------------------------------
  // Diagnostic_Data Operations
  // ---------------------------------------------------------------------------

  Future<DiagnosticData?> getDiagnosticData([int userId = 1]) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Diagnostic_Data',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return DiagnosticData.fromMap(maps.first);
    }
    return null;
  }

  Future<void> saveDiagnosticData(DiagnosticData data) async {
    final db = await database;
    await db.insert(
      'Diagnostic_Data',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await updateUserProfileTimestamp(data.userId);
  }

  // ---------------------------------------------------------------------------
  // Adaptive_UI_Settings Operations
  // ---------------------------------------------------------------------------

  Future<AdaptiveUiSettings?> getUiSettings([int userId = 1]) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Adaptive_UI_Settings',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return AdaptiveUiSettings.fromMap(maps.first);
    }
    return null;
  }

  Future<void> saveUiSettings(AdaptiveUiSettings settings) async {
    final db = await database;
    await db.insert(
      'Adaptive_UI_Settings',
      settings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await updateUserProfileTimestamp(settings.userId);
  }

  // ---------------------------------------------------------------------------
  // Accessibility_Preferences Operations
  // ---------------------------------------------------------------------------

  Future<AccessibilityPreferences?> getAccessibilityPreferences([int userId = 1]) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Accessibility_Preferences',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return AccessibilityPreferences.fromMap(maps.first);
    }
    return null;
  }

  Future<void> saveAccessibilityPreferences(AccessibilityPreferences prefs) async {
    final db = await database;
    await db.insert(
      'Accessibility_Preferences',
      prefs.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await updateUserProfileTimestamp(prefs.userId);
  }

  // ---------------------------------------------------------------------------
  // Reset / Clear Helper (e.g. for retesting or dev resets)
  // ---------------------------------------------------------------------------

  Future<void> resetAssessmentData([int userId = 1]) async {
    final db = await database;
    await db.update(
      'Diagnostic_Data',
      {
        'has_taken_test': 0,
        'cvd_type': null,
        'severity': null,
        'test_date': null,
      },
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    await db.update(
      'Adaptive_UI_Settings',
      {
        'applied_theme': 'Default',
        'color_agnostic_mode': 0,
      },
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    await updateUserProfileTimestamp(userId);
  }
}
