import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:costly/helpers/format_currency.dart';
import 'package:costly/theme/app_colors.dart';
import '../provider/budget_provider.dart';

class BudgetSummaryCard extends StatefulWidget {
  const BudgetSummaryCard({super.key});

  @override
  State<BudgetSummaryCard> createState() => _BudgetSummaryCardState();
}

class _BudgetSummaryCardState extends State<BudgetSummaryCard> {
  @override
  Widget build(BuildContext context) {

    final presupuesto = context.watch<BudgetProvider>();
    final labelStyleSuccess = TextStyle(fontSize: 24, color: AppColors.success, fontWeight: FontWeight.bold);
    final labelStyleError = TextStyle(fontSize: 24, color: AppColors.error, fontWeight: FontWeight.bold);
    final valueStyleSuccess = TextStyle(fontSize: 28, color: AppColors.success, fontWeight: FontWeight.w500);
    final valueStyleError = TextStyle(fontSize: 28, color: AppColors.error, fontWeight: FontWeight.w500);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CardValue(
          labelStyle: labelStyleSuccess,
          labelText: 'Disponible', 
          valueStyle: valueStyleSuccess,
          presupuesto: presupuesto.disponible
        ),
        CardValue(
          labelStyle: labelStyleError,
          labelText: 'Gastado', 
          valueStyle: valueStyleError,
          presupuesto: presupuesto.gastado
        ),
      ],
    );
  }
}

class CardValue extends StatelessWidget {
  const CardValue({
    super.key,
    required this.labelStyle,
    required this.labelText,
    required this.valueStyle,
    required this.presupuesto,
  });

  final TextStyle labelStyle;
  final String labelText;
  final TextStyle valueStyle;
  final double presupuesto;
  

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(labelText, style: labelStyle),
          Text(formatCurrency(presupuesto), style: valueStyle),
        ],
      ),
    );
  }
}