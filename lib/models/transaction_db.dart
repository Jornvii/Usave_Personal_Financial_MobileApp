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
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT NOT NULL, -- Category of the typeCategory
            amount REAL NOT NULL,
            typeCategory INTEGER NOT NULL,  -- Expense, Income,Saving
            description TEXT,
            date TEXT NOT NULL,
            deleted INTEGER DEFAULT 0 -- New column to mark deleted transactions  
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // migration by adding the 'deleted' column if upgrading from version 1 to 2
          await db.execute(
              'ALTER TABLE transactions ADD COLUMN deleted INTEGER DEFAULT 0');
        }
      },
    );
  }

  Future<int> addTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction);
  }

  Future<List<Map<String, dynamic>>> getTransactionsByDateRange(
      String startDate, String endDate) async {
    final db = await database;
    return await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ? AND deleted = 0',
      whereArgs: [startDate, endDate],
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;
    return await db.query('transactions',
        where: 'deleted = 0', orderBy: 'date DESC');
  }

  Future<List<Map<String, dynamic>>> getDeletedTransactions() async {
    final db = await database;
    return await db.query('transactions',
        where: 'deleted = 1', orderBy: 'date DESC');
  }

  Future<void> updateTransaction(
      int id, Map<String, dynamic> updatedTransaction) async {
    final db = await database;
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

  // Move transaction to trash (mark as deleted)
  Future<void> moveToTrash(int id) async {
    final db = await database;
    await db.update(
      'transactions',
      {'deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Restore transaction from trash
  Future<void> recoverTransaction(int id) async {
    final db = await database;
    await db.update(
      'transactions',
      {'deleted': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Permanently delete transaction
  Future<void> permanentlyDeleteTransaction(int id) async {
    final db = await database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getSavingAmountByCategory(String category) async {
    final db = await database;
    var result = await db.rawQuery(
        'SELECT SUM(amount) as totalAmount FROM transactions WHERE typeCategory = 2 AND category = ? AND deleted = 0',
        [category]);
    return result.isNotEmpty && result.first['totalAmount'] != null
        ? result.first['totalAmount'] as double
        : 0.0;
  }

  Future<double> getTotalIncome() async {
    final db = await database;
    var result = await db.rawQuery(
        'SELECT SUM(amount) as totalIncome FROM transactions WHERE typeCategory = 1 AND deleted = 0');
    return result.isNotEmpty && result.first['totalIncome'] != null
        ? result.first['totalIncome'] as double
        : 0.0;
  }

  Future<double> getTotalExpenses() async {
    final db = await database;
    var result = await db.rawQuery(
        'SELECT SUM(amount) as totalExpenses FROM transactions WHERE typeCategory = 0 AND deleted = 0');
    return result.isNotEmpty && result.first['totalExpenses'] != null
        ? result.first['totalExpenses'] as double
        : 0.0;
  }

  Future<double> getTotalSavings() async {
    final db = await database;
    var result = await db.rawQuery(
        'SELECT SUM(amount) as totalSavings FROM transactions WHERE typeCategory = 2 AND deleted = 0');
    return result.isNotEmpty && result.first['totalSavings'] != null
        ? result.first['totalSavings'] as double
        : 0.0;
  }

  // reset all transactions without move to bin
  Future<void> resetDatabase() async {
    final db = await database;
    await db.delete('transactions');
  }
  // Function to get category totals for each typeCategory
  Future<List<Map<String, dynamic>>> getCategoryTotals() async {
    final db = await database; // Await the database connection.

    final result = await db.rawQuery('''
      SELECT category, typeCategory, SUM(amount) as totalAmount
      FROM transactions
      WHERE deleted = 0
      GROUP BY category, typeCategory
    ''');

    return result;
  }
}
