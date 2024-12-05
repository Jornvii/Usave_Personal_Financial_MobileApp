import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SavingGoalDB {
  static final SavingGoalDB _instance = SavingGoalDB._internal();
  Database? _database;

  factory SavingGoalDB() {
    return _instance;
  }

  SavingGoalDB._internal();

  /// Initialize the database and create the table if necessary.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return await openDatabase(
      join(dbPath, 'SavingGoalDB.db'),
      version: 2, // Increment version for schema update
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE SavingGoal ('
          'id INTEGER PRIMARY KEY, '
          'savingCategory TEXT, '
          'goalAmount REAL)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute('ALTER TABLE SavingGoal ADD COLUMN savingCategory TEXT');
        }
      },
    );
  }

  /// Fetch all saving goals from the database.
  Future<List<Map<String, dynamic>>> fetchSavingGoals() async {
    final db = await database;
    return await db.query('SavingGoal');
  }

  /// Save or update a saving goal.
  Future<void> saveSavingGoal(String category, double goal) async {
    final db = await database;
    final existing = await db.query(
      'SavingGoal',
      where: 'savingCategory = ?',
      whereArgs: [category],
    );

    if (existing.isEmpty) {
      // Insert new saving goal
      await db.insert('SavingGoal', {'savingCategory': category, 'goalAmount': goal});
    } else {
      // Update existing saving goal
      await db.update(
        'SavingGoal',
        {'goalAmount': goal},
        where: 'savingCategory = ?',
        whereArgs: [category],
      );
    }
  }

  /// Delete a saving goal.
  Future<void> deleteSavingGoal(String category) async {
    final db = await database;
    await db.delete(
      'SavingGoal',
      where: 'savingCategory = ?',
      whereArgs: [category],
    );
  }
}
