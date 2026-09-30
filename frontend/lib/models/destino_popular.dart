class DestinoPopular {
  final String ciudad;
  final String pais;
  final String categoria; // cultura, playa, naturaleza, gastronomia, nieve
  final String descripcion;
  final String imagenUrl;
  final int costoEstimado;

  const DestinoPopular({
    required this.ciudad,
    required this.pais,
    required this.categoria,
    required this.descripcion,
    required this.imagenUrl,
    required this.costoEstimado,
  });
}
