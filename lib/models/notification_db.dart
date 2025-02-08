import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class NotificationDB {
  static final NotificationDB _instance = NotificationDB._internal();
  static Database? _database;

  factory NotificationDB() => _instance;

  NotificationDB._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'NotificationDB.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        message TEXT NOT NULL,
        time TEXT NULL,
        timestamp INTEGER NULL
      )
    ''');
  }

  Future<int> insertNotification(Map<String, dynamic> notification) async {
    final db = await database;
    return await db.insert('Notifications', notification);
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final db = await database;
    return await db.query('Notifications', orderBy: 'timestamp DESC');
  }

  Future<int> deleteNotification(int id) async {
    final db = await database;
    return await db.delete('Notifications', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllNotifications() async {
    final db = await database;
    await db.delete('Notifications');
  }

  /// Fetches the count of notifications in the database.
  Future<int> getNotificationCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM Notifications');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
