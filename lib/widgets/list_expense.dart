import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../helpers/format_currency.dart';
import '../helpers/format_date.dart';
import '../provider/expense_provider.dart';

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
                        ListTile(
                          visualDensity: VisualDensity.compact,
                          dense: true,
                          leading: Icon(expense.category.icon, size: 45, color: expense.category.color,),
                          title: Text(expense.description, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            '${expense.category.label} - ${formatDate(expense.date)}',
                            style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w600),
                          ),
                          trailing: Text(formatCurrency(expense.amount), style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
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
}
