import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDB('Detail.db');
    return _database!;
  }

  Future<Database> _initializeDB(String filepath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filepath);

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    } catch (e) {
      debugPrint("Error initializing database: $e");
      rethrow;
    }
  }

  Future<void> _createDB(Database db, int version) async {
    try {
      // Create table for categories
      await db.execute('''
        CREATE TABLE IF NOT EXISTS option_categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL
        )
      ''');

      // Create table for choices
      await db.execute('''
        CREATE TABLE IF NOT EXISTS option_choices (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          additional_price INTEGER DEFAULT 0,
          FOREIGN KEY (category_id) REFERENCES option_categories (id) ON DELETE CASCADE
        )
      ''');
    } catch (e) {
      debugPrint("Error creating tables: $e");
      rethrow;
    }
  }

  // Add initial data to the database
  Future<void> addInitialData() async {
    final db = await database;

    final categories = [
      'Size',
      'Sweetness',
      'Ice Cube',
      'Topping',
    ];

    // Add categories
    Map<String, int> categoryIds = {};
    for (var category in categories) {
      int id = await db.insert(
        'option_categories',
        {'name': category},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      categoryIds[category] = id;
    }

    final choices = [
      {'category': 'Size', 'name': 'Regular Ice', 'additional_price': 0},
      {'category': 'Size', 'name': 'Large Ice', 'additional_price': 6000},
      {'category': 'Sweetness', 'name': 'Normal Sweet', 'additional_price': 0},
      {'category': 'Sweetness', 'name': 'Less Sweet', 'additional_price': 0},
      {'category': 'Sweetness', 'name': 'No Sweet', 'additional_price': 0},
      {'category': 'Ice Cube', 'name': 'Normal Ice', 'additional_price': 0},
      {'category': 'Ice Cube', 'name': 'Less Ice', 'additional_price': 0},
      {'category': 'Ice Cube', 'name': 'More Ice', 'additional_price': 0},
      {'category': 'Ice Cube', 'name': 'No Ice', 'additional_price': 0},
      {'category': 'Topping', 'name': 'Caramel Sauce', 'additional_price': 6000},
      {'category': 'Topping', 'name': 'Crumble', 'additional_price': 6000},
      {'category': 'Topping', 'name': 'Sea Salt Cream', 'additional_price': 6000},
      {'category': 'Topping', 'name': 'Milo Powder', 'additional_price': 6000},
      {'category': 'Topping', 'name': 'Oreo Crumbs', 'additional_price': 6000},
    ];

    // Add choices to database
    for (var choice in choices) {
      int? categoryId = categoryIds[choice['category']];
      if (categoryId != null) {
        await db.insert(
          'option_choices',
          {
            'category_id': categoryId,
            'name': choice['name'],
            'additional_price': choice['additional_price'],
          },
        );
      }
    }
  }

  // Fetch order details (categories and their choices)
  Future<List<Map<String, dynamic>>> fetchOrderDetails() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> categories =
          await db.query('option_categories');
      List<Map<String, dynamic>> results = [];

      for (var category in categories) {
        final categoryId = category['id'];
        final List<Map<String, dynamic>> choices = await db.query(
          'option_choices',
          where: 'category_id = ?',
          whereArgs: [categoryId],
        );

        results.add({
          'category': category['name'],
          'choices': choices,
        });
      }

      return results;
    } catch (e) {
      debugPrint("Error fetching order details: $e");
      return [];
    }
  }

  /// Add a new category
  Future<int> addCategory(String name) async {
    final db = await database;
    return await db.insert('option_categories', {'name': name});
  }

  /// Get all categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query('option_categories');
  }

  /// Update a category
  Future<int> updateCategory(int id, String name) async {
    final db = await database;
    return await db.update(
      'option_categories',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete a category
  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      'option_categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Add a new choice
  Future<int> addChoice(int categoryId, String name, int additionalPrice) async {
    final db = await database;
    return await db.insert('option_choices', {
      'category_id': categoryId,
      'name': name,
      'additional_price': additionalPrice,
    });
  }

  /// Get all choices
  Future<List<Map<String, dynamic>>> getChoices(int categoryId) async {
    final db = await database;
    return await db.query(
      'option_choices',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
  }

  /// Update a choice
  Future<int> updateChoice(int id, String name, int additionalPrice) async {
    final db = await database;
    return await db.update(
      'option_choices',
      {
        'name': name,
        'additional_price': additionalPrice,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete a choice
  Future<int> deleteChoice(int id) async {
    final db = await database;
    return await db.delete(
      'option_choices',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
