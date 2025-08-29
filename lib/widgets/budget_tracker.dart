import 'package:flutter/material.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import 'package:costly/provider/budget_provider.dart';
import 'package:costly/screens/home_screen.dart';
import '../theme/app_colors.dart';

class BudgetTracker extends StatefulWidget {
  const BudgetTracker({super.key});

  @override
  State<BudgetTracker> createState() => _BudgetTrackerState();
}

class _BudgetTrackerState extends State<BudgetTracker> {
  
  @override
  Widget build(BuildContext context) {

    final TextStyle valorStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black);
    final presupuesto = context.watch<BudgetProvider>();

    double porcentaje = presupuesto.total > 0
      ? presupuesto.gastado / presupuesto.total
      : 0;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
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
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 100,
            lineWidth: 15,
            percent: porcentaje,
            center: Text(
              '${(porcentaje * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 30, color: AppColors.azulPrimario),
            ),
            progressColor: AppColors.azulPrimario,
            backgroundColor: Color(0xFFf5f5f5),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await presupuesto.resetBudget();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: ( _ ) => HomeScreen())
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.fucsia,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              textStyle: TextStyle(fontSize: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Resetear', style: TextStyle(color: Colors.white)),
          ),
          SizedBox(height: 20),
          //* Presupuesto *//
          RichText(
            text: TextSpan(
              text: 'Presupuesto: ',
              style: TextStyle(color: AppColors.azulPrimario, fontSize: 30),
              children: [
                TextSpan(
                  text: '\$${presupuesto.total}',
                  style: valorStyle,
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          //* Disponible *//
          RichText(
            text: TextSpan(
              text: 'Disponible: ',
              style: TextStyle(color: AppColors.azulPrimario, fontSize: 30),
              children: [
                TextSpan(
                  text: '\$${presupuesto.disponible}',
                  style: valorStyle,
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          //* Gastado *//
          RichText(
            text: TextSpan(
              text: 'Gastado: ',
              style: TextStyle(color: AppColors.azulPrimario, fontSize: 30),
              children: [
                TextSpan(
                  text: '\$${presupuesto.gastado}',
                  style: valorStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
