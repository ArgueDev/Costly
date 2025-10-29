import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../database/database_helper.dart';
import '../helpers/format_currency.dart';
import '../model/category_expense.dart';
import '../model/expense.dart';
import '../provider/budget_provider.dart';
import '../provider/expense_provider.dart';
import '../theme/app_colors.dart';

class ExpenseForm extends StatefulWidget {
  final Expense? expenseEdit;
  const ExpenseForm({super.key, this.expenseEdit});

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreGastoCtrl = TextEditingController();
  final TextEditingController _cantidadGastoCtrl = TextEditingController();

  CategoryExpense? _selectedCategory;
  DateTime? _selectedDate;
  bool _isButtonEnabled = false;
  bool get _isEditMode => widget.expenseEdit != null;

  void _validateForm() {
    setState(() {
      _isButtonEnabled =
          _nombreGastoCtrl.text.isNotEmpty &&
          _cantidadGastoCtrl.text.isNotEmpty &&
          _selectedCategory != null &&
          _selectedDate != null;
    });
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa $fieldName';
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa la cantidad';
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Ingresa una cantidad válida mayor a 0';
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime(2050),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
      _validateForm();
    }
  }

  void showError(double disponible) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.warning_rounded, color: Colors.red, size: 50),
        title: Text(
          'Presupuesto Excedido',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        content: Text(
          'Solo te queda ${formatCurrency(disponible)} para registrar el gasto',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _registrarGasto() async {
    final provider = context.read<BudgetProvider>();
    final budgetActual = await DatabaseHelper().getBudget();

    if (budgetActual != null) {
      final monto = double.parse(_cantidadGastoCtrl.text);
      final disponibleActual = budgetActual['disponible'];

      final montoRedondeado = double.parse(monto.toStringAsFixed(2));
      final disponibleRedondeado = double.parse(
        disponibleActual.toStringAsFixed(2),
      );

      // Validar que el monto no pase del presupuesto
      if (montoRedondeado > disponibleRedondeado) {
        throw Exception('El monto del gasto excede el presupuesto disponible.');
      }

      final gastado = budgetActual['gastado'] + monto;
      final disponible = budgetActual['disponible'] - monto;

      await DatabaseHelper().insertExpense(
        amount: monto,
        description: _nombreGastoCtrl.text,
        category: _selectedCategory!,
        date: _selectedDate!,
      );

      await DatabaseHelper().updateBudget(gastado, disponible);

      provider.updateBudget(gastado, disponible);
    }
  }

  Future<void> _updateExpense() async {
    final budgetProvider = context.read<BudgetProvider>();
    final expenseProvider = context.read<ExpenseProvider>();

    if (widget.expenseEdit != null) {
      final montoNuevo = double.parse(_cantidadGastoCtrl.text);
      final montoViejo = widget.expenseEdit!.amount;
      final diferencia = montoNuevo - montoViejo;
      final disponibleActual = budgetProvider.disponible;

      // ✅ VALIDACIÓN CORRECTA:
      if (diferencia > disponibleActual) {
        throw Exception(
          'No tienes suficiente presupuesto para este aumento. '
          'Solo tienes \$$disponibleActual disponible.',
        );
      }

      final updateExpense = Expense(
        id: widget.expenseEdit!.id,
        amount: montoNuevo,
        description: _nombreGastoCtrl.text,
        category: _selectedCategory!,
        date: _selectedDate!,
      );

      await expenseProvider.updateExpense(updateExpense);

      final nuevoGastado = budgetProvider.gastado + diferencia;
      final nuevoDisponible = budgetProvider.disponible - diferencia;

      await budgetProvider.updateBudget(nuevoGastado, nuevoDisponible);
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (_isEditMode) {
          await _updateExpense();
        } else {
          await _registrarGasto();
        }

        // ignore: use_build_context_synchronously
        await context.read<ExpenseProvider>().loadExpenses();

        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop(true);
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop(false);
        }
        showError((await DatabaseHelper().getBudget())?['disponible'] ?? 0);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _nombreGastoCtrl.text = widget.expenseEdit!.description;
      _cantidadGastoCtrl.text = widget.expenseEdit!.amount.toString();
      _selectedCategory = widget.expenseEdit!.category;
      _selectedDate = widget.expenseEdit!.date;
      _validateForm();
    }

    _nombreGastoCtrl.addListener(_validateForm);
    _cantidadGastoCtrl.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nombreGastoCtrl.dispose();
    _cantidadGastoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(
          context,
        ).viewInsets.bottom, // ✅ para que suba con el teclado
        left: 16,
        right: 16,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 5,
                width: 60,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            Center(
              child: Text(
                _isEditMode ? 'Editar Gasto' : 'Registrar Gasto',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
            ),
            SizedBox(height: 20),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Campo nombre
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    margin: EdgeInsets.only(bottom: 18),
                    child: TextFormField(
                      controller: _nombreGastoCtrl,
                      decoration: _decoracionInput(
                        "Nombre del gasto",
                        Icons.edit,
                        AppColors.primary,
                        hint: 'Ej. Almuerzo, Cine, etc.',
                      ),
                      validator: (value) =>
                          _validateRequired(value, 'El nombre del gasto'),
                    ),
                  ),

                  // Campo cantidad
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    margin: EdgeInsets.only(bottom: 18),
                    child: TextFormField(
                      controller: _cantidadGastoCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _decoracionInput(
                        "Cantidad del gasto",
                        Icons.attach_money,
                        AppColors.success,
                        hint: 'Ej. 100.00',
                      ),
                      validator: _validateAmount,
                    ),
                  ),

                  // Campo categoría
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    margin: EdgeInsets.only(bottom: 18),
                    child: DropdownButtonFormField<CategoryExpense>(
                      initialValue: _selectedCategory,
                      dropdownColor: AppColors.surface,
                      hint: Text(
                        'Selecciona una categoría',
                        style: TextStyle(color: AppColors.marron),
                      ),
                      decoration: _decoracionInput(
                        'Categoria',
                        Icons.category_rounded,
                        AppColors.marron,
                      ),
                      items: CategoryExpense.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(category.label),
                              Icon(category.icon, color: category.color),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (CategoryExpense? value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                        _validateForm();
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor selecciona una categoría';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Campo fecha
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    margin: EdgeInsets.only(bottom: 30),
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: _decoracionInput(
                          'Fecha del gasto',
                          Icons.date_range_rounded,
                          AppColors.purpura,
                        ),
                        child: Row(
                          children: [
                            Text(
                              _selectedDate != null
                                  ? DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(_selectedDate!)
                                  : 'Selecciona una fecha',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Botón registrar o actualizar
                  Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isButtonEnabled ? _submitForm : null,
                        icon: Icon(Icons.add_rounded, size: 22),
                        label: Text(
                          _isEditMode ? 'Guardar Cambios' : 'Registrar Gasto',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                          shadowColor: Colors.black26,
                        ),
                      ),
                    ),
                  ),

                  // Card resumen
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF007AFF)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Verifica los datos antes de registrar el gasto.",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoracionInput(
    String label,
    IconData icon,
    Color color, {
    String hint = '',
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[500]),
      prefixIcon: Icon(icon, color: color),
      filled: true,
      fillColor: Colors.grey[100],
      labelStyle: TextStyle(fontSize: 15, color: color),
      contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.transparent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.border),
      ),
    );
  }
}
