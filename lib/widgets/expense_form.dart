import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../model/category_expense.dart';
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Guardar el gasto en la db
      print('NombreGasto: ${_nombreGastoCtrl.text}');
      print('CantidadGasto: ${_cantidadGastoCtrl.text}');
      print('CategoriaGasto: ${_selectedCategory?.label}');
      print('FechaGasto: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}');
      
      // Cerrar el diálogo después de guardar
      Navigator.of(context).pop();
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