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

    final labelStyleSuccess = const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
    final labelStyleError = const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
    final valueStyleSuccess = TextStyle(
      fontSize: 18,
      color: AppColors.success,
      fontWeight: FontWeight.w700,
    );
    final valueStyleError = TextStyle(
      fontSize: 18,
      color: AppColors.error,
      fontWeight: FontWeight.w700,
    );

    return Row(
      children: [
        Expanded(
          child: CardValue(
            labelStyle: labelStyleSuccess,
            labelText: 'Disponible',
            valueStyle: valueStyleSuccess,
            presupuesto: presupuesto.disponible,
            icon: Icons.account_balance_wallet_outlined,
            iconColor: AppColors.success,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: CardValue(
            labelStyle: labelStyleError,
            labelText: 'Gastado',
            valueStyle: valueStyleError,
            presupuesto: presupuesto.gastado,
            icon: Icons.money_off_csred_outlined,
            iconColor: AppColors.error,
          ),
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
    required this.icon,
    required this.iconColor,
  });

  final TextStyle labelStyle;
  final String labelText;
  final TextStyle valueStyle;
  final double presupuesto;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: .all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: .circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                Text(
                  labelText,
                  style: labelStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  formatCurrency(presupuesto),
                  style: valueStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}