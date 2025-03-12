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
      timestamp INTEGER NULL,
      isRead INTEGER DEFAULT 0  -- New column: 0 = unread, 1 = read
    )
  ''');
}

  // Future<void> _onCreate(Database db, int version) async {
  //   await db.execute('''
  //     CREATE TABLE Notifications (
  //       id INTEGER PRIMARY KEY AUTOINCREMENT,
  //       message TEXT NOT NULL,
  //       time TEXT NULL,
  //       timestamp INTEGER NULL
  //     )
  //   ''');
  // }

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
    /// Fetch notifications where date is today
  Future<List<Map<String, dynamic>>> getTodaysNotifications() async {
    final db = await database;

    // Get current timestamp at start of the day (midnight)
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).millisecondsSinceEpoch;

    return await db.query(
      'Notifications',
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [startOfDay, endOfDay],
      orderBy: 'timestamp DESC',
    );
  }

 Future<int> getNotificationCountToday() async {
  final db = await database;

  // Get timestamps for start and end of today
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).millisecondsSinceEpoch;

  // Query to count only unread notifications
  final result = await db.rawQuery(
    'SELECT COUNT(*) as count FROM Notifications WHERE timestamp >= ? AND timestamp <= ? AND isRead = 0',
    [startOfDay, endOfDay]
  );

  return Sqflite.firstIntValue(result) ?? 0;
}
Future<void> markAllNotificationsAsRead() async {
  final db = await database;
  await db.update(
    'Notifications',
    {'isRead': 1},
    where: 'isRead = 0', // Only update unread notifications
  );
}


}
