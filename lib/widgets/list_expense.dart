import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../database/database_helper.dart';
import '../helpers/format_currency.dart';
import '../helpers/format_date.dart';
import '../model/expense.dart';
import '../provider/budget_provider.dart';
import '../provider/expense_provider.dart';
import '../theme/app_colors.dart';
import 'widgets.dart';

class ListExpense extends StatefulWidget {
  const ListExpense({super.key});

  @override
  State<ListExpense> createState() => _ListExpenseState();
}

class _ListExpenseState extends State<ListExpense> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: expenseProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : expenseProvider.expenses.isEmpty
          ? Text(
              'No hay gastos',
              style: TextStyle(
                fontSize: 30,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Listado de Gastos',
                  style: TextStyle(
                    fontSize: 30,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(top: 0),
                  itemCount: expenseProvider.expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenseProvider.expenses[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Dismissible(
                        background: _leftBackground(),
                        secondaryBackground: _rightBackground(),
                        key: Key(expense.id.toString()),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            _updateExpense(context, expense);
                            return false;
                          } else if (direction == DismissDirection.endToStart) {
                            return await _confirmDelete(context);
                          }
                          return false;
                        },
                        onDismissed: (direction) {
                          if (direction == DismissDirection.endToStart) {
                            _deleteExpense(context, expense);
                          }
                        },
                        child: Card(
                          elevation: 3,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Ícono de categoría
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: expense.category.color.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    expense.category.icon,
                                    size: 30,
                                    color: expense.category.color,
                                  ),
                                ),
                                SizedBox(width: 16),
                                // Información del gasto
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              expense.description,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[800],
                                              ),
                                              overflow: TextOverflow.fade,
                                            ),
                                          ),
                                          Text(
                                            '- ${formatCurrency(expense.amount)}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: expense.category.color
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              expense.category.label,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: expense.category.color,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            '•',
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            formatDate(expense.date),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }

  void _deleteExpense(BuildContext context, Expense expense) async {
    try {
      await DatabaseHelper().deleteExpense(expense.id!);
      // ignore: use_build_context_synchronously
      await context.read<BudgetProvider>().removeExpense(expense.amount);
      // ignore: use_build_context_synchronously
      await context.read<ExpenseProvider>().loadExpenses();
    } catch (e) {
      // ignore: avoid_print
      print('❌ Error deleting expense: $e');
    }
  }

  void _updateExpense(BuildContext context, Expense expense) {
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          expand: false,
          builder: ( _ , scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24))
              ),
              padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
              child: SingleChildScrollView(
                controller: scrollController,
                child: ExpenseForm(expenseEdit: expense,),
              ),
            );
          },
        );
      }
    );
  }

  Widget? _leftBackground() {
    return Container(
      color: Colors.green,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 20),
      child: Icon(Icons.edit, color: Colors.white, size: 30),
    );
  }

  Widget? _rightBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20),
      child: Icon(Icons.delete, color: Colors.white, size: 30),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '¿Estás seguro de eliminar el gasto?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          'Esta acción no se puede deshacer',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
