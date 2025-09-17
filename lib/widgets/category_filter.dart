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
      margin: EdgeInsets.symmetric(horizontal: 15),
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
      child: Row(
        children: [
          Text('Filtrar Gastos', style: TextStyle(fontSize: 20)),
          SizedBox(width: 20),
          Expanded(
            child: DropdownMenu<CategoryExpense?>(
              initialSelection: selectedCategory,
              onSelected: (CategoryExpense? value) {
                setState(() {
                  selectedCategory = value;
                });
                context.read<ExpenseProvider>().setFilterCategory(value);
              },
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AppColors.azulClaro,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Categoría'),
              ),
              menuStyle: MenuStyle(
                backgroundColor: WidgetStateProperty.all(AppColors.azulClaro),
              ),
              label: Text('Categoria'),
              dropdownMenuEntries: [
                DropdownMenuEntry<CategoryExpense?>(
                  value: null,
                  label: 'Todas'
                ),
                ...CategoryExpense.values.map((categoria) {
                  return DropdownMenuEntry<CategoryExpense?>(
                    value: categoria, 
                    label: categoria.label
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
