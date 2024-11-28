import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class chatTest {
  static final chatTest _instance = chatTest._internal();
  factory chatTest() => _instance;
  chatTest._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'chatbot.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            role TEXT,
            text TEXT,
            category TEXT,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      },
    );
  }

  Future<void> insertMessage(Map<String, dynamic> message) async {
    final db = await database;
    await db.insert('messages', message);
  }

  Future<List<Map<String, dynamic>>> fetchMessages() async {
    final db = await database;
    return await db.query('messages', orderBy: 'timestamp ASC');
  }

  Future<void> clearChatHistory() async {
    final db = await database;
    await db.delete('messages');
  }
}
