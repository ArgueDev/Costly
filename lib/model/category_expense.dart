import 'package:flutter/material.dart';

enum CategoryExpense {
  comida('Comida', id: 1, icon: Icons.restaurant),
  transporte('Transporte', id: 2, icon: Icons.directions_car),
  hotel('Hotel', id: 3, icon: Icons.hotel),
  entretenimiento('Entretenimiento', id: 4, icon: Icons.movie),
  compras('Compras', id: 5, icon: Icons.shopping_cart),
  otro('Otro', id: 6, icon: Icons.category),
  todo('Todo', id: 7, icon: Icons.all_inclusive_rounded);

  final String label;
  final int id;
  final IconData icon;

  const CategoryExpense(this.label, {
    required this.id, 
    required this.icon
  });

}