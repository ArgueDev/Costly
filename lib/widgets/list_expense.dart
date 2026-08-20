import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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

    return SizedBox(
      width: double.infinity,
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
                  'Gastos del viaje',
                  style: TextStyle(
                    fontSize: 24,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: .zero,
                  itemCount: expenseProvider.expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenseProvider.expenses[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Slidable(
                        key: ValueKey(expense.id),

                        endActionPane: ActionPane(
                          motion: const StretchMotion(),
                          extentRatio: 0.32,
                          children: [
                            CustomSlidableAction(
                              onPressed: (_) {
                                _updateExpense(context, expense);
                              },
                              backgroundColor: Colors.transparent,
                              padding: .zero,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  shape: .circle,
                                ),
                                child: Icon(
                                  Icons.edit_outlined,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ),
                            ),

                            CustomSlidableAction(
                              onPressed: (_) async {
                                final confirmed = await _confirmDelete(context);

                                if (confirmed && context.mounted) {
                                  _deleteExpense(context, expense);
                                }
                              },
                              backgroundColor: Colors.transparent,
                              padding: .zero,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(
                                    alpha: 0.12,
                                  ),
                                  shape: .circle,
                                ),
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  color: AppColors.error,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),

                        child: Card(
                          margin: .zero,
                          elevation: 3,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: .circular(12),
                          ),
                          child: Padding(
                            padding: .all(16),
                            child: Row(
                              spacing: 18,
                              children: [
                                // Ícono de categoría
                                Container(
                                  padding: .all(12),
                                  decoration: BoxDecoration(
                                    color: expense.category.color.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: .circular(10),
                                  ),
                                  child: Icon(
                                    expense.category.icon,
                                    size: 30,
                                    color: expense.category.color,
                                  ),
                                ),

                                // Información del gasto
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: .start,
                                    spacing: 4,
                                    children: [
                                      Text(
                                        expense.description,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: expense.category.color
                                              .withValues(alpha: 0.1),
                                          borderRadius: .circular(6),
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
                                ),
                                Text(
                                  '- ${formatCurrency(expense.amount)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[600],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.grey[400],
                                )
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
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: ExpenseForm(expenseEdit: expense),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        if (isIOS) {
          return CupertinoAlertDialog(
            title: const Text('Eliminar gasto'),
            content: const Text(
              '¿Estás seguro de eliminar este gasto? Esta acción no se puede deshacer.',
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Eliminar'),
              ),
            ],
          );
        }

        return AlertDialog(
          title: const Text('Eliminar gasto'),
          content: const Text(
            '¿Estás seguro de eliminar este gasto? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }
}
