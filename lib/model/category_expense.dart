enum CategoryExpense {
  comida('Comida', id: 1),
  transporte('Transporte', id: 2),
  hotel('Hotel', id: 3),
  entretenimiento('Entretenimiento', id: 4),
  compras('Compras', id: 5),
  otro('Otro', id: 6),
  todo('Todo', id: 7);

  final String label;
  final int id;

  const CategoryExpense(this.label, {required this.id});

}