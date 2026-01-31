import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';
import '../models/vocabulary_item.dart';
import '../models/user_preferences.dart';

/// Service for local storage operations
class StorageService {
  Database? _database;
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _database = await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'translator_ai.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create messages table
        await db.execute('''
          CREATE TABLE messages (
            id TEXT PRIMARY KEY,
            content TEXT NOT NULL,
            isUser INTEGER NOT NULL,
            timestamp TEXT NOT NULL,
            mode INTEGER,
            englishText TEXT,
            tamilText TEXT,
            hasVocabulary INTEGER DEFAULT 0
          )
        ''');

        // Create vocabulary table
        await db.execute('''
          CREATE TABLE vocabulary (
            id TEXT PRIMARY KEY,
            englishWord TEXT NOT NULL,
            tamilMeaning TEXT NOT NULL,
            exampleSentence TEXT,
            exampleTranslation TEXT,
            savedAt TEXT NOT NULL,
            isFavorite INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  // ============ User Preferences ============

  Future<UserPreferences> getPreferences() async {
    final prefs = _prefs!;
    return UserPreferences(
      nativeLanguage: prefs.getString('nativeLanguage') ?? 'ta',
      isFirstLaunch: prefs.getBool('isFirstLaunch') ?? true,
      speechRate: prefs.getDouble('speechRate') ?? 0.5,
      apiKey: prefs.getString('apiKey'),
      voiceInputEnabled: prefs.getBool('voiceInputEnabled') ?? true,
    );
  }

  Future<void> savePreferences(UserPreferences preferences) async {
    final prefs = _prefs!;
    await prefs.setString('nativeLanguage', preferences.nativeLanguage);
    await prefs.setBool('isFirstLaunch', preferences.isFirstLaunch);
    await prefs.setDouble('speechRate', preferences.speechRate);
    if (preferences.apiKey != null) {
      await prefs.setString('apiKey', preferences.apiKey!);
    }
    await prefs.setBool('voiceInputEnabled', preferences.voiceInputEnabled);
  }

  Future<void> setFirstLaunchComplete() async {
    await _prefs!.setBool('isFirstLaunch', false);
  }

  Future<String?> getApiKey() async {
    return _prefs!.getString('apiKey');
  }

  Future<void> setApiKey(String apiKey) async {
    await _prefs!.setString('apiKey', apiKey);
  }

  // ============ Messages ============

  Future<List<Message>> getMessages({int limit = 50}) async {
    final db = _database!;
    final maps = await db.query(
      'messages',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return maps.map((map) => Message.fromMap(map)).toList().reversed.toList();
  }

  Future<void> saveMessage(Message message) async {
    final db = _database!;
    await db.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearMessages() async {
    final db = _database!;
    await db.delete('messages');
  }

  // ============ Vocabulary ============

  Future<List<VocabularyItem>> getVocabulary({
    bool favoritesOnly = false,
  }) async {
    final db = _database!;
    final maps = await db.query(
      'vocabulary',
      where: favoritesOnly ? 'isFavorite = 1' : null,
      orderBy: 'savedAt DESC',
    );
    return maps.map((map) => VocabularyItem.fromMap(map)).toList();
  }

  Future<void> saveVocabulary(VocabularyItem item) async {
    final db = _database!;
    await db.insert(
      'vocabulary',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteVocabulary(String id) async {
    final db = _database!;
    await db.delete('vocabulary', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> toggleFavorite(String id, bool isFavorite) async {
    final db = _database!;
    await db.update(
      'vocabulary',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isVocabularySaved(String englishWord) async {
    final db = _database!;
    final result = await db.query(
      'vocabulary',
      where: 'englishWord = ?',
      whereArgs: [englishWord],
    );
    return result.isNotEmpty;
  }
}
