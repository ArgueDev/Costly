import 'package:flutter/material.dart';

import 'dart:io';

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
  int _selectedIndex = 0;

  void _itemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.6,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: ExpenseForm(),
                  ),
                );
              },
            );
          },
        );
        break;
      case 1:
        exportPDF();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            BudgetTracker(),
            SizedBox(height: 20),
            BudgetSummaryCard(),
            SizedBox(height: 20),
            CategoryFilter(), 
            ListExpense()
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_chart, color: AppColors.primary),
            label: 'Registrar gasto',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt, color: AppColors.fucsia),
            label: 'Exportar PDF',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _itemSelected,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.fucsia,
        ),
      ),
    );
  }

  Future<void> exportPDF() async {
    try {
      final expenses = Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).expenses;
      final budget = Provider.of<BudgetProvider>(context, listen: false);
      final pdfBytes = await ExportPdf.generarPdfExpense(expenses, budget);

      final directory = await getExternalStorageDirectory();
      final downloadsPath = '${directory?.path}/Download';
      final fileName =
          'Costly_Report_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';
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
