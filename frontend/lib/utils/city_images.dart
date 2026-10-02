import 'package:flutter/widgets.dart';

// Fotos de portada por ciudad. Antes había dos listas distintas (planificador y
// Mis Viajes); ahora es una sola y el ancho se pide según dónde se muestre.
// Un valor que empieza con "assets/" es una foto incluida en la app.
const _fotosPorCiudad = <List<String>, String>{
  ['roma']: 'photo-1552832230-c0197dd311b5',
  ['florencia', 'firenze']: 'photo-1543429776-2782fc8e1acd',
  ['paris', 'parís']: 'photo-1502602898657-3e91760cbb34',
  ['madrid']: 'photo-1539037116277-4db20889f2d4',
  ['barcelona']: 'photo-1583422409516-2895a77efded',
  ['londres', 'london']: 'photo-1513635269975-59663e0ac1ad',
  ['tokio', 'tokyo']: 'photo-1503899036084-c55cdd92da26',
  ['nueva york', 'new york']: 'photo-1496442226666-8d4d0e62e6e9',
  ['buenos aires']: 'photo-1589909202802-8f4aadce1849',
  ['miami']: 'photo-1506953823976-52e1fdc0149a',
  ['berlin', 'berlín']: 'photo-1560969184-10fe8719e047',
  // Destinos del inicio: así el itinerario y Mis Viajes muestran la misma foto.
  ['kioto', 'kyoto']: 'photo-1493976040374-85c8e12f0c0e',
  ['cancun', 'cancún']: 'photo-1510097467424-192d713fd8b2',
  ['rio de janeiro', 'río de janeiro']: 'photo-1483729558449-99ef09a8c325',
  ['zermatt']: 'photo-1530122037265-a5f1f91d3b99',
  ['santorini']: 'photo-1570077188670-e3a8d69ac5ff',
  ['maldivas', 'maldives', 'malé']: 'photo-1573843981267-be1999ff37cd',
  ['lima']: 'photo-1531968455001-5c5272a41129',
  ['bangkok']: 'photo-1508009603885-50cf7c579365',
  ['bariloche']: 'assets/destinos/bariloche.jpg',
  ['ushuaia']: 'assets/destinos/ushuaia.jpg',
  ['chamonix']: 'assets/destinos/chamonix.jpg',
  ['torres del paine', 'puerto natales']: 'photo-1478827387698-1527781a4887',
  ['banff']: 'photo-1561134643-668f9057cce4',
  ['reikiavik', 'reykjavik', 'islandia']: 'photo-1476610182048-b716b8518aae',
  ['dolomitas', 'dolomites', 'dolomiti']: 'photo-1501785888041-af3ef285b470',
};

// Fallback general para cualquier otra ciudad del mundo
const _fotoGenerica = 'photo-1488646953014-85cb44e25828';

String obtenerImagenCiudad(String ciudad, {int ancho = 800}) {
  final c = ciudad.toLowerCase();
  var foto = _fotoGenerica;
  for (final entry in _fotosPorCiudad.entries) {
    if (entry.key.any(c.contains)) {
      foto = entry.value;
      break;
    }
  }
  if (foto.startsWith('assets/')) return foto;
  return 'https://images.unsplash.com/$foto?auto=format&fit=crop&w=$ancho&q=80';
}

/// Imagen para una URL de internet o una foto incluida en la app ("assets/...").
ImageProvider proveedorImagen(String rutaOUrl) =>
    rutaOUrl.startsWith('assets/') ? AssetImage(rutaOUrl) : NetworkImage(rutaOUrl);
