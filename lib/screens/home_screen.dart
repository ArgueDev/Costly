import 'package:flutter/material.dart';

import 'package:costly/theme/app_colors.dart';
import 'control_screen.dart';

class HomeScreen extends StatefulWidget {
    const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

    final TextEditingController _controller = TextEditingController();

    bool isButtonEnabled = false;

    @override
    void initState() {
      super.initState();
      _controller.addListener(() {
        setState(() {
          isButtonEnabled = _controller.text.isNotEmpty;
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
      appBar: AppBar(
        title: Text(
          'Control de gastos', 
          style: TextStyle(fontSize: 36, color: Colors.white)
        ),
        backgroundColor: AppColors.azulPrimario,
        centerTitle: true,
      ),
      backgroundColor: AppColors.azulClaro,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              )
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Definir Presupuesto',
                style: TextStyle(fontSize: 50, color: AppColors.azulPrimario),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextField(
                style: TextStyle(fontSize: 20),
                keyboardType: TextInputType.number,
                controller: _controller,
                decoration: InputDecoration(
                  hintText: '0',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      style: BorderStyle.none,
                      color: AppColors.azulPrimario
                    )
                  )
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isButtonEnabled
                ? () {
                    FocusScope.of(context).unfocus();
                    // print('Presupuesto: ${_controller.text}');
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => ControlScreen())
                    );
                  }
                : null,
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: Color(0xFF8aaefd),
                  backgroundColor: AppColors.azulPrimario,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  )
                ),
                child: Text('Definir Presupuesto', style: TextStyle(color: Colors.white, fontSize: 22),)
              )
            ],
          ),
        ),
      ),
   );
  }
}