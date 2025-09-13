import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../model/category_expense.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'costly.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla para el presupuesto
    await db.execute('''
      CREATE TABLE budget (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL NOT NULL,
        disponible REAL NOT NULL,
        gastado REAL NOT NULL
      )
    ''');

    // Tabla para gastos individuales 
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        description TEXT,
        category TEXT,
        date TEXT NOT NULL
      )
    ''');
  }

  // Metodo para budget
  Future<int> insertBudget(double total) async {
    final db = await database;

    return await db.insert('budget', {
      'total': total,
      'gastado': 0,
      'disponible': total
    });
  }

  Future<Map<String, dynamic>?> getBudget() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('budget');

    if (maps.isNotEmpty) return maps.first;

    return null;
  }

  Future<void> updateBudget(double gastado, double disponible) async {
    final db = await database;
    await db.update('budget', {
      'gastado': gastado,
      'disponible': disponible
    });
  }

  // --- MÉTODOS PARA EXPENSES (para usar después) ---EL q
  Future<int> insertExpense({
    required double amount, 
    required String description, 
    required CategoryExpense category,  
    required DateTime date
  }) async {
    final db = await database;
    return await db.insert('expenses', {
      'amount': amount,
      'description': description,
      'category': category.id,
      'date': date.toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getExpenses() async {
    final db = await database;
    return await db.query('expenses', orderBy: 'date DESC');
  }

  Future<void> deleteExpense(int id) async {
    final db = await database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // --- MÉTODO PARA RESETEAR ---
  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete('budget');
    await db.delete('expenses');
  }
}