import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'provider/budget_provider.dart';
import 'provider/expense_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) {
          final provider = BudgetProvider();
          provider.loadBudget();
          return provider;
        }),
        ChangeNotifierProvider(create: (context) {
          final provider = ExpenseProvider();
          provider.loadExpenses();
          return provider;
        }),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
        theme: ThemeData(
          colorSchemeSeed: AppColors.primary
        )
      ),
    );
  }
}
