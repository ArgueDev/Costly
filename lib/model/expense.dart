import 'category_expense.dart';

class Expense {
  final int? id;
  final double amount;
  final String description;
  final CategoryExpense category;
  final DateTime date;

  Expense({
    this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
  });

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      amount: map['amount'],
      description: map['description'],
      category: CategoryExpense.values.firstWhere(
        (e) =>
            e.id == int.parse(map['category'].toString()), // ← Convertir a int
      ),
      date: DateTime.parse(map['date']),
    );
  }
}
