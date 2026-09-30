// Fotos de portada por ciudad. Antes había dos listas distintas (planificador y
// Mis Viajes); ahora es una sola y el ancho se pide según dónde se muestre.
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
  return 'https://images.unsplash.com/$foto?auto=format&fit=crop&w=$ancho&q=80';
}
