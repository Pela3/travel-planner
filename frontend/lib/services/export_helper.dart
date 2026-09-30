import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/viaje_guardado.dart';

Future<void> compartirOdescargarTexto(String contenido, String nombreArchivo) async {
  if (kIsWeb) {
    // Si corre en Web usamos el share nativo del navegador o share_plus web
    await SharePlus.instance.share(ShareParams(text: contenido, subject: 'Itinerario de Viaje'));
    return;
  }

  // En Android / iOS guardamos en archivo temporal y disparamos la hoja de compartir nativa
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$nombreArchivo');
  await file.writeAsString(contenido);

  await SharePlus.instance.share(ShareParams(
    files: [XFile(file.path)],
    text: '¡Aquí está mi itinerario de viaje planificado!',
    subject: 'Itinerario de Viaje',
  ));
}

String generarItinerarioTexto(ViajeGuardado viaje) {
  final buffer = StringBuffer();
  buffer.writeln('========================================');
  buffer.writeln('          ITINERARIO DE VIAJE           ');
  buffer.writeln('========================================\n');
  buffer.writeln('Ruta: ${viaje.titulo}');
  buffer.writeln('Origen: ${viaje.origenInicial}');
  buffer.writeln('Salida: ${viaje.fechaInicio.day}/${viaje.fechaInicio.month}/${viaje.fechaInicio.year}');
  buffer.writeln('Estilo: ${viaje.estilo} • Duración: ${viaje.diasTotales} días');
  buffer.writeln('Presupuesto Total Estimado: ~USD ${viaje.costoTotalEstimado}\n');
  buffer.writeln('Detalle de paradas:');
  for (var i = 0; i < viaje.paradas.length; i++) {
    final p = viaje.paradas[i];
    buffer.writeln('\n----------------------------------------');
    buffer.writeln('${i + 1}. ${p.ciudad.toUpperCase()} (${p.dias} días)');
    if (p.traslado != null) {
      buffer.writeln('Traslado desde ${p.ciudadOrigen}: ${p.traslado!.medioSugerido} (${p.traslado!.duracionEstimada})');
    }
    if (p.resumen.isNotEmpty) buffer.writeln('Resumen: ${p.resumen}');
  }
  return buffer.toString();
}

Future<void> compartirItinerarioTexto(ViajeGuardado viaje) {
  return compartirOdescargarTexto(generarItinerarioTexto(viaje), 'itinerario_${viaje.id}.txt');
}
