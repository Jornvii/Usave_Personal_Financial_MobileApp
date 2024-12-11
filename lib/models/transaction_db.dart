import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TransactionDB {
  static final TransactionDB _instance = TransactionDB._internal();
  static Database? _database;

  TransactionDB._internal();

  factory TransactionDB() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'transactions.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT NOT NULL,
            amount REAL NOT NULL,
            typeCategory INTEGER NOT NULL,
            description TEXT,
            date TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> addTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction);
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;
    return await db.query('transactions', orderBy: 'date DESC');
  }

  Future<void> updateTransaction(int id, Map<String, dynamic> updatedTransaction) async {
  final db = await database; // Assuming you have a `database` getter
  await db.update(
    'transactions', 
    updatedTransaction,
    where: 'id = ?', 
    whereArgs: [id],
  );
}


  Future<void> deleteTransaction(int id) async {
    final db = await database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearTransactions() async {
    final db = await database;
    await db.delete('transactions');
  }

  Future<double> getTotalIncome() async {
    final db = await database;
    var result = await db.rawQuery(
        'SELECT SUM(amount) as totalIncome FROM transactions WHERE typeCategory = 1');
    return result.isNotEmpty && result.first['totalIncome'] != null
        ? result.first['totalIncome'] as double
        : 0.0;
  }

  Future<double> getTotalExpenses() async {
    final db = await database;
    var result = await db.rawQuery(
        'SELECT SUM(amount) as totalExpenses FROM transactions WHERE typeCategory = 0');
    return result.isNotEmpty && result.first['totalExpenses'] != null
        ? result.first['totalExpenses'] as double
        : 0.0;
  }

  Future<double> getTotalSavings() async {
    final db = await database;
    var result = await db.rawQuery(
        'SELECT SUM(amount) as totalSavings FROM transactions WHERE typeCategory = 2');
    return result.isNotEmpty && result.first['totalSavings'] != null
        ? result.first['totalSavings'] as double
        : 0.0;
  }
}
