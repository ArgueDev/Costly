import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ExpenseForm extends StatelessWidget {
  const ExpenseForm({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Nuevo Gasto'),
      content: Text('Aqui va el form de los gastos'),
      actions: [
        ElevatedButton(
          onPressed: () {
            //TODO:Guardar el gasto en la db
          },
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: Color(0xFF8aaefd),
            backgroundColor: AppColors.azulPrimario,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Center(
            child: Text(
              'Registrar Gasto',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }
}
