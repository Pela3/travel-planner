import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/borrador_storage.dart';
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
import '../../theme/app_colors.dart';
import '../../utils/validaciones.dart';

class PlannerScreen extends StatefulWidget {
  final String? destinoInicial;
  final String? estiloInicial;

  /// Se llama si el usuario elige retomar un viaje a medio planificar, para
  /// mostrar la pestaña del planificador.
  final VoidCallback? onRetomarBorrador;

  const PlannerScreen({super.key, this.destinoInicial, this.estiloInicial, this.onRetomarBorrador});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  int _pasoActual = 1; // 1: Destino, 2: Tipo de viaje, 3: Compañía, 4: Loading, 5: Itinerario

  // Vacíos: el paso 1 muestra ejemplos en gris en vez de datos ya cargados.
  final _origenController = TextEditingController();
  final _destinoController = TextEditingController();
  final _diasTotalesController = TextEditingController();

  DateTime _fechaSalida = DateTime.now().add(const Duration(days: 30));
  // null hasta que el usuario elige (el estilo puede venir del inicio).
  String? _estiloSeleccionado;
  String? _companiaSeleccionada;

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
    if (widget.estiloInicial != null) _estiloSeleccionado = widget.estiloInicial!;
    WidgetsBinding.instance.addPostFrameCallback((_) => _ofrecerBorrador());
  }

  /// Si la app se cerró a mitad de una planificación, pregunta si retomarla.
  Future<void> _ofrecerBorrador() async {
    final borrador = await BorradorStorage.cargar();
    if (borrador == null || !mounted) return;

    final retomar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.superficie,
        title: const Text('¿Retomar tu viaje?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Cerraste la app a mitad de la planificación de:\n\n'
          '${borrador.recorrido}\n'
          '${borrador.diasPlanificados > 0 ? '${borrador.diasPlanificados} de ${borrador.diasTotales} días armados.' : 'Estabas por confirmar la primera parada.'}\n\n'
          '¿Querés seguir donde lo dejaste?',
          style: const TextStyle(color: AppColors.textoClaro, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, empezar de cero', style: TextStyle(color: AppColors.textoSecundario)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, retomar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (retomar == true) {
      _restaurar(borrador);
      widget.onRetomarBorrador?.call();
    } else {
      BorradorStorage.borrar();
    }
  }

  void _restaurar(BorradorViaje b) {
    setState(() {
      _origenController.text = b.origen;
      _destinoController.text = b.destino;
      _diasTotalesController.text = '${b.diasTotales}';
      _fechaSalida = b.fechaSalida;
      _estiloSeleccionado = b.estilo;
      _companiaSeleccionada = b.compania;
      _diasTotales = b.diasTotales;
      _diasRestantes = b.diasRestantes;
      _diasSeleccionados = b.diasSeleccionados;
      _diaCronogramaSeleccionado = 1;
      _itinerario
        ..clear()
        ..addAll(b.itinerario);
      _paradaActualData = b.paradaActual;
      _error = null;
      _isLoading = false;
      _pasoActual = 5;
    });
  }

  /// Guarda el viaje en curso para poder retomarlo. Solo vale la pena desde
  /// que hay itinerario (antes es cargar 3 datos) y hasta que se completa.
  void _guardarBorrador() {
    final hayAlgo = _itinerario.isNotEmpty || _paradaActualData != null;
    if (_pasoActual != 5 || !hayAlgo || _diasRestantes <= 0) return;
    BorradorStorage.guardar(BorradorViaje(
      origen: _origenController.text.trim(),
      destino: _destinoController.text.trim(),
      fechaSalida: _fechaSalida,
      estilo: _estilo,
      compania: _companiaSeleccionada!,
      diasTotales: _diasTotales,
      diasRestantes: _diasRestantes,
      diasSeleccionados: _diasSeleccionados,
      itinerario: List.of(_itinerario),
      paradaActual: _paradaActualData,
    ));
  }

  @override
  void didUpdateWidget(covariant PlannerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.destinoInicial != null &&
        (widget.destinoInicial != oldWidget.destinoInicial || widget.estiloInicial != oldWidget.estiloInicial)) {
      setState(() {
        _destinoController.text = widget.destinoInicial!;
        if (widget.estiloInicial != null) _estiloSeleccionado = widget.estiloInicial!;
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

  /// Desde la generación del itinerario el estilo ya está elegido.
  String get _estilo => _estiloSeleccionado!;

  String get _mesDeFechaSalida => nombreMes(_fechaSalida);

  DateTime get _fechaInicioParadaActual {
    int diasAcumulados = _itinerario.fold(0, (acc, p) => acc + p.dias);
    return _fechaSalida.add(Duration(days: diasAcumulados));
  }

  int get _costoAcumuladoItinerario =>
      _itinerario.fold(0, (acc, p) => acc + p.costoTotalParada);

  /// Valida los datos del paso 1. Devuelve el mensaje de error o null.
  String? _validarDatosViaje() {
    if (_destinoController.text.trim().isEmpty) return 'Ingresá un destino.';
    if (_origenController.text.trim().isEmpty) return 'Ingresá tu ciudad de partida.';
    final errorNombre = validarNombreLugar(_destinoController.text, campo: 'El destino') ??
        validarNombreLugar(_origenController.text, campo: 'La ciudad de partida');
    if (errorNombre != null) return errorNombre;
    final dias = int.tryParse(_diasTotalesController.text.trim());
    if (dias == null || dias < 1 || dias > maxDiasViaje) {
      return 'Los días totales tienen que estar entre 1 y $maxDiasViaje.';
    }
    return null;
  }

  /// Vuelve al paso 1. Si hay un viaje a medio armar, pide confirmación
  /// (antes un toque sin querer en "refrescar" perdía todas las paradas).
  Future<void> _reiniciar() async {
    final hayViajeEnCurso = _itinerario.isNotEmpty || _paradaActualData != null;
    if (hayViajeEnCurso && _diasRestantes > 0) {
      final confirmado = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.superficie,
          title: const Text('¿Empezar un viaje nuevo?', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Vas a perder las paradas que armaste de este viaje, porque todavía no está terminado ni guardado.',
            style: TextStyle(color: AppColors.textoSecundario),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Seguir con este viaje')),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Empezar de nuevo', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      );
      if (confirmado != true || !mounted) return;
    }
    BorradorStorage.borrar();
    setState(() {
      _itinerario.clear();
      _paradaActualData = null;
      _error = null;
      _pasoActual = 1;
    });
  }

  void _irAlPaso2() {
    final error = _validarDatosViaje();
    setState(() {
      _error = error;
      if (error == null) _pasoActual = 2;
    });
  }

  void _iniciarGeneracion() async {
    // Por si los datos cambiaron después del paso 1: el error se ve en el paso 1.
    final errorDatos = _validarDatosViaje();
    if (errorDatos != null) {
      setState(() {
        _error = errorDatos;
        _pasoActual = 1;
      });
      return;
    }
    // Los botones de los pasos 2 y 3 no dejan avanzar sin elegir; por las dudas.
    if (_estiloSeleccionado == null || _companiaSeleccionada == null) {
      setState(() => _pasoActual = _estiloSeleccionado == null ? 2 : 3);
      return;
    }
    final origen = _origenController.text.trim();
    final destino = _destinoController.text.trim();
    final dias = int.parse(_diasTotalesController.text.trim());

    // Un viaje nuevo reemplaza al borrador anterior.
    BorradorStorage.borrar();
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
        estilo: _estilo,
        mes: _mesDeFechaSalida,
        compania: _companiaSeleccionada!,
      );
      final diasRecomendados = data['dias_recomendados'] as int? ?? 1;

      if (mounted) {
        setState(() {
          _paradaActualData = data;
          _diasSeleccionados = diasRecomendados.clamp(1, _diasRestantes > 0 ? _diasRestantes : 1);
          _isLoading = false;
          _pasoActual = 5; // Ver itinerario
        });
        _guardarBorrador();
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
            estilo: _estilo,
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
    if (_diasRestantes > 0) {
      _guardarBorrador();
    } else {
      BorradorStorage.borrar();
    }

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
      estilo: _estilo.toUpperCase(),
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
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: Column(
          children: [
            PlannerHeader(
              pasoActual: _pasoActual,
              onVolver: () => setState(() => _pasoActual--),
              onReiniciar: _reiniciar,
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
          onDiasSeleccionadosChanged: (dias) {
            setState(() => _diasSeleccionados = dias);
            _guardarBorrador();
          },
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
          onSiguiente: _irAlPaso2,
        );
    }
  }
}
