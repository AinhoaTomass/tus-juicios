import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../ajustes/domain/datos_despacho.dart';
import '../domain/factura.dart';

Future<Uint8List> generarFacturaPdf(Factura factura, DatosDespacho despacho) async {
  // Helvetica (la fuente base de `pdf`) no incluye el símbolo €; Noto Sans sí.
  final fuenteRegular = await PdfGoogleFonts.notoSansRegular();
  final fuenteBold = await PdfGoogleFonts.notoSansBold();
  final doc = pw.Document(theme: pw.ThemeData.withFont(base: fuenteRegular, bold: fuenteBold));

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      despacho.nombre.isEmpty ? 'TusJuicios' : despacho.nombre,
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                    ),
                    if (despacho.nifCif.isNotEmpty) pw.Text(despacho.nifCif),
                    if (despacho.direccion.isNotEmpty) pw.Text(despacho.direccion),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'FACTURA',
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text('Nº ${factura.numero}'),
                    pw.Text(
                      '${factura.fecha.day}/${factura.fecha.month}/${factura.fecha.year}',
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 32),
            pw.Text('Cliente', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(factura.clienteNombre ?? ''),
            if (factura.clienteNifCif != null) pw.Text(factura.clienteNifCif!),
            if (factura.clienteDireccion != null) pw.Text(factura.clienteDireccion!),
            pw.SizedBox(height: 32),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              columnWidths: const {0: pw.FlexColumnWidth(3), 1: pw.FlexColumnWidth(1)},
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Concepto', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Importe',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(factura.concepto ?? '—'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        '${factura.importe.toStringAsFixed(2)} €',
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Total: ${factura.importe.toStringAsFixed(2)} €',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Text('Estado: ${_etiquetaEstado(factura.estado)}'),
          ],
        );
      },
    ),
  );

  return doc.save();
}

String _etiquetaEstado(EstadoFactura estado) => switch (estado) {
      EstadoFactura.pendiente => 'Pendiente de cobro',
      EstadoFactura.pagada => 'Pagada',
      EstadoFactura.vencida => 'Vencida',
    };
