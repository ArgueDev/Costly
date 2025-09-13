import 'package:costly/database/database_helper.dart';
import 'package:flutter/widgets.dart';

class BudgetProvider with ChangeNotifier {
  double _total = 0;
  double _disponible = 0;
  double _gastado = 0;
  final DatabaseHelper dbHelper = DatabaseHelper();

  double get total => _total;
  double get disponible => _disponible;
  double get gastado => _gastado;

  Future<void> loadBudget() async {
    final budgetData = await dbHelper.getBudget();
    if (budgetData != null) {
      _total = budgetData['total'] ?? 0;
      _disponible = budgetData['disponible'] ?? 0;
      _gastado = budgetData['gastado'] ?? 0;
      notifyListeners();
    }
  }

  void setBudget(double presupuesto) async {
    _total = presupuesto;
    _disponible = presupuesto;
    _gastado = 0;
    await dbHelper.insertBudget(presupuesto);
    notifyListeners();
  }

  void updateBudget(double nuevoGasto, double nuevoDisponible) {
    _gastado = nuevoGasto;
    _disponible = nuevoDisponible;
    notifyListeners();
  }

  Future<void> resetBudget() async {
    await dbHelper.deleteAllData();
    _total = 0;
    _disponible = 0;
    _gastado = 0;
    notifyListeners();
  }
}