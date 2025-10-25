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
      final disponibleRedondeado = double.parse(disponibleActual.toStringAsFixed(2));

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
    return AlertDialog(
      title: Text(
        _isEditMode ? 'Editar Gasto' : 'Registrar Gasto',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Nombre del gasto
              TextFormField(
                controller: _nombreGastoCtrl,
                decoration: InputDecoration(
                  labelText: 'Nombre Gasto',
                  hintText: 'Agrega el nombre del gasto',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) =>
                    _validateRequired(value, 'el nombre del gasto'),
              ),
              SizedBox(height: 20),

              // Cantidad del gasto
              TextFormField(
                controller: _cantidadGastoCtrl,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Cantidad',
                  hintText: 'Ej: 100.00',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: _validateAmount,
              ),
              SizedBox(height: 20),

              // Categoría del gasto
              DropdownButtonFormField<CategoryExpense>(
                initialValue: _selectedCategory,
                dropdownColor: AppColors.surface,
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                borderRadius: BorderRadius.circular(12),
                items: CategoryExpense.values.map((categoria) {
                  return DropdownMenuItem(
                    value: categoria,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(categoria.label),
                        Icon(categoria.icon, color: categoria.color)
                      ],
                    )
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
              SizedBox(height: 20),

              // Fecha del gasto
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fecha',
                    filled: true,
                    fillColor: AppColors.surface,
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate != null
                            ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                            : 'Selecciona una fecha',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: _isButtonEnabled ? _submitForm : null,
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: Color(0xFF8aaefd),
            backgroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: Size(double.infinity, 50),
          ),
          child: Text(
            _isEditMode ? 'Guardar Cambios' : 'Registrar Gasto',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ],
    );
  }
}
