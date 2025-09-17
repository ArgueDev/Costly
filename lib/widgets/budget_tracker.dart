import 'package:flutter/material.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../helpers/format_currency.dart';
import '../provider/budget_provider.dart';
import '../screens/home_screen.dart';
import '../theme/app_colors.dart';

class BudgetTracker extends StatefulWidget {
  const BudgetTracker({super.key});

  @override
  State<BudgetTracker> createState() => _BudgetTrackerState();
}

class _BudgetTrackerState extends State<BudgetTracker> {
  @override
  Widget build(BuildContext context) {
    final TextStyle valorStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 25,
      color: Colors.black,
    );
    final TextStyle labelStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 25,
      color: AppColors.azulPrimario,
    );
    final presupuesto = context.watch<BudgetProvider>();

    double porcentaje = presupuesto.total > 0
        ? (presupuesto.gastado / presupuesto.total).clamp(0.0, 1.0)
        : 0;

    String porcentajeTexto = presupuesto.total > 0
        ? (porcentaje * 100 % 1 == 0
              ? '${(porcentaje * 100).toInt()}%' // Entero
              : '${(porcentaje * 100).toStringAsFixed(2)}%' // Decimal
                )
        : '0%';

    Color colorPorcentaje = porcentajeTexto == '100%'
        ? Colors.red
        : AppColors.azulPrimario;

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
              porcentajeTexto,
              style: TextStyle(fontSize: 30, color: colorPorcentaje),
            ),
            progressColor: colorPorcentaje,
            backgroundColor: Color(0xFFf5f5f5),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await presupuesto.resetBudget();
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => HomeScreen()),
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
              style: labelStyle,
              children: [
                TextSpan(
                  text: formatCurrency(presupuesto.total),
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
              style: labelStyle,
              children: [
                TextSpan(
                  text: formatCurrency(presupuesto.disponible),
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
              style: labelStyle,
              children: [
                TextSpan(
                  text: formatCurrency(presupuesto.gastado),
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
