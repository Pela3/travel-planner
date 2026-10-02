import 'package:flutter/material.dart';

import '../../../models/parada_confirmada.dart';
import '../../../services/enlaces_externos.dart';
import '../../../utils/fechas.dart';
import '../../planner/widgets/atraccion_card.dart';
import '../../planner/widgets/clima_card.dart';
import '../../planner/widgets/cronograma_diario.dart';
import '../../planner/widgets/traslado_card.dart';
import '../../../theme/app_colors.dart';

/// Una parada de un viaje guardado, desplegable, con todo su detalle.
class ParadaDetalle extends StatelessWidget {
  final ParadaConfirmada parada;
  final int numero;
  final bool expandidaInicialmente;

  const ParadaDetalle({
    super.key,
    required this.parada,
    required this.numero,
    this.expandidaInicialmente = false,
  });

  @override
  Widget build(BuildContext context) {
    final fechaFin = parada.fechaInicio.add(Duration(days: parada.dias - 1));

    // Material (y no un Container con color) para que el efecto al tocar el
    // ExpansionTile se vea sobre el fondo de la tarjeta.
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: AppColors.superficie,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borde),
        ),
        child: Theme(
          // Sin las líneas divisorias que ExpansionTile dibuja por defecto.
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: expandidaInicialmente,
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            iconColor: AppColors.primario,
            collapsedIconColor: AppColors.textoTenue,
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primario.withValues(alpha: 0.15),
              child: Text(
                '$numero',
                style: const TextStyle(color: AppColors.primario, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            title: Text(
              parada.ciudad,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              '${parada.dias} ${parada.dias == 1 ? 'día' : 'días'} • ${formatearFecha(parada.fechaInicio)} al ${formatearFecha(fechaFin)}'
              '${parada.costoTotalParada > 0 ? ' • ~USD ${parada.costoTotalParada}' : ''}',
              style: const TextStyle(color: AppColors.textoSecundario, fontSize: 12),
            ),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (parada.resumen.isNotEmpty) ...[
                Text(parada.resumen, style: const TextStyle(color: AppColors.textoSecundario, fontSize: 13, height: 1.4)),
                const SizedBox(height: 14),
              ],
              if (parada.traslado != null)
                TrasladoCard(
                  traslado: parada.traslado!.toJson(),
                  onBuscarPasajes: () => EnlacesExternos.abrirOmio(parada.ciudadOrigen, parada.ciudad),
                ),
              if (parada.clima != null) ...[
                ClimaCard(clima: parada.clima!.toJson()),
                const SizedBox(height: 16),
              ],
              if (parada.atracciones.isNotEmpty) ...[
                const _Titulo('Atracciones'),
                ...parada.atracciones.map((a) => AtraccionCard(
                      nombre: a.nombre,
                      requiereTicket: a.requiereTicket,
                      consejo: a.consejoReserva,
                      onReservar: () => EnlacesExternos.abrirCompraEntrada(a.nombre, parada.ciudad),
                    )),
                const SizedBox(height: 8),
              ],
              if (parada.cronograma.isNotEmpty) ...[
                const _Titulo('Cronograma'),
                // Numerado por posición (viajes viejos pueden tener "dia" repetido).
                for (final (i, dia) in parada.cronograma.indexed) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 10),
                    child: Text(
                      'Día ${i + 1} • ${formatearFecha(parada.fechaInicio.add(Duration(days: i)))}',
                      style: const TextStyle(color: AppColors.primario, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  TimelineItem(
                    hora: dia.horarioManana?.split('-').first.trim() ?? '09:30',
                    icono: Icons.wb_twilight,
                    franja: 'Mañana',
                    detalle: dia.manana,
                  ),
                  TimelineItem(
                    hora: dia.horarioTarde?.split('-').first.trim() ?? '14:00',
                    icono: Icons.wb_sunny_outlined,
                    franja: 'Tarde',
                    detalle: dia.tarde,
                  ),
                  TimelineItem(
                    hora: dia.horarioNoche?.split('-').first.trim() ?? '20:30',
                    icono: Icons.nightlight_outlined,
                    franja: 'Noche',
                    detalle: dia.noche,
                    isLast: true,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  final String texto;
  const _Titulo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(texto, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }
}
