// lib/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('my_database.db');
    return _database!;
  }

  Future<Database> _initDB(String dbName) async {
    String path = join(await getDatabasesPath(), dbName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
      )
    ''');
  }

  // Create
  Future<void> insertItem(Map<String, dynamic> item) async {
    final db = await database;
    await db.insert(
      'items',
      item,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Read
  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await database;
    return await db.query('items');
  }

  // Update
  Future<void> updateItem(Map<String, dynamic> item) async {
    final db = await database;
    await db.update(
      'items',
      item,
      where: 'id = ?',
      whereArgs: [item['id']],
    );
  }

  // Delete
  Future<void> deleteItem(int id) async {
    final db = await database;
    await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
