import 'package:flutter/widgets.dart';

import '../database/database_helper.dart';
import '../model/category_expense.dart';
import '../model/expense.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  List<Expense> filteredExpenses = [];
  bool _isLoading = false;
  CategoryExpense? filterCategory;

  List<Expense> get expenses => filteredExpenses;
  bool get isLoading => _isLoading;

  void setFilterCategory(CategoryExpense? category) {
    filterCategory = category;
    applyFilter();
    notifyListeners();
  }

  void applyFilter() {
    if (filterCategory == null) {
      filteredExpenses = _expenses;
    } else {
      filteredExpenses = _expenses.where((expense) {
        return expense.category == filterCategory;
      }).toList();
    }
  }

  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final expensesData = await DatabaseHelper().getExpenses();
      _expenses = expensesData.map((data) => Expense.fromMap(data)).toList();
      applyFilter();
    } catch (e) {
      // ignore: avoid_print
      print('❌ Error loading expenses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateExpense(Expense updateExpense) async {
    try {
      await DatabaseHelper().updateExpense(updateExpense.toMap());
      await loadExpenses();
    } catch (e) {
      throw Exception('❌ Error updating expense: $e');
    }
  }
}
