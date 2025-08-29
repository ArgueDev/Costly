import 'package:flutter/material.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';

import '../theme/app_colors.dart';

class BudgetTracker extends StatelessWidget {
  const BudgetTracker({super.key});


  @override
  Widget build(BuildContext context) {
    
    final TextStyle valorStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black);

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
            percent: 0.5,
            center: Text(
              '50%',
              style: TextStyle(fontSize: 30, color: AppColors.azulPrimario),
            ),
            progressColor: AppColors.azulPrimario,
            backgroundColor: Color(0xFFf5f5f5),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              //TODO:Formatea el sharedpreferences y reinicia el presupuesto
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
                  text: '\$1000',
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
                  text: '\$1000',
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
                  text: '\$0',
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
