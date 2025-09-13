import 'package:flutter/widgets.dart';

import '../database/database_helper.dart';
import '../model/expense.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final expensesData = await DatabaseHelper().getExpenses();

      _expenses = expensesData.map((data) => Expense.fromMap(data)).toList();
    } catch (e) {
      // ignore: avoid_print
      print('❌ Error loading expenses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
