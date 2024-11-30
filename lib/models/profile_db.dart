import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class UserDB {
  static final UserDB _instance = UserDB._internal();
  static Database? _database;

  factory UserDB() {
    return _instance;
  }

  UserDB._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user_profile (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            profile_photo TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveUserProfile(String username, String profilePhotoPath) async {
    final db = await database;

    await db.insert(
      'user_profile',
      {
        'username': username,
        'profile_photo': profilePhotoPath,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    final db = await database;
    final result = await db.query('user_profile', limit: 1);

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
}
