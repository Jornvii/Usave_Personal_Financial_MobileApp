import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CurrencyDB {
  static final CurrencyDB _instance = CurrencyDB._internal();
  factory CurrencyDB() => _instance;
  CurrencyDB._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'currency.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE currencies (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            symbol TEXT NOT NULL,
            isDefault INTEGER DEFAULT 0
          )
        ''');
        // Insert default currency ($) when database is created
        await db.insert('currencies', {'name': 'Dollar', 'symbol': '\$', 'isDefault': 1});
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS currencies (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              symbol TEXT NOT NULL,
              isDefault INTEGER DEFAULT 0
            )
          ''');
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> getCurrencies() async {
    final dbClient = await db;
    return await dbClient.query('currencies');
  }

  Future<void> insertCurrency(String name, String symbol) async {
    final dbClient = await db;
    await dbClient.insert('currencies', {'name': name, 'symbol': symbol, 'isDefault': 0});
  }

  Future<void> setDefaultCurrency(int id) async {
    final dbClient = await db;
    await dbClient.update('currencies', {'isDefault': 0});
    await dbClient.update('currencies', {'isDefault': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> getDefaultCurrency() async {
    final dbClient = await db;
    final result = await dbClient.query(
      'currencies',
      where: 'isDefault = ?',
      whereArgs: [1],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }
}
