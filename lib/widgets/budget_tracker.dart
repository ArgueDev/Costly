import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/format_currency.dart';
import '../provider/budget_provider.dart';
import '../theme/app_colors.dart';

class BudgetTracker extends StatelessWidget {
  const BudgetTracker({super.key});

  Color getProgressColor(double value) {
    if (value >= 1.0) {
      return Colors.red;
    } else if (value >= 0.90) {
      return Colors.deepOrange;
    } else if (value >= 0.70) {
      return Colors.orange;
    } else {
      return AppColors.primary;
    }
  }

  Widget buildSegmentedProgress(double progress) {
    const int segments = 5;
    const double barHeight = 14;
    const double separatorWidth = 3;

    final safeProgress = progress.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: .circular(20),
      child: SizedBox(
        height: barHeight,
        child: Stack(
          children: [
            // Fondo de la barra
            Container(width: double.infinity, color: Colors.grey.shade200),

            // Progreso continuo
            FractionallySizedBox(
              alignment: .centerLeft,
              widthFactor: safeProgress,
              child: Container(
                decoration: BoxDecoration(
                  color: getProgressColor(safeProgress),
                  borderRadius: .circular(20),
                ),
              ),
            ),

            // Separadores visuales
            Row(
              children: List.generate(segments, (index) {
                if (index == segments - 1) {
                  return const Expanded(child: SizedBox());
                }

                return Expanded(
                  child: Align(
                    alignment: .centerRight,
                    child: Container(
                      width: separatorWidth,
                      height: barHeight,
                      color: Colors.white,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();
    final progress = budget.total > 0
        ? (budget.gastado / budget.total).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: .symmetric(horizontal: 14, vertical: 18),
      margin: .only(top: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .circular(10),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          const Text(
            'Presupuesto del Viaje',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: 4),

          Text(
            formatCurrency(budget.total),
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              const Text('Progreso de gasto'),
              Text(
                '${(progress * 100).toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: getProgressColor(progress),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: progress),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            builder: (context, animatedProgress, _) {
              return buildSegmentedProgress(animatedProgress);
            },
          ),
        ],
      ),
    );
  }
}
