import 'package:flutter/material.dart';

import '../../../utils/fechas.dart';
import '../../../theme/app_colors.dart';

/// Selector de día (chips horizontales) + timeline mañana/tarde/noche.
class CronogramaDiario extends StatelessWidget {
  final List<dynamic> cronograma;
  final int diasSeleccionados;
  final int diaSeleccionado;
  final DateTime fechaInicio;
  final ValueChanged<int> onDiaSeleccionado;

  const CronogramaDiario({
    super.key,
    required this.cronograma,
    required this.diasSeleccionados,
    required this.diaSeleccionado,
    required this.fechaInicio,
    required this.onDiaSeleccionado,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Cronograma diario',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'Día $diaSeleccionado de $diasSeleccionados',
              style: const TextStyle(color: AppColors.primario, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildChipsDias(),
        const SizedBox(height: 18),
        _buildTimeline(),
      ],
    );
  }

  Widget _buildChipsDias() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(diasSeleccionados, (idx) {
          final diaNum = idx + 1;
          final sel = diaSeleccionado == diaNum;
          final fechaDia = fechaInicio.add(Duration(days: idx));
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Semantics(
              button: true,
              selected: sel,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onDiaSeleccionado(diaNum),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primario : AppColors.superficie,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: sel ? AppColors.primario : AppColors.borde,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Día $diaNum',
                          style: TextStyle(
                            color: sel ? AppColors.fondo : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          formatearFecha(fechaDia),
                          style: TextStyle(
                            color: sel ? AppColors.fondo.withValues(alpha: 0.8) : AppColors.textoTenue,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // TIMELINE VERTICAL
  Widget _buildTimeline() {
    // Por posición y no por el campo "dia": la IA a veces numera mal, y al
    // confirmar la parada los días se renumeran 1..N en ese mismo orden.
    final idx = diaSeleccionado - 1;
    if (idx < 0 || idx >= cronograma.length) {
      return _buildDiaPendiente();
    }
    final actividadDelDia = cronograma[idx];

    return Column(
      children: [
        TimelineItem(
          hora: actividadDelDia['horario_manana']?.toString().split('-').first.trim() ?? '09:30',
          icono: Icons.wb_twilight,
          franja: 'Mañana (${actividadDelDia['horario_manana'] ?? '09:30'})',
          detalle: actividadDelDia['manana'],
        ),
        TimelineItem(
          hora: actividadDelDia['horario_tarde']?.toString().split('-').first.trim() ?? '14:00',
          icono: Icons.wb_sunny_outlined,
          franja: 'Tarde (${actividadDelDia['horario_tarde'] ?? '14:00'})',
          detalle: actividadDelDia['tarde'],
        ),
        TimelineItem(
          hora: actividadDelDia['horario_noche']?.toString().split('-').first.trim() ?? '20:30',
          icono: Icons.nightlight_outlined,
          franja: 'Noche (${actividadDelDia['horario_noche'] ?? '20:30'})',
          detalle: actividadDelDia['noche'],
          isLast: true,
        ),
      ],
    );
  }

  // Día elegido más allá de los que precargó la IA: antes se mostraba el
  // día 1 otra vez y parecía duplicado.
  Widget _buildDiaPendiente() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borde),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.primario, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              cronograma.isEmpty
                  ? 'Sin actividades detalladas para este día.'
                  : 'Las actividades del día $diaSeleccionado se generan con IA al confirmar esta parada, sin repetir lugares de los días anteriores.',
              style: const TextStyle(color: AppColors.textoSecundario, fontSize: 12.5, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class TimelineItem extends StatelessWidget {
  final String hora;
  final IconData icono;
  final String franja;
  final dynamic detalle;
  final bool isLast;

  const TimelineItem({
    super.key,
    required this.hora,
    required this.icono,
    required this.franja,
    required this.detalle,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hora estimada
          SizedBox(
            width: 48,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                hora,
                style: const TextStyle(
                  color: AppColors.textoSecundario,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Columna con punto y línea conectora vertical
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.primario,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.fondo, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primario.withValues(alpha: 0.45),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.borde,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          // Tarjeta oscura con la actividad
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.superficie,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borde),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icono, size: 16, color: AppColors.primario),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          franja,
                          style: const TextStyle(
                            color: AppColors.primario,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detalle?.toString() ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
