import 'package:costly/database/database_helper.dart';
import 'package:flutter/widgets.dart';

import 'package:costly/model/expense.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();

    // ✅ AGREGA ESTOS PRINTS PARA DEBUGGEAR
    print('🔄 Cargando gastos...');

    try {
      final expensesData = await DatabaseHelper().getExpenses();
      print('📊 Datos de BD: $expensesData'); // ← Ver qué retorna la BD

      _expenses = expensesData.map((data) => Expense.fromMap(data)).toList();
      print('✅ Gastos convertidos: ${_expenses.length}'); // ← Ver conversión
    } catch (e) {
      print('❌ Error loading expenses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      print('🏁 Carga completada'); // ← Confirmar que terminó
    }
  }
}
