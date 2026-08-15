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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono de la billetera
                Container(
                  padding: .all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: .circle,
                  ),
                  child: const Icon(Icons.wallet, color: Colors.blue, size: 50),
                ),
                // Título y subtítulo
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Define tu ',
                        style: TextStyle(
                          fontSize: 40,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: 'Presupuesto',
                        style: TextStyle(
                          fontSize: 40,
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Establece el monto total de tu viaje. Podrás registrarlo y controlarlo fácilmente.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                Image.asset('assets/images/travel.png', fit: BoxFit.cover),
                SizedBox(height: 20),

                // Campo de texto para ingresar el presupuesto
                Container(
                  height: 64,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50, 
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '\$',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onTapOutside: (_) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: const InputDecoration(
                            hintText: '300.00',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Botón para confirmar y continuar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
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
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    iconAlignment: .end,
                    icon: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 22
                    ),
                    label: Text(
                      'Confirmar y Continuar',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500),
                    )
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
