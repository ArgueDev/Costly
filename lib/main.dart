import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:costly/screens/home_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
      theme: ThemeData(
        textTheme: GoogleFonts.bebasNeueTextTheme()
      )
    );
  }
}
