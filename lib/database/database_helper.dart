import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../model/category_expense.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static Future<Database>? _databaseFuture;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final pendingDatabase = _databaseFuture ??= _initDatabase();
    try {
      return _database = await pendingDatabase;
    } catch (_) {
      // Permite reintentar si la apertura falla, sin iniciar dos aperturas a la vez.
      if (identical(_databaseFuture, pendingDatabase)) {
        _databaseFuture = null;
      }
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'costly.db');

    try {
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onOpen: (db) async {
          final tables = await db.query(
            'sqlite_master',
            where: 'type = ?',
            whereArgs: ['table'],
          );
          final hasBudget = tables.any((row) => row['name'] == 'budget');
          final hasExpenses = tables.any((row) => row['name'] == 'expenses');

          if (!hasBudget || !hasExpenses) {
            await _resetDatabase(db);
          }
        },
      );
    } on DatabaseException catch (error) {
      if (!_isCorruptDatabase(error)) rethrow;

      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }

      return await openDatabase(path, version: 1, onCreate: _onCreate);
    }
  }

  bool _isCorruptDatabase(DatabaseException error) {
    final message = error.toString().toLowerCase();
    return message.contains('file is not a database') ||
        message.contains('database disk image is malformed') ||
        message.contains('database corrupt');
  }

  Future<void> _resetDatabase(Database db) async {
    await db.execute('DROP TABLE IF EXISTS budget');
    await db.execute('DROP TABLE IF EXISTS expenses');
    await _onCreate(db, 1);
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

    return db.transaction((txn) async {
      await txn.delete('budget');
      return txn.insert('budget', {
        'id': 1,
        'total': total,
        'gastado': 0,
        'disponible': total,
      });
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

    final gastoRedondeado = double.parse(gastado.toStringAsFixed(2));
    final disponibleRedondeado = double.parse(disponible.toStringAsFixed(2));

    await db.update('budget', {
      'gastado': gastoRedondeado,
      'disponible': disponibleRedondeado,
    });
  }

  // --- MÉTODOS PARA EXPENSES ---
  Future<int> insertExpense({
    required double amount,
    required String description,
    required CategoryExpense category,
    required DateTime date,
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
    return await db.query('expenses', orderBy: 'date DESC, id DESC');
  }

  Future<void> deleteExpense(int id) async {
    final db = await database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateExpense(Map<String, dynamic> expense) async {
    final db = await database;
    await db.update(
      'expenses',
      expense,
      where: 'id = ?',
      whereArgs: [expense['id']],
    );
  }

  // --- MÉTODO PARA RESETEAR ---
  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete('budget');
    await db.delete('expenses');
  }
}
