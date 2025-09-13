import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/widgets.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Control de gastos',
          style: TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.azulPrimario,
        centerTitle: true,
      ),
      backgroundColor: AppColors.azulClaro,
      body: SingleChildScrollView(
      physics: ScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
        child: Center(
          child: Column(
            children: [
              BudgetTracker(),
              CategoryFilter(),
              ListExpense()
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context, 
            builder: (BuildContext context) => ExpenseForm()
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
