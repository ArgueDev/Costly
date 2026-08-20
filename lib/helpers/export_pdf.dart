import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;

import '../model/expense.dart';
import '../provider/budget_provider.dart';

class ExportPdf {
  static Future<Uint8List> generarPdfExpense(
    List<Expense> expense,
    BudgetProvider budget,
  ) async {
    final pdf = pw.Document();

    final logo = await _loadLogo();

    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Encabezado con logo
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(
                    logo,
                    width: 100,
                    height: 50,
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Reporte de gastos',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        DateFormat('dd/MM/yyyy').format(DateTime.now()),
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Resumen del presupuesto
              pw.Container(
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                padding: const pw.EdgeInsets.all(16),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'Presupuesto',
                      budget.total,
                      PdfColors.blue,
                    ),
                    _buildStatCard(
                      'Disponible',
                      budget.disponible,
                      PdfColors.green,
                    ),
                    _buildStatCard(
                      'Gastado',
                      budget.gastado,
                      PdfColors.red,
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 25),

              // Detalle de gastos
              pw.Text(
                'DETALLE DE GASTOS',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              pw.TableHelper.fromTextArray(
                context: context,
                border: const pw.TableBorder(
                  verticalInside: pw.BorderSide(
                    width: 0.5,
                    color: PdfColors.grey300,
                  ),
                  horizontalInside: pw.BorderSide(
                    width: 0.5,
                    color: PdfColors.grey300,
                  ),
                  bottom: pw.BorderSide(
                    width: 1,
                    color: PdfColors.blue,
                  ),
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blue100,
                ),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
                headerAlignment: pw.Alignment.centerLeft,
                data: <List<dynamic>>[
                  [
                    'Descripción',
                    'Categoría',
                    'Fecha',
                    'Cantidad',
                  ],
                  ...expense.map(
                    (e) => [
                      e.description,
                      e.category.label,
                      DateFormat('dd/MM/yyyy').format(e.date),
                      '\$${e.amount.toStringAsFixed(2)}',
                    ],
                  ),
                  [
                    '',
                    '',
                    'TOTAL:',
                    '\$${budget.gastado.toStringAsFixed(2)}',
                  ],
                ],
              ),

              pw.SizedBox(height: 30),

              // Footer
              pw.Divider(
                color: PdfColors.grey,
              ),

              pw.Text(
                'Este documento fue generado por Costly',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildStatCard(
    String title,
    double value,
    PdfColor color,
  ) {
    return pw.Column(
      children: [
        pw.Text(
          title,
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '\$${value.toStringAsFixed(2)}',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  static Future<pw.MemoryImage> _loadLogo() async {
    final data = await rootBundle.load(
      'assets/icon/icono_costly.png',
    );

    final image = img.decodeImage(
      data.buffer.asUint8List(),
    );

    if (image == null) {
      throw StateError(
        'No se pudo cargar el logo de Costly',
      );
    }

    return pw.MemoryImage(
      img.encodePng(image),
    );
  }
}