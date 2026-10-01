import '../models/actividad_dia.dart';

/// Cuántos días se le piden a la IA por llamada. Más que esto y la respuesta
/// puede cortarse por límite de tokens (y el backend rechaza más de 30).
const int diasPorTanda = 10;

/// Firma de la llamada a /extender-cronograma (inyectable para tests).
typedef PedirDiasExtra = Future<List<ActividadDia>> Function({
  required int diaInicio,
  required int diasAdicionales,
  required List<String> lugaresYaVistos,
});

class ResultadoCronograma {
  final List<ActividadDia> dias;

  /// false si alguna tanda falló y faltan días por generar.
  final bool completo;

  const ResultadoCronograma(this.dias, {required this.completo});
}

/// Numera los días 1..N según su posición. La IA a veces repite o salta
/// números ("dia": 1 en los días extra), y eso se veía como días duplicados.
List<ActividadDia> renumerarDias(List<ActividadDia> dias) {
  return [
    for (var i = 0; i < dias.length; i++) dias[i].copyWith(dia: i + 1),
  ];
}

/// Ajusta el cronograma de la IA a [diasObjetivo] días: recorta si sobran y,
/// si faltan, pide los días extra en tandas de [diasPorTanda] sin repetir
/// lugares. Si una tanda falla devuelve lo que se pudo generar.
Future<ResultadoCronograma> completarCronograma({
  required List<ActividadDia> base,
  required int diasObjetivo,
  required PedirDiasExtra pedirDiasExtra,
}) async {
  final dias = base.take(diasObjetivo).toList();

  while (dias.length < diasObjetivo) {
    final faltan = diasObjetivo - dias.length;
    final tanda = faltan < diasPorTanda ? faltan : diasPorTanda;

    final List<ActividadDia> nuevos;
    try {
      nuevos = await pedirDiasExtra(
        diaInicio: dias.length + 1,
        diasAdicionales: tanda,
        lugaresYaVistos: [for (final d in dias) ...[d.manana, d.tarde, d.noche]],
      );
    } catch (_) {
      return ResultadoCronograma(renumerarDias(dias), completo: false);
    }

    // Una respuesta vacía cortaría el bucle para siempre.
    if (nuevos.isEmpty) {
      return ResultadoCronograma(renumerarDias(dias), completo: false);
    }
    // Si la IA manda de más, nos quedamos con lo pedido.
    dias.addAll(nuevos.take(tanda));
  }

  return ResultadoCronograma(renumerarDias(dias), completo: true);
}
