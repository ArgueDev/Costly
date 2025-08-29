class Expense {
  double total;
  double disponible;
  double gastado;

  Expense({required this.total,})
    : gastado = 0,
      disponible = total;
  
}