import 'package:flutter/material.dart';

import '../../../utils/fechas.dart';

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
              style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.w600),
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
          return GestureDetector(
            onTap: () => onDiaSeleccionado(diaNum),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFF38BDF8) : const Color(0xFF131D31),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: sel ? const Color(0xFF38BDF8) : const Color(0xFF1E293B),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Día $diaNum',
                    style: TextStyle(
                      color: sel ? const Color(0xFF0B111E) : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    formatearFecha(fechaDia),
                    style: TextStyle(
                      color: sel ? const Color(0xFF0B111E).withValues(alpha: 0.8) : const Color(0xFF64748B),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // TIMELINE VERTICAL
  Widget _buildTimeline() {
    final actividadDelDia = cronograma.firstWhere(
      (c) => (c['dia'] as int? ?? 1) == diaSeleccionado,
      orElse: () => cronograma.isNotEmpty ? cronograma.first : null,
    );

    if (actividadDelDia == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('Sin actividades detalladas para este día.', style: TextStyle(color: Color(0xFF94A3B8))),
      );
    }

    return Column(
      children: [
        TimelineItem(
          hora: actividadDelDia['horario_manana']?.toString().split('-').first.trim() ?? '09:30',
          franja: '🌅 Mañana (${actividadDelDia['horario_manana'] ?? '09:30'})',
          detalle: actividadDelDia['manana'],
        ),
        TimelineItem(
          hora: actividadDelDia['horario_tarde']?.toString().split('-').first.trim() ?? '14:00',
          franja: '☀️ Tarde (${actividadDelDia['horario_tarde'] ?? '14:00'})',
          detalle: actividadDelDia['tarde'],
        ),
        TimelineItem(
          hora: actividadDelDia['horario_noche']?.toString().split('-').first.trim() ?? '20:30',
          franja: '🌙 Noche (${actividadDelDia['horario_noche'] ?? '20:30'})',
          detalle: actividadDelDia['noche'],
          isLast: true,
        ),
      ],
    );
  }
}

class TimelineItem extends StatelessWidget {
  final String hora;
  final String franja;
  final dynamic detalle;
  final bool isLast;

  const TimelineItem({
    super.key,
    required this.hora,
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
                  color: Color(0xFF94A3B8),
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
                  color: const Color(0xFF38BDF8),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0B111E), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.45),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFF1E293B),
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
                color: const Color(0xFF131D31),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    franja,
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
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
