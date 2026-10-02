import 'package:flutter/material.dart';

import '../models/destino_popular.dart';

/// Categorías del inicio: etiqueta e ícono del filtro, y estilo del
/// planificador que se preselecciona al planificar un destino de esa categoría.
const categoriasDestino = <String, ({String etiqueta, IconData icono, String estilo})>{
  'cultura': (etiqueta: 'Cultura', icono: Icons.account_balance_outlined, estilo: 'cultural'),
  'playa': (etiqueta: 'Playa', icono: Icons.beach_access_outlined, estilo: 'playa'),
  'naturaleza': (etiqueta: 'Naturaleza', icono: Icons.forest_outlined, estilo: 'aventura'),
  'gastronomia': (etiqueta: 'Gastronomía', icono: Icons.restaurant_outlined, estilo: 'gastronomico'),
  'nieve': (etiqueta: 'Nieve', icono: Icons.ac_unit, estilo: 'aventura'),
};

const List<DestinoPopular> destinosPopulares = [
  DestinoPopular(
    ciudad: 'Roma',
    pais: 'Italia',
    categoria: 'cultura',
    descripcion: 'Historia milenaria, el Coliseo y gastronomía toscana inolvidable.',
    imagenUrl: 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?auto=format&fit=crop&w=700&q=80',
    costoEstimado: 1200,
  ),
  DestinoPopular(
    ciudad: 'Kioto',
    pais: 'Japón',
    categoria: 'cultura',
    descripcion: 'Templos de madera centenarios, santuarios sintoístas y jardines zen.',
    imagenUrl: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=700&q=80',
    costoEstimado: 1800,
  ),
  DestinoPopular(
    ciudad: 'Cancún',
    pais: 'México',
    categoria: 'playa',
    descripcion: 'Playas de arena blanca, aguas turquesas del Caribe y cenotes mayas.',
    imagenUrl: 'https://images.unsplash.com/photo-1510097467424-192d713fd8b2?auto=format&fit=crop&w=700&q=80',
    costoEstimado: 1100,
  ),
  DestinoPopular(
    ciudad: 'Río de Janeiro',
    pais: 'Brasil',
    categoria: 'playa',
    descripcion: 'Copacabana, el Cristo Redentor y atardeceres mágicos al ritmo de samba.',
    imagenUrl: 'https://images.unsplash.com/photo-1483729558449-99ef09a8c325?auto=format&fit=crop&w=700&q=80',
    costoEstimado: 950,
  ),
  DestinoPopular(
    ciudad: 'Buenos Aires',
    pais: 'Argentina',
    categoria: 'cultura',
    descripcion: 'Tango, arquitectura europea clásica, teatros y la mejor gastronomía en Palermo y San Telmo.',
    imagenUrl: 'https://images.unsplash.com/photo-1589909202802-8f4aadce1849?auto=format&fit=crop&w=700&q=80',
    costoEstimado: 750,
  ),
  DestinoPopular(
    ciudad: 'París',
    pais: 'Francia',
    categoria: 'gastronomia',
    descripcion: 'La meca de la pastelería, museos icónicos y paseos nocturnos por el Sena.',
    imagenUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=700&q=80',
    costoEstimado: 1600,
  ),
  DestinoPopular(
    ciudad: 'Zermatt',
    pais: 'Suiza',
    categoria: 'nieve',
    descripcion: 'El monte Cervino, aldeas alpinas de cuento y los mejores centros de esquí.',
    imagenUrl: 'https://images.unsplash.com/photo-1530122037265-a5f1f91d3b99?auto=format&fit=crop&w=700&q=80',
    costoEstimado: 2300,
  ),
  DestinoPopular(
    ciudad: 'Barcelona',
    pais: 'España',
    categoria: 'cultura',
    descripcion: 'La arquitectura de Gaudí, playas mediterráneas y tapas en el Barrio Gótico.',
    imagenUrl: 'https://images.unsplash.com/photo-1583422409516-2895a77efded?auto=format&fit=crop&w=700&q=80',
    costoEstimado: 1350,
  ),
];
