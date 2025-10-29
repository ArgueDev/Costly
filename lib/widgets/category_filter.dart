import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../model/category_expense.dart';
import '../provider/expense_provider.dart';
import '../theme/app_colors.dart';

class CategoryFilter extends StatefulWidget {
  const CategoryFilter({super.key});

  @override
  State<CategoryFilter> createState() => _CategoryFilterState();
}

class _CategoryFilterState extends State<CategoryFilter> {

  CategoryExpense? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(15),
      child: Row(
        children: [
          Flexible(
            flex: 2,
            child: AutoSizeText(
              'Filtrar Gastos', 
              style: TextStyle(fontSize: 24, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              maxLines: 1,
            )
          ),
          SizedBox(width: 10),
          Flexible(
            flex: 3,
            child: DropdownButtonFormField<CategoryExpense>(
              isExpanded: true,
              initialValue: selectedCategory,
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
                context.read<ExpenseProvider>().setFilterCategory(value);
              },
              decoration: InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)
                )
              ),
              dropdownColor: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text('Todas'),
                ),
                ...CategoryExpense.values.map((categoria) {
                  return DropdownMenuItem(
                    value: categoria,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(categoria.label),
                        Icon(categoria.icon, color: categoria.color)
                      ],
                    )
                  );
                })
              ],
            ),
          ),
        ],
      ),
    );
  }
}
