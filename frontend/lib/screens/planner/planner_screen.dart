import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/cronograma.dart';
import '../../services/pdf_generator.dart';
import '../../services/travel_api.dart';
import '../../services/viajes_storage.dart';
import '../../utils/fechas.dart';
import 'steps/paso_compania.dart';
import 'steps/paso_destino.dart';
import 'steps/paso_estilo.dart';
import 'steps/paso_generando.dart';
import 'steps/paso_itinerario.dart';
import 'widgets/planner_header.dart';

class PlannerScreen extends StatefulWidget {
  final String? destinoInicial;

  const PlannerScreen({super.key, this.destinoInicial});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  int _pasoActual = 1; // 1: Destino, 2: Tipo de viaje, 3: Compañía, 4: Loading, 5: Itinerario

  final _origenController = TextEditingController(text: 'Buenos Aires');
  final _destinoController = TextEditingController(text: 'Roma');
  final _diasTotalesController = TextEditingController(text: '10');

  DateTime _fechaSalida = DateTime.now().add(const Duration(days: 30));
  String _estiloSeleccionado = 'cultural';
  String _companiaSeleccionada = 'pareja';

  int _diasTotales = 10;
  int _diasRestantes = 10;
  int _diasSeleccionados = 1;
  int _diaCronogramaSeleccionado = 1;

  bool _isLoading = false;
  int _loadingStep = 0;
  String? _mensajeCarga; // Texto de la pantalla de carga (null = checklist)
  String? _error;

  final List<ParadaConfirmada> _itinerario = [];
  Map<String, dynamic>? _paradaActualData;

  @override
  void initState() {
    super.initState();
    if (widget.destinoInicial != null && widget.destinoInicial!.isNotEmpty) {
      _destinoController.text = widget.destinoInicial!;
    }
  }

