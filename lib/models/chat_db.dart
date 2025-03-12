import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class ChatDB {
  static final ChatDB instance = ChatDB._init();
  static Database? _database;

  ChatDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chatMessages.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT';
    const integerType = 'INTEGER';

    await db.execute('''
      CREATE TABLE chat_messages (
        id $idType,
        role $textType,
        text $textType,
        timestamp $integerType
      );
    ''');
  }

  Future<void> insertChatMessage(Map<String, dynamic> message) async {
    final db = await instance.database;
    await db.insert('chat_messages', message);
  }

  Future<List<Map<String, dynamic>>> fetchChatMessages() async {
    final db = await instance.database;
    return await db.query('chat_messages', orderBy: 'timestamp DESC');
  }
   // Function to clear all chat messages
  Future<void> clearAllChatMessages() async {
    final db = await instance.database;
    await db.delete('chat_messages'); // Deletes all rows in the table
  }
}
