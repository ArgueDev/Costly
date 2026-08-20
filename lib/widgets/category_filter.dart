import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../model/category_expense.dart';
import '../provider/expense_provider.dart';

class CategoryFilter extends StatefulWidget {
  const CategoryFilter({super.key});

  @override
  State<CategoryFilter> createState() => _CategoryFilterState();
}

class _CategoryFilterState extends State<CategoryFilter> {
  CategoryExpense? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Flexible(
            flex: 3,
            child: DropdownButtonFormField<CategoryExpense>(
              isExpanded: true,
              initialValue: selectedCategory,
              hint: const Row(
                children: [
                  Icon(Icons.filter_alt_outlined, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    'Filtrar por categoría',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
                context.read<ExpenseProvider>().setFilterCategory(value);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              borderRadius: BorderRadius.circular(12),
              items: [
                ...CategoryExpense.values.map((categoria) {
                  return DropdownMenuItem(
                    value: categoria,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(categoria.label),
                        if (categoria.icon != null)
                          Icon(categoria.icon, color: categoria.color),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
