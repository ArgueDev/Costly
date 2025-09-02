import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:costly/provider/budget_provider.dart';
import 'package:costly/screens/home_screen.dart';
import 'package:costly/theme/app_colors.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BudgetProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
        theme: ThemeData(
          colorSchemeSeed: AppColors.azulPrimario
        )
      ),
    );
  }
}
