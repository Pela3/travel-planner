import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/models/models.dart';
import 'package:frontend/utils/city_images.dart';

ViajeGuardado _viaje({required DateTime inicio, int dias = 5}) => ViajeGuardado(
      id: '1',
      titulo: 'BA ➔ Roma',
      origenInicial: 'Buenos Aires',
      estilo: 'CULTURAL',
      mes: 'Mayo',
      fechaInicio: inicio,
      diasTotales: dias,
      costoTotalEstimado: 0,
      fechaCreacion: inicio,
      paradas: [],
    );

void main() {
  group('ViajeGuardado.esPasado', () {
    final ahora = DateTime(2026, 10, 1, 15, 30);

    test('un viaje que ya terminó es pasado', () {
      expect(_viaje(inicio: DateTime(2026, 9, 1)).esPasado(ahora), isTrue);
    });

    test('un viaje en curso no es pasado', () {
      expect(_viaje(inicio: DateTime(2026, 9, 29)).esPasado(ahora), isFalse);
    });

    test('un viaje futuro no es pasado', () {
      expect(_viaje(inicio: DateTime(2026, 12, 1)).esPasado(ahora), isFalse);
    });
  });

  test('InfoTraslado conserva el costo estimado y tolera que falte', () {
    final conCosto = InfoTraslado.fromJson({'medio_sugerido': 'Tren', 'costo_estimado': 45});
    expect(conCosto.costoEstimado, 45);
    expect(InfoTraslado.fromJson(conCosto.toJson()).costoEstimado, 45);

    // Viajes guardados antes de este cambio no tienen el campo.
    expect(InfoTraslado.fromJson({'medio_sugerido': 'Tren'}).costoEstimado, 0);
  });

  test('obtenerImagenCiudad usa foto específica o genérica', () {
    expect(obtenerImagenCiudad('Roma, Italia'), contains('photo-1552832230'));
    expect(obtenerImagenCiudad('Berlín', ancho: 600), allOf(contains('photo-1560969184'), contains('w=600')));
    expect(obtenerImagenCiudad('Salzburgo'), contains('photo-1488646953014'));
  });
}
