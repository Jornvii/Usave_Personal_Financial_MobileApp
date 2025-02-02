import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CategoryDB {
  static final CategoryDB _instance = CategoryDB._internal();
  static Database? _database;

  CategoryDB._internal();

  factory CategoryDB() => _instance;

  // Initialize the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDB('categories.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    String path = join(await getDatabasesPath(), fileName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');
  }

  // Insert a new category
  Future<int> insertCategory(Map<String, dynamic> category) async {
    final db = await database;
    return await db.insert('categories', category);
  }

  // Fetch all categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query('categories');
  }

  // Delete a category by its ID
  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update category information (name or type)
  Future<int> updateCategory(int id, Map<String, dynamic> updatedCategory) async {
    final db = await database;
    return await db.update(
      'categories',
      updatedCategory,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
    /// Fetch all categories with a specific type (e.g., 'Saving').
   Future<List<Map<String, dynamic>>> fetchCategoriesByType(String type) async {
    final db = await database;
    return await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
    );
  }

}
