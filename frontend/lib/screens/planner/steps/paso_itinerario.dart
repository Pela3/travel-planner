import 'package:flutter/material.dart';

import '../../../models/parada_confirmada.dart';
import '../../../services/enlaces_externos.dart';
import '../widgets/alojamiento_card.dart';
import '../widgets/atraccion_card.dart';
import '../widgets/buscador_ciudad_manual.dart';
import '../widgets/clima_card.dart';
import '../widgets/cronograma_diario.dart';
import '../widgets/itinerario_hero.dart';
import '../widgets/selector_dias_card.dart';
import '../widgets/traslado_card.dart';
import '../../../theme/app_colors.dart';

// PASO 5: Itinerario con cabecera e información
class PasoItinerario extends StatelessWidget {
  /// Respuesta cruda de /planificar para la parada que se está revisando.
  final Map<String, dynamic>? paradaActual;
  final List<ParadaConfirmada> itinerario;
  final int diasTotales;
  final int diasRestantes;
  final int costoAcumulado;
  final int diasSeleccionados;
  final int diaCronogramaSeleccionado;
  final DateTime fechaInicioParada;

  /// Ciudad desde la que se viaja a esta parada (para buscar pasajes).
  final String ciudadOrigenTraslado;

  final ValueChanged<int> onDiasSeleccionadosChanged;
  final ValueChanged<int> onDiaCronogramaChanged;

  /// Confirma la parada actual. Con ciudad: sigue a esa ciudad; con null: finaliza.
  final ValueChanged<String?> onConfirmar;
  final VoidCallback onExportarPdf;

  /// Error al pedir la siguiente parada (el viaje sigue a medio armar).
  final String? error;

  /// Vuelve a pedir una parada desde la última ciudad confirmada.
  final ValueChanged<String> onReintentar;

