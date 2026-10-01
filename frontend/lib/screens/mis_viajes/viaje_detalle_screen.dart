import 'package:flutter/material.dart';

import '../../models/viaje_guardado.dart';
import '../../services/export_helper.dart';
import '../../services/pdf_generator.dart';
import '../../services/viajes_storage.dart';
import '../../utils/city_images.dart';
import 'confirmar_eliminar.dart';
import 'widgets/parada_detalle.dart';

/// Itinerario completo de un viaje guardado. Funciona sin internet: todo sale
/// de lo guardado en el dispositivo (solo las fotos necesitan conexión).
///
class ViajeDetalleScreen extends StatelessWidget {
  final ViajeGuardado viaje;

  const ViajeDetalleScreen({super.key, required this.viaje});

  Future<void> _eliminar(BuildContext context) async {
    if (!await confirmarEliminarViaje(context, viaje)) return;
    await ViajesStorage.eliminar(viaje.id);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final ciudadPrincipal = viaje.paradas.isNotEmpty ? viaje.paradas.first.ciudad : 'Destino';
    final f = viaje.fechaInicio;

    return Scaffold(
      backgroundColor: const Color(0xFF0B111E),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: const Color(0xFF0B111E),
            foregroundColor: Colors.white,
            actions: [
              PopupMenuButton<String>(
                color: const Color(0xFF1E293B),
                onSelected: (value) {
                  if (value == 'txt') compartirItinerarioTexto(viaje);
                  if (value == 'delete') _eliminar(context);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'txt',
                    child: ListTile(
                      leading: Icon(Icons.share, color: Colors.white70, size: 20),
                      title: Text('Compartir TXT', style: TextStyle(color: Colors.white, fontSize: 13)),
                      dense: true,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                      title: Text('Eliminar', style: TextStyle(color: Color(0xFFEF4444), fontSize: 13)),
                      dense: true,
                    ),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(start: 56, end: 56, bottom: 14),
              title: Text(
                viaje.titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    // Mismo ancho que en la lista: sin internet se reutiliza la foto en caché.
                    obtenerImagenCiudad(ciudadPrincipal, ancho: 600),
                    fit: BoxFit.cover,
                    // Sin internet queda el fondo liso: el resto de la pantalla sigue andando.
                    errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF1E293B)),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, const Color(0xFF0B111E).withValues(alpha: 0.95)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            sliver: SliverList.list(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Dato(Icons.calendar_month_outlined, 'Salida ${f.day}/${f.month}/${f.year}'),
                    _Dato(Icons.date_range_outlined, '${viaje.diasTotales} días'),
                    _Dato(Icons.place_outlined, '${viaje.paradas.length} ${viaje.paradas.length == 1 ? 'ciudad' : 'ciudades'}'),
                    _Dato(Icons.style_outlined, viaje.estilo),
                    if (viaje.costoTotalEstimado > 0) _Dato(Icons.payments_outlined, '~USD ${viaje.costoTotalEstimado}'),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8),
                      foregroundColor: const Color(0xFF0B111E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('Exportar / Compartir PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () => exportarItinerarioPdf(viaje),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Paradas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                if (viaje.paradas.isEmpty)
                  const Text('Este viaje no tiene paradas guardadas.', style: TextStyle(color: Color(0xFF94A3B8)))
                else
                  for (final (i, parada) in viaje.paradas.indexed)
                    ParadaDetalle(parada: parada, numero: i + 1, expandidaInicialmente: i == 0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _Dato(this.icono, this.texto);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF131D31),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: const Color(0xFF38BDF8), size: 14),
          const SizedBox(width: 6),
          Text(texto, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
