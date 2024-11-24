import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ChatDB {
  static final ChatDB _instance = ChatDB._internal();

  factory ChatDB() => _instance;

  ChatDB._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'chat.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE chat (id INTEGER PRIMARY KEY, role TEXT, text TEXT, animated TEXT)',
        );
      },
      version: 1,
    );
  }

  /// Insert a message into the chat table
  Future<void> insertMessage(Map<String, String> message) async {
    final db = await database;
    await db.insert('chat', message, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Fetch all messages from the chat table
  Future<List<Map<String, dynamic>>> fetchMessages() async {
    final db = await database;
    return await db.query('chat', orderBy: 'id ASC');
  }

  /// Clear all messages in the chat table
  Future<void> clearMessages() async {
    final db = await database;
    await db.delete('chat');
  }


}
