import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../database/database_helper.dart';
import '../helpers/format_currency.dart';
import '../helpers/format_date.dart';
import '../model/expense.dart';
import '../provider/budget_provider.dart';
import '../provider/expense_provider.dart';
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
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: expenseProvider.isLoading
      ? Center(child: CircularProgressIndicator())
      : expenseProvider.expenses.isEmpty
          ? Text('No hay gastos', style: TextStyle(fontSize: 30, color: Colors.grey, fontWeight: FontWeight.bold),)
          : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Listado de Gatos', style: TextStyle(fontSize: 30, color: Colors.grey, fontWeight: FontWeight.bold),),
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: expenseProvider.expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenseProvider.expenses[index];
                    return Column(
                      children: [
                        Dismissible(
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
                          child: ListTile(
                            visualDensity: VisualDensity.compact,
                            dense: true,
                            leading: Icon(expense.category.icon, size: 45, color: expense.category.color,),
                            title: Text(expense.description, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              '${expense.category.label} - ${formatDate(expense.date)}',
                              style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w600),
                            ),
                            trailing: Text(formatCurrency(expense.amount), style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                        Divider(color: Colors.grey, thickness: 0.5)
                      ],
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
    showDialog(
      context: context, 
      builder: (context) => ExpenseForm(expenseEdit: expense,)
    );
  }

  Widget? _leftBackground() {
    return Container(
      color: Colors.green,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 20),
      child: Icon(Icons.edit, color: Colors.white, size: 30,),
    );
  }
  
  Widget? _rightBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20),
      child: Icon(Icons.delete, color: Colors.white, size: 30,),
    );
  }
  
  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text('¿Estás seguro de eliminar el gasto?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text('Esta acción no se puede deshacer', style: TextStyle(fontSize: 20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), 
            child: Text('Cancelar')
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), 
            child: Text('Eliminar')
          )
        ],
      )
    );
  }
  
}
