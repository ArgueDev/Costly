import 'package:auto_size_text/auto_size_text.dart';
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

    final presupuesto = context.watch<BudgetProvider>();
    
    Color colorPorcentaje = AppColors.success;
    Color colorPorcentajeText = AppColors.surface;

    double porcentaje = presupuesto.total > 0
        ? (presupuesto.gastado / presupuesto.total).clamp(0.0, 1.0)
        : 0;

    String porcentajeTexto = presupuesto.total > 0
        ? (porcentaje * 100 % 1 == 0
              ? '${(porcentaje * 100).toInt()}%'
              : '${(porcentaje * 100).toStringAsFixed(2)}%'
                )
        : '0%';

    if (porcentaje == 1) {
      colorPorcentaje = AppColors.error;
      colorPorcentajeText = AppColors.error;
    } else if (porcentaje > 0.7) {
      colorPorcentaje = AppColors.warning;
      colorPorcentajeText = AppColors.warning;
    } else {
      colorPorcentaje = AppColors.success;
      colorPorcentajeText = AppColors.surface;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 20, right: 20, top: 80, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topRight,
          colors: [
            AppColors.background,
            AppColors.primary,
          ],
          stops: [0.0, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(60),
          bottomRight: Radius.circular(60),
        )
      ),
      child: Row(
        children: [
          Column(
            children: [
              CircularPercentIndicator(
                radius: 80,
                lineWidth: 12,
                percent: porcentaje,
                center: Text(
                  porcentajeTexto,
                  style: TextStyle(fontSize: 30, color: colorPorcentajeText, fontWeight: FontWeight.bold),
                ),
                progressColor: colorPorcentaje,
                backgroundColor: AppColors.surface,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ],
          ),
          SizedBox(width: 30),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //* Presupuesto *//
                AutoSizeText(
                  'Presupuesto', 
                  style: TextStyle(fontSize: 24, color: AppColors.surface, fontWeight: FontWeight.bold),
                  maxLines: 1,
                ),
                AutoSizeText(
                  formatCurrency(presupuesto.total), 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: AppColors.surface),
                  maxLines: 1,
                ),
                SizedBox(height: 10,),
                ElevatedButton(
                  onPressed: () async {
                    await presupuesto.resetBudget();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => HomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: AutoSizeText(
                    'Resetear', 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
