import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum CategoryExpense {
  comida('Comida', id: 1, icon: Icons.restaurant, color: AppColors.naranja),
  transporte('Transporte', id: 2, icon: Icons.directions_car, color: AppColors.azulPrimario),
  hotel('Hotel', id: 3, icon: Icons.hotel, color: AppColors.purpura),
  entretenimiento('Entretenimiento', id: 4, icon: Icons.movie, color: AppColors.fucsia),
  compras('Compras', id: 5, icon: Icons.shopping_cart, color: AppColors.verde),
  otro('Otro', id: 6, icon: Icons.category, color: AppColors.marron);

  final String label;
  final int id;
  final IconData icon;
  final Color color;

  const CategoryExpense(this.label, {
    required this.id, 
    required this.icon,
    required this.color
  });

}