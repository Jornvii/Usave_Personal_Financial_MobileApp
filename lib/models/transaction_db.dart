// import 'dart:async';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

// class TransactionDB {
//   static final TransactionDB _instance = TransactionDB._internal();
//   static Database? _database;

//   TransactionDB._internal();

//   factory TransactionDB() => _instance;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB();
//     return _database!;
//   }

//   Future<Database> _initDB() async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, 'transactions.db');

//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE transactions (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             category TEXT NOT NULL,
//             amount REAL NOT NULL,
//             isIncome INTEGER NOT NULL,
//             description TEXT,
//             date TEXT NOT NULL
//           )
//         ''');
//       },
//     );
//   }

//   Future<int> addTransaction(Map<String, dynamic> transaction) async {
//     final db = await database;
//     return await db.insert('transactions', transaction);
//   }

//   Future<List<Map<String, dynamic>>> getTransactions() async {
//     final db = await database;
//     return await db.query('transactions', orderBy: 'date DESC');
//   }

//   Future<void> clearTransactions() async {
//     final db = await database;
//     await db.delete('transactions');
//   }
// }
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
            isIncome INTEGER NOT NULL,
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

  Future<List<Map<String, dynamic>>> getTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await database;

    // Convert dates to string format for comparison
    String start = startDate.toIso8601String();
    String end = endDate.toIso8601String();

    return await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start, end],
      orderBy: 'date DESC',
    );
  }

  Future<void> clearTransactions() async {
    final db = await database;
    await db.delete('transactions');
  }
}
