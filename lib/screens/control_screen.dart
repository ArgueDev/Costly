import 'package:flutter/cupertino.dart';
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
import 'home_screen.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Costly',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Row(
            children: [
              // PDF Export Button
              Container(
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.picture_as_pdf_rounded,
                    color: AppColors.primary,
                  ),
                  onPressed: () => exportPDF(),
                ),
              ),

              // Reset Button
              Container(
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.exit_to_app_rounded,
                    color: AppColors.primary,
                  ),
                  onPressed: _confirmResetBudget,
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: .symmetric(horizontal: 20),
        child: Column(
          children: [
            BudgetTracker(),
            SizedBox(height: 20),
            BudgetSummaryCard(),
            SizedBox(height: 20),
            CategoryFilter(),
            SizedBox(height: 20),
            ListExpense(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
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
        },
        backgroundColor: AppColors.primary,
        label: Text('Agregar gasto', style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _confirmResetBudget() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        if (Platform.isIOS) {
          return CupertinoAlertDialog(
            title: const Text('Resetear presupuesto'),
            content: const Text(
              '¿Deseas reiniciar el presupuesto? Esta acción eliminará el estado actual.',
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Resetear'),
              ),
            ],
          );
        }

        return AlertDialog(
          title: const Text('Resetear presupuesto'),
          content: const Text(
            '¿Deseas reiniciar el presupuesto? Esta acción eliminará el estado actual.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Resetear'),
            ),
          ],
        );
      },
    );

    if (shouldReset != true) return;

    // ignore: use_build_context_synchronously
    final presupuesto = context.read<BudgetProvider>();
    await presupuesto.resetBudget();

    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  Future<void> exportPDF() async {
    try {
      final expenses = Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).expenses;
      final budget = Provider.of<BudgetProvider>(context, listen: false);
      final pdfBytes = await ExportPdf.generarPdfExpense(expenses, budget);

      final fileName =
          'Costly_Report_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';

      if (Platform.isIOS) {
        final temporaryDirectory = await getTemporaryDirectory();
        final file = File('${temporaryDirectory.path}/$fileName');
        await file.writeAsBytes(pdfBytes, flush: true);

        final openResult = await OpenFile.open(
          file.path,
          type: 'application/pdf',
          isIOSAppOpen: true,
        );

        if (openResult.type != ResultType.done) {
          throw Exception(openResult.message);
        }
        return;
      }

      final directory = await getExternalStorageDirectory();
      final downloadsPath = '${directory?.path}/Download';
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
