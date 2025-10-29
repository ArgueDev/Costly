import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../provider/budget_provider.dart';
import '../theme/app_colors.dart';
import 'control_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  bool isButtonEnabled = false;

  // Si ya existe un presupuesto, navegar directamente a ControlScreen
  Future<void> checkExistingBudget() async {
    final provider = context.read<BudgetProvider>();
    await provider.loadBudget();

    if (provider.total > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ControlScreen()),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkExistingBudget();
    _controller.addListener(() {
      setState(() {
        final text = _controller.text;
        final value = double.tryParse(text);
        if (text.isEmpty) {
          isButtonEnabled = false;
        } else {
          isButtonEnabled = value != null && value > 0;
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              color: AppColors.primary
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AutoSizeText(
                      'Define tu Presupuesto',
                      style: TextStyle(
                        fontSize: 50,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    SizedBox(height: 20),
                    Image.asset('assets/images/finanza.jpg', fit: BoxFit.cover),
                    SizedBox(height: 20),
                    TextField(
                      style: TextStyle(fontSize: 20),
                      keyboardType: TextInputType.number,
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ej: 300.00',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isButtonEnabled
                          ? () {
                              FocusScope.of(context).unfocus();
                              // print('Presupuesto: ${_controller.text}');
                              final provider = context.read<BudgetProvider>();
                              provider.setBudget(
                                double.tryParse(_controller.text) ?? 0.0,
                              );
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => ControlScreen(),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: Color(0xFF8aaefd),
                        backgroundColor: AppColors.primaryDark,
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 30,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Confirmar y Continuar',
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
