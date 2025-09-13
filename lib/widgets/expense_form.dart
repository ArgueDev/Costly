import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../database/database_helper.dart';
import '../helpers/format_currency.dart';
import '../model/category_expense.dart';
import '../provider/budget_provider.dart';
import '../provider/expense_provider.dart';
import '../theme/app_colors.dart';

class ExpenseForm extends StatefulWidget {
  const ExpenseForm({super.key});

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

  void _validateForm() {
    setState(() {
      _isButtonEnabled = _nombreGastoCtrl.text.isNotEmpty &&
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
        title: Text('Presupuesto Excedido', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
        content: Text('Solo te queda ${formatCurrency(disponible)} para registrar el gasto', style: TextStyle(fontSize: 20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), 
            child: Text('Cerrar')
          )
        ],
      )
    );
  }

  Future<void> _registrarGasto() async {
    final provider = context.read<BudgetProvider>();
    final budgetActual = await DatabaseHelper().getBudget();

    if (budgetActual != null) {
      final monto = double.parse(_cantidadGastoCtrl.text);
      final disponibleActual = budgetActual['disponible'];

      // Validar que el monto no pase del presupuesto
      if (monto > disponibleActual) {
        throw Exception('El monto del gasto excede el presupuesto disponible.');
      }

      final gastado = budgetActual['gastado'] + monto;
      final disponible = budgetActual['disponible'] - monto;

      await DatabaseHelper().insertExpense(
        amount: monto,
        description: _nombreGastoCtrl.text,
        category: _selectedCategory!,
        date: _selectedDate!
      );

      await DatabaseHelper().updateBudget(gastado, disponible);

      provider.updateBudget(gastado, disponible);
    } 
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _registrarGasto();
        // ignore: use_build_context_synchronously
        await context.read<ExpenseProvider>().loadExpenses();
        // ignore: use_build_context_synchronously
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
        'Nuevo Gasto',
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
                    bottom: BorderSide(color: AppColors.azulPrimario, width: 2),
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
                  fillColor: AppColors.azulClaro,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) => _validateRequired(value, 'el nombre del gasto'),
              ),
              SizedBox(height: 20),
              
              // Cantidad del gasto
              TextFormField(
                controller: _cantidadGastoCtrl,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Cantidad',
                  hintText: '0.00',
                  filled: true,
                  fillColor: AppColors.azulClaro,
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
                dropdownColor: AppColors.azulClaro,
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  filled: true,
                  fillColor: AppColors.azulClaro,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: CategoryExpense.values.map((CategoryExpense categoria) {
                  return DropdownMenuItem<CategoryExpense>(
                    value: categoria,
                    child: Text(categoria.label),
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
                    fillColor: AppColors.azulClaro,
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
            backgroundColor: AppColors.azulPrimario,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: Size(double.infinity, 50), // Botón más ancho
          ),
          child: Text(
            'Registrar Gasto',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ],
    );
  }
}