  @override
  void didUpdateWidget(covariant PlannerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.destinoInicial != null && widget.destinoInicial != oldWidget.destinoInicial) {
      setState(() {
        _destinoController.text = widget.destinoInicial!;
      });
    }
  }

  @override
  void dispose() {
    _origenController.dispose();
    _destinoController.dispose();
    _diasTotalesController.dispose();
    super.dispose();
  }

  String get _mesDeFechaSalida => nombreMes(_fechaSalida);

  DateTime get _fechaInicioParadaActual {
    int diasAcumulados = _itinerario.fold(0, (acc, p) => acc + p.dias);
    return _fechaSalida.add(Duration(days: diasAcumulados));
  }

  int get _costoAcumuladoItinerario =>
      _itinerario.fold(0, (acc, p) => acc + p.costoTotalParada);

  void _iniciarGeneracion() async {
    final origen = _origenController.text.trim();
    final destino = _destinoController.text.trim();
    final dias = int.tryParse(_diasTotalesController.text.trim()) ?? 10;

    if (origen.isEmpty || destino.isEmpty) {
      setState(() => _error = 'Ingresá origen y destino.');
      return;
    }

    setState(() {
      _diasTotales = dias;
      _diasRestantes = dias;
      _itinerario.clear();
      _error = null;
      _pasoActual = 4; // Pantalla de carga animada
      _isLoading = true;
      _loadingStep = 0;
    });

    // Animación de checklist
    for (int i = 1; i <= 4; i++) {
      await Future.delayed(const Duration(milliseconds: 650));
      if (mounted && _isLoading) {
        setState(() => _loadingStep = i);
      }
    }

    _consultarDestino(origen, destino);
  }

  Future<void> _consultarDestino(String origen, String destino) async {
    setState(() => _error = null);

    try {
      final data = await TravelApi.planificar(
        origen: origen,
        destino: destino,
        diasTotales: _diasTotales,
        diasRestantes: _diasRestantes,
        estilo: _estiloSeleccionado,
        mes: _mesDeFechaSalida,
        compania: _companiaSeleccionada,
      );
      final diasRecomendados = data['dias_recomendados'] as int? ?? 1;

      if (mounted) {
        setState(() {
          _paradaActualData = data;
          _diasSeleccionados = diasRecomendados.clamp(1, _diasRestantes > 0 ? _diasRestantes : 1);
          _isLoading = false;
          _pasoActual = 5; // Ver itinerario
        });
      }
    } on ApiException catch (e) {
      _mostrarErrorConsulta(e.toString());
    } on TimeoutException {
      _mostrarErrorConsulta('El servidor tardó demasiado en responder. Intentá de nuevo.');
    } catch (e) {
      debugPrint('Error consultando destino: $e');
      _mostrarErrorConsulta('No pudimos conectarnos con el servidor. Revisá tu conexión.');
    }
  }

  void _mostrarErrorConsulta(String mensaje) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _error = mensaje;
      // Si ya hay paradas confirmadas no tiramos el viaje: el paso 5 permite
      // reintentar o elegir otra ciudad. Solo la primera parada vuelve al paso 1.
      _pasoActual = _itinerario.isEmpty ? 1 : 5;
    });
  }

  /// Pide a la IA la siguiente parada partiendo de la última ciudad confirmada.
  void _continuarHacia(String ciudad) {
    setState(() {
      _isLoading = true;
      _loadingStep = 2;
      _diaCronogramaSeleccionado = 1;
    });
    _consultarDestino(_itinerario.last.ciudad, ciudad);
  }

  void _avisar(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _confirmarYContinuar(String? siguienteCiudad) async {
    // Evita confirmar dos veces la misma parada con un doble toque.
    if (_paradaActualData == null || _isLoading) return;

    final diasEfectivos = _diasSeleccionados > _diasRestantes ? _diasRestantes : _diasSeleccionados;
    final origen = _itinerario.isEmpty ? _origenController.text.trim() : _itinerario.last.ciudad;

    final rawCronograma = (_paradaActualData!['cronograma_dias'] as List<dynamic>?) ?? [];
    final cronogramaBase = rawCronograma
        .map((c) => ActividadDia.fromJson(c as Map<String, dynamic>))
        .toList();

    // Si el usuario eligió más días de los que precargó la IA, se piden los
    // faltantes (en tandas) antes de confirmar la parada.
    final faltanDias = diasEfectivos > cronogramaBase.length;
    if (faltanDias) {
      final extra = diasEfectivos - cronogramaBase.length;
      setState(() {
        _isLoading = true;
        _mensajeCarga = 'Armando $extra ${extra == 1 ? 'día extra' : 'días extra'} en '
            '${_paradaActualData!['ciudad_actual'] ?? 'tu destino'} sin repetir lugares...';
      });
    }

    final ciudadActual = _paradaActualData!['ciudad_actual'] ?? 'Destino';
    final resultado = await completarCronograma(
      base: cronogramaBase,
      diasObjetivo: diasEfectivos,
      pedirDiasExtra: ({required diaInicio, required diasAdicionales, required lugaresYaVistos}) async {
        try {
          return await TravelApi.extenderCronograma(
            ciudad: ciudadActual,
            estilo: _estiloSeleccionado,
            diaInicio: diaInicio,
            diasAdicionales: diasAdicionales,
            lugaresYaVistos: lugaresYaVistos,
          );
        } catch (e) {
          debugPrint('Error extendiendo cronograma con IA: $e');
          rethrow;
        }
      },
    );
    final cronogramaParseado = resultado.dias;

    if (!mounted) return;
    if (faltanDias) {
      setState(() {
        _isLoading = false;
        _mensajeCarga = null;
      });
    }
    if (!resultado.completo) {
      _avisar('No pudimos generar el detalle de todos los días extra. La parada se guardó igual.');
    }

    final rawAtracciones = (_paradaActualData!['atracciones'] as List<dynamic>?) ?? [];
    final atraccionesParseadas = rawAtracciones
        .map((a) => AtraccionDetallada.fromJson(a as Map<String, dynamic>))
        .toList();

    final rawClima = _paradaActualData!['clima'] as Map<String, dynamic>?;
    final climaParseado = rawClima != null ? InfoClima.fromJson(rawClima) : null;

    final rawPresupuesto = _paradaActualData!['presupuesto'] as Map<String, dynamic>?;
    final presupuestoParseado = rawPresupuesto != null ? PresupuestoEstimado.fromJson(rawPresupuesto) : null;

    final rawTraslado = _paradaActualData!['traslado'] as Map<String, dynamic>?;
    final trasladoParseado = rawTraslado != null ? InfoTraslado.fromJson(rawTraslado) : null;

    setState(() {
      _itinerario.add(ParadaConfirmada(
        ciudad: _paradaActualData!['ciudad_actual'] ?? 'Destino',
        ciudadOrigen: origen,
        dias: diasEfectivos,
        fechaInicio: _fechaInicioParadaActual,
        resumen: _paradaActualData!['resumen'] ?? '',
        traslado: trasladoParseado,
        presupuesto: presupuestoParseado,
        clima: climaParseado,
        atracciones: atraccionesParseadas,
        cronograma: cronogramaParseado,
      ));

      _diasRestantes -= diasEfectivos;
      _paradaActualData = null;
    });

    if (_diasRestantes > 0 && siguienteCiudad != null && siguienteCiudad.isNotEmpty) {
      _continuarHacia(siguienteCiudad);
    } else if (_diasRestantes <= 0) {
      ViajesStorage.guardar(_construirViaje());
    }
  }

  ViajeGuardado _construirViaje() {
    final origen = _origenController.text.trim();
    return ViajeGuardado(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: '$origen ➔ ${_itinerario.map((p) => p.ciudad).join(' ➔ ')}',
      origenInicial: origen,
      estilo: _estiloSeleccionado.toUpperCase(),
      mes: _mesDeFechaSalida,
      fechaInicio: _fechaSalida,
      diasTotales: _diasTotales,
      costoTotalEstimado: _costoAcumuladoItinerario,
      fechaCreacion: DateTime.now(),
      paradas: _itinerario,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B111E),
      body: SafeArea(
        child: Column(
          children: [
            PlannerHeader(
              pasoActual: _pasoActual,
              onVolver: () => setState(() => _pasoActual--),
              onReiniciar: () => setState(() => _pasoActual = 1),
            ),
            const SizedBox(height: 4),

            // Contenido del paso actual expandido
            Expanded(
              child: _buildCurrentPaso(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPaso() {
    switch (_pasoActual) {
      case 2:
        return PasoEstilo(
          estiloSeleccionado: _estiloSeleccionado,
          onEstiloChanged: (id) => setState(() => _estiloSeleccionado = id),
          onSiguiente: () => setState(() => _pasoActual = 3),
        );
      case 3:
        return PasoCompania(
          companiaSeleccionada: _companiaSeleccionada,
          onCompaniaChanged: (id) => setState(() => _companiaSeleccionada = id),
          onGenerar: _iniciarGeneracion,
        );
      case 4:
        return PasoGenerando(loadingStep: _loadingStep);
      case 5:
        if (_isLoading) return PasoGenerando(loadingStep: _loadingStep, mensaje: _mensajeCarga);
        return PasoItinerario(
          paradaActual: _paradaActualData,
          itinerario: _itinerario,
          diasTotales: _diasTotales,
          diasRestantes: _diasRestantes,
          costoAcumulado: _costoAcumuladoItinerario,
          diasSeleccionados: _diasSeleccionados,
          diaCronogramaSeleccionado: _diaCronogramaSeleccionado,
          fechaInicioParada: _fechaInicioParadaActual,
          ciudadOrigenTraslado: _itinerario.isNotEmpty ? _itinerario.last.ciudad : _origenController.text,
          onDiasSeleccionadosChanged: (dias) => setState(() => _diasSeleccionados = dias),
          onDiaCronogramaChanged: (dia) => setState(() => _diaCronogramaSeleccionado = dia),
          onConfirmar: _confirmarYContinuar,
          error: _error,
          onReintentar: _continuarHacia,
          onExportarPdf: () => exportarItinerarioPdf(_construirViaje()),
        );
      case 1:
      default:
        return PasoDestino(
          destinoController: _destinoController,
          origenController: _origenController,
          diasTotalesController: _diasTotalesController,
          fechaSalida: _fechaSalida,
          error: _error,
          onFechaSeleccionada: (fecha) => setState(() => _fechaSalida = fecha),
          onSiguiente: () => setState(() => _pasoActual = 2),
        );
    }
  }
}
