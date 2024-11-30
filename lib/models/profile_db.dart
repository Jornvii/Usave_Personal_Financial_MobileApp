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
            username TEXT
          )
        ''');
      },
    );
  }

  // Save or update user profile
  Future<void> saveOrUpdateUserProfile(String username) async {
    final db = await database;

    try {
      await db.insert(
        'user_profile',
        {
          'username': username,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error saving user profile: $e');
    }
  }

  // Fetch user profile
  Future<Map<String, dynamic>?> fetchUserProfile() async {
    final db = await database;

    try {
      final result = await db.query('user_profile', limit: 1);
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // Delete user profile
  Future<void> deleteUserProfile() async {
    final db = await database;

    try {
      await db.delete('user_profile');
    } catch (e) {
      print('Error deleting user profile: $e');
    }
  }
}
