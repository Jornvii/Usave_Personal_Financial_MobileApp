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
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE SavingGoal (id INTEGER PRIMARY KEY, goalAmount REAL)',
        );
      },
    );
  }

  /// Fetch the current saving goal from the database.
  Future<double?> fetchSavingGoal() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('SavingGoal');
    if (result.isNotEmpty) {
      return result.first['goalAmount'] as double?;
    }
    return null;
  }

  /// Save or update the saving goal in the database.
  Future<void> saveSavingGoal(double goal) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('SavingGoal');
    if (result.isEmpty) {
      // Insert new saving goal
      await db.insert('SavingGoal', {'goalAmount': goal});
    } else {
      // Update existing saving goal
      await db.update(
        'SavingGoal',
        {'goalAmount': goal},
        where: 'id = ?',
        whereArgs: [result.first['id']],
      );
    }
  }
}
