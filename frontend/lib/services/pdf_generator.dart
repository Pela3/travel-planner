import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/viaje_guardado.dart';

Future<void> exportarItinerarioPdf(ViajeGuardado viaje) async {
  final pdf = pw.Document();

  final fontRegular = await PdfGoogleFonts.openSansRegular();
  final fontBold = await PdfGoogleFonts.openSansBold();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => [
        // Encabezado
        pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(width: 2, color: PdfColors.indigo)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('ITINERARIO DE VIAJE', style: pw.TextStyle(font: fontBold, fontSize: 22, color: PdfColors.indigo900)),
                  pw.SizedBox(height: 4),
                  pw.Text(viaje.titulo, style: pw.TextStyle(font: fontBold, fontSize: 13, color: PdfColors.grey800)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Estilo: ${viaje.estilo}', style: pw.TextStyle(font: fontBold, fontSize: 11)),
                  pw.Text('${viaje.diasTotales} Días • ${viaje.mes}', style: pw.TextStyle(font: fontRegular, fontSize: 10, color: PdfColors.grey700)),
                  pw.Text('Costo est: ~USD ${viaje.costoTotalEstimado}', style: pw.TextStyle(font: fontBold, fontSize: 11, color: PdfColors.green900)),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 16),

        // Paradas
        ...viaje.paradas.map((parada) {
          final fechaFin = parada.fechaInicio.add(Duration(days: parada.dias - 1));
          final fechaStr = '${parada.fechaInicio.day}/${parada.fechaInicio.month} al ${fechaFin.day}/${fechaFin.month}';

          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 16),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(parada.ciudad.toUpperCase(), style: pw.TextStyle(font: fontBold, fontSize: 15, color: PdfColors.indigo800)),
                    pw.Text('${parada.dias} días ($fechaStr)', style: pw.TextStyle(font: fontBold, fontSize: 11, color: PdfColors.grey700)),
                  ],
                ),
                if (parada.traslado != null) ...[
                  pw.SizedBox(height: 6),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(6),
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.orange50,
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text(
                      'Traslado desde ${parada.ciudadOrigen}: ${parada.traslado!.medioSugerido} (${parada.traslado!.duracionEstimada}) - ${parada.traslado!.consejoLogistica}',
                      style: pw.TextStyle(font: fontRegular, fontSize: 9, color: PdfColors.orange900),
                    ),
                  ),
                ],
                if (parada.resumen.isNotEmpty) ...[
                  pw.SizedBox(height: 6),
                  pw.Text(parada.resumen, style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                ],
                if (parada.atracciones.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  pw.Text('Atracciones & Entradas:', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                  ...parada.atracciones.map(
                    (a) => pw.Bullet(
                      text: '${a.nombre}${a.requiereTicket ? " [Requiere Ticket]" : ""}: ${a.consejoReserva}',
                      style: pw.TextStyle(font: fontRegular, fontSize: 9),
                    ),
                  ),
                ],
                if (parada.cronograma.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  pw.Text('Cronograma de actividades:', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                  ...parada.cronograma.map(
                    (c) => pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 3),
                      child: pw.Text(
                        'Día ${c.dia}: M: ${c.manana} | T: ${c.tarde} | N: ${c.noche}',
                        style: pw.TextStyle(font: fontRegular, fontSize: 8.5, color: PdfColors.grey800),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    ),
  );

  final pdfBytes = await pdf.save();

  if (kIsWeb) {
    await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
    return;
  }

  // En Android / iOS: guardamos archivo y compartimos directamente
  final dir = await getTemporaryDirectory();
  final safeTitle = viaje.titulo.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  final file = File('${dir.path}/itinerario_$safeTitle.pdf');
  await file.writeAsBytes(pdfBytes);

  await SharePlus.instance.share(ShareParams(
    files: [XFile(file.path, mimeType: 'application/pdf')],
    subject: 'Itinerario de Viaje - ${viaje.titulo}',
    text: 'Te comparto el itinerario completo en PDF.',
  ));
}