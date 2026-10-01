import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../utils/fechas.dart';
import '../widgets/paso_encabezado.dart';

/// Máximo de días de un viaje (el backend rechaza más).
const int maxDiasViaje = 60;

// PASO 1: Destino
class PasoDestino extends StatelessWidget {
  final TextEditingController destinoController;
  final TextEditingController origenController;
  final TextEditingController diasTotalesController;
  final DateTime fechaSalida;
  final String? error;
  final ValueChanged<DateTime> onFechaSeleccionada;
  final VoidCallback onSiguiente;

  const PasoDestino({
    super.key,
    required this.destinoController,
    required this.origenController,
    required this.diasTotalesController,
    required this.fechaSalida,
    required this.error,
    required this.onFechaSeleccionada,
    required this.onSiguiente,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PasoEncabezado(
            paso: 1,
            etiqueta: 'Destino',
            titulo: '¿A dónde querés viajar?',
            subtitulo: 'Contanos qué te gustaría y armaremos el plan.',
          ),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF131D31),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: TextField(
              controller: destinoController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Destino, país o ciudad...',
                hintStyle: TextStyle(color: Color(0xFF64748B)),
                prefixIcon: Icon(Icons.search, color: Color(0xFF38BDF8)),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Origen
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF131D31),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: TextField(
              controller: origenController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Ciudad de partida (Origen)',
                labelStyle: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                prefixIcon: Icon(Icons.home_outlined, color: Color(0xFF38BDF8), size: 20),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Días totales y Selector de Fecha de salida
          Row(
            children: [
              // Días
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131D31),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: TextField(
                    controller: diasTotalesController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      labelText: 'Días totales',
                      labelStyle: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                      prefixIcon: Icon(Icons.date_range_outlined, color: Color(0xFF38BDF8), size: 18),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Selector interactivo de Fecha
              Expanded(
                flex: 3,
                child: _buildSelectorFecha(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Text('Sugerencias populares', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          _buildSugerenciaTile('Roma, Italia', Icons.history),
          _buildSugerenciaTile('París, Francia', Icons.museum_outlined),
          _buildSugerenciaTile('Madrid, España', Icons.wb_sunny_outlined),

          if (error != null) ...[
            const SizedBox(height: 14),
            Text(error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ],

          const SizedBox(height: 30),
          BotonSiguiente(onPressed: onSiguiente),
        ],
      ),
    );
  }

  Widget _buildSelectorFecha(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: fechaSalida,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 730)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFF38BDF8),
                  onPrimary: Color(0xFF0B111E),
                  surface: Color(0xFF131D31),
                  onSurface: Colors.white,
                ),
                dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF0B111E)),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onFechaSeleccionada(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF131D31),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined, color: Color(0xFF38BDF8), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fecha de salida', style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
                  Text(
                    '${formatearFecha(fechaSalida)} (${nombreMes(fechaSalida)})',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSugerenciaTile(String ciudad, IconData icon) {
    return GestureDetector(
      // El TextField escucha al controller, no hace falta setState.
      onTap: () => destinoController.text = ciudad,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF131D31),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF64748B), size: 18),
            const SizedBox(width: 12),
            Text(ciudad, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
