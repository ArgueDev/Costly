import 'package:flutter/material.dart';

import 'package:costly/widgets/widgets.dart';

import 'package:costly/theme/app_colors.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Control de gastos',
          style: TextStyle(fontSize: 36, color: Colors.white),
        ),
        backgroundColor: AppColors.azulPrimario,
        centerTitle: true,
      ),
      backgroundColor: AppColors.azulClaro,
      body: Center(
        child: Column(
          children: [
            BudgetTracker()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