  const PasoItinerario({
    super.key,
    required this.paradaActual,
    required this.itinerario,
    required this.diasTotales,
    required this.diasRestantes,
    required this.costoAcumulado,
    required this.diasSeleccionados,
    required this.diaCronogramaSeleccionado,
    required this.fechaInicioParada,
    required this.ciudadOrigenTraslado,
    required this.onDiasSeleccionadosChanged,
    required this.onDiaCronogramaChanged,
    required this.onConfirmar,
    required this.onExportarPdf,
    required this.error,
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    if (paradaActual == null && itinerario.isEmpty) {
      return const Center(child: Text('No hay datos disponibles.', style: TextStyle(color: Colors.white70)));
    }

    final String ciudadNombre = paradaActual?['ciudad_actual'] ?? (itinerario.isNotEmpty ? itinerario.last.ciudad : 'Destino');
    final costoParada = _costoParadaActual();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Hero con foto dinámica
          ItinerarioHero(
            ciudad: ciudadNombre,
            diasUsados: diasTotales - diasRestantes,
            diasTotales: diasTotales,
            // Paradas confirmadas + la que se está viendo con los días elegidos
            // (antes mostraba "~USD 0" hasta confirmar la primera).
            costoAcumulado: costoAcumulado + costoParada,
            onExportarPdf: diasRestantes <= 0 ? onExportarPdf : null,
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (paradaActual != null)
                  ..._buildDetalleParada(paradaActual!, ciudadNombre)
                else if (diasRestantes <= 0)
                  _buildViajeCompletado()
                else
                  ..._buildErrorSiguienteParada(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Costo estimado de la parada en revisión según los días elegidos.
  int _costoParadaActual() {
    final presupuesto = paradaActual?['presupuesto'] as Map<String, dynamic>?;
    final porDia = presupuesto?['total_diario'] as int? ?? 0;
    return porDia * diasSeleccionados;
  }

  List<Widget> _buildDetalleParada(Map<String, dynamic> parada, String ciudadNombre) {
    final diasRecomendadosIA = parada['dias_recomendados'] as int? ?? 2;

    return [
      if (parada['es_fallback'] == true) ...[
        _buildAvisoFallback(),
        const SizedBox(height: 16),
      ],

      // Clima y vestimenta
      if (parada['clima'] != null) ...[
        ClimaCard(clima: parada['clima']),
        const SizedBox(height: 16),
      ],

      // Resumen de la ciudad
      Text(
        parada['resumen'] ?? '',
        style: const TextStyle(color: AppColors.textoSecundario, fontSize: 13, height: 1.4),
      ),
      const SizedBox(height: 20),

      // DÍAS EN ESTA CIUDAD + RECOMENDACIÓN DE LA IA
      SelectorDiasCard(
        diasRecomendados: diasRecomendadosIA,
        diasSeleccionados: diasSeleccionados,
        diasRestantes: diasRestantes,
        costoParada: _costoParadaActual(),
        onChanged: onDiasSeleccionadosChanged,
      ),
      const SizedBox(height: 24),

      // 1° ATRACCIONES & ENTRADAS (ARRIBA DEL CRONOGRAMA)
      const Text(
        'Atracciones & Entradas sugeridas',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      const SizedBox(height: 12),
      ...?(parada['atracciones'] as List<dynamic>?)?.map((a) {
        final String nombreAtraccion = a['nombre'] ?? '';
        return AtraccionCard(
          nombre: nombreAtraccion,
          requiereTicket: a['requiere_ticket'] as bool? ?? false,
          consejo: a['consejo_reserva'] ?? '',
          onReservar: () => EnlacesExternos.abrirCompraEntrada(nombreAtraccion, ciudadNombre),
        );
      }),
      const SizedBox(height: 48),

      AlojamientoCard(
        ciudad: ciudadNombre,
        onVerBooking: () => EnlacesExternos.abrirBooking(ciudadNombre),
      ),

      if (parada['traslado'] != null)
        TrasladoCard(
          traslado: parada['traslado'],
          onBuscarPasajes: () => EnlacesExternos.abrirOmio(ciudadOrigenTraslado, ciudadNombre),
        ),

      // CRONOGRAMA DIARIO
      CronogramaDiario(
        cronograma: (parada['cronograma_dias'] as List<dynamic>?) ?? [],
        diasSeleccionados: diasSeleccionados,
        diaSeleccionado: diaCronogramaSeleccionado,
        fechaInicio: fechaInicioParada,
        onDiaSeleccionado: onDiaCronogramaChanged,
      ),
      const SizedBox(height: 24),

      // Próximas paradas o Finalizar
      if (diasSeleccionados == diasRestantes)
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.exito,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => onConfirmar(null),
            child: const Text('Confirmar y Finalizar Itinerario', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        )
      else ...[
        const Text('Siguiente ciudad sugerida:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 10),
        ...?(parada['proximas_paradas'] as List<dynamic>?)?.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                tileColor: AppColors.superficie,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.borde),
                ),
                leading: const Icon(Icons.directions_train, color: AppColors.primario),
                title: Text(p['ciudad'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('${p['tiempo_traslado']} • ${p['por_que_visitarlo']}', style: const TextStyle(color: AppColors.textoSecundario, fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.textoTenue, size: 14),
                onTap: () => onConfirmar(p['ciudad']),
              ),
            )),
        BuscadorCiudadManual(onBuscar: onConfirmar),
      ],
    ];
  }

  // La IA no respondió y el backend mandó un plan genérico.
  Widget _buildAvisoFallback() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.advertencia.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.advertencia.withValues(alpha: 0.5)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.advertencia, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'La IA no está disponible en este momento. Te mostramos un plan genérico; '
              'podés reintentar en unos minutos para obtener uno personalizado.',
              style: TextStyle(color: Color(0xFFFDE68A), fontSize: 12, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  // Entre paradas: falló la consulta de la siguiente (o se retomó un borrador
  // guardado mientras cargaba). Se puede reintentar sin perder el viaje.
  List<Widget> _buildErrorSiguienteParada() {
    if (error == null) {
      return [
        const Text(
          'Tu viaje está guardado hasta acá. Elegí la próxima ciudad para seguir.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.35),
        ),
        const SizedBox(height: 8),
        BuscadorCiudadManual(onBuscar: onReintentar),
      ];
    }
    return [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.superficie,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.redAccent, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'No pudimos armar la siguiente parada${error != null ? ' ($error)' : ''}. '
                'Tu viaje sigue guardado hasta acá: probá de nuevo o elegí otra ciudad.',
                style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.35),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      BuscadorCiudadManual(onBuscar: onReintentar),
    ];
  }

  // Viaje terminado
  Widget _buildViajeCompletado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.exito),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: AppColors.exito, size: 48),
          const SizedBox(height: 12),
          const Text('¡Viaje completado!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            'Presupuesto total estimado: ~USD $costoAcumulado',
            style: const TextStyle(color: AppColors.textoSecundario, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
