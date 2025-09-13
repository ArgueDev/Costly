import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:costly/helpers/format_date.dart';
import 'package:costly/provider/expense_provider.dart';
import 'package:costly/helpers/format_currency.dart';

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
          : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: expenseProvider.expenses.length,
              itemBuilder: (context, index) {
                final expense = expenseProvider.expenses[index];
                return ListTile(
                  leading: Icon(expense.category.icon, size: 30),
                  title: Text(expense.description),
                  subtitle: Text(
                    '${expense.category.label} - ${formatDate(expense.date)}',
                  ),
                  trailing: Text(formatCurrency(expense.amount)),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                );
              },
            ),
    );
  }
}
