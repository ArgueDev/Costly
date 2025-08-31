import 'package:flutter/material.dart';

import 'package:costly/model/category_expense.dart';
import 'package:costly/theme/app_colors.dart';

class CategoryFilter extends StatefulWidget {
  const CategoryFilter({super.key});

  @override
  State<CategoryFilter> createState() => _CategoryFilterState();
}

class _CategoryFilterState extends State<CategoryFilter> {

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
          Text('Filtrar Gastos', style: TextStyle(fontSize: 20),),
          SizedBox(width: 20),
          Expanded(
            child: DropdownMenu(
              menuStyle: MenuStyle(
                backgroundColor: WidgetStateProperty.all(AppColors.azulClaro),
            
              ),
              label: Text('Categoria'),
              dropdownMenuEntries: CategoryExpense.values.map(
                (CategoryExpense categoria) {
                  return DropdownMenuEntry(
                    value: categoria, 
                    label: categoria.label,
                    style: ButtonStyle(
                      textStyle: WidgetStateProperty.all(TextStyle(fontSize: 20)),
                    )
                  );
                }
              ).toList(),
            ),
          )
        ],
      )
    );
  }
}