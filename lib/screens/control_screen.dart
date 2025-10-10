import 'package:flutter/material.dart';

import 'dart:io';

import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../helpers/export_pdf.dart';
import '../provider/budget_provider.dart';
import '../provider/expense_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/widgets.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {

  final _key = GlobalKey<ExpandableFabState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Control de gastos',
          style: TextStyle(
            fontSize: 36,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.azulPrimario,
        centerTitle: true,
      ),
      backgroundColor: AppColors.azulClaro,
      body: SingleChildScrollView(
        physics: ScrollPhysics(parent: BouncingScrollPhysics()),
        child: Center(
          child: Column(
            children: [BudgetTracker(), CategoryFilter(), ListExpense()],
          ),
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _key,
        type: ExpandableFabType.fan,
        childrenAnimation: ExpandableFabAnimation.none,
        distance: 70,
        overlayStyle: ExpandableFabOverlayStyle(
          blur: 3
        ),
        children: [
          FloatingActionButton.extended(
            heroTag: null,
            onPressed: () {
              _key.currentState?.toggle();
                exportPDF(); 
            },
            label: Text('Exportar PDF'),
            icon: Icon(Icons.receipt),
            foregroundColor: AppColors.fucsia,
          ),
          FloatingActionButton.extended(
            heroTag: null,
            onPressed: () {
              _key.currentState?.toggle();
              showDialog(context: context, builder: (context) => ExpenseForm());
            },
            label: Text('Registrar gasto'),
            icon: Icon(Icons.add_chart),
            foregroundColor: AppColors.azulPrimario,
          ),
        ]
      )
    );
  }

  Future<void> exportPDF() async {
    try {
      final expenses = Provider.of<ExpenseProvider>(context, listen: false).expenses;
      final budget = Provider.of<BudgetProvider>(context, listen: false);
      final pdfBytes = await ExportPdf.generarPdfExpense(expenses, budget);

      final directory = await getExternalStorageDirectory();
      final downloadsPath = '${directory?.path}/Download';
      final fileName = 'Costly_Report_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';
      final file = File('$downloadsPath/$fileName');
      
      await Directory(downloadsPath).create(recursive: true);
      await file.writeAsBytes(pdfBytes);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF exportado: $fileName'),
          backgroundColor: Colors.green,
        ),
      );

      OpenFile.open(file.path);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al exportar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
