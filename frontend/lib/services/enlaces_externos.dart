import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Enlaces de afiliados / reservas externas.
class EnlacesExternos {
  static Future<void> abrirCompraEntrada(String atraccion, String ciudad) async {
    // Parámetros oficiales de tu cuenta de GetYourGuide
    const String partnerId = 'AMVPBRW';
    const String campana = 'share_to_earn';

    // Codificamos la búsqueda del monumento y la ciudad
    final query = Uri.encodeComponent('$atraccion $ciudad');

    // Ruta /s/?q= con los parámetros de búsqueda y comisión
    final uri = Uri.parse(
      'https://www.getyourguide.es/s/?q=$query&partner_id=$partnerId&cmp=$campana',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // Enlace dinámico de Booking.com para buscar alojamiento en la ciudad
  static Future<void> abrirBooking(String ciudad) async {
    final query = Uri.encodeComponent(ciudad);
    // Podés sumar tu aid=TU_AFILIADO_BOOKING cuando tengas la cuenta aprobada
    final uri = Uri.parse(
      'https://www.booking.com/searchresults.es.html?ss=$query',
    );

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (e) {
      debugPrint('Error al abrir Booking: $e');
    }
  }

  // Enlace dinámico de Omio para comprar pasajes entre paradas
  static Future<void> abrirOmio(String origen, String destino) async {
    final orig = Uri.encodeComponent(origen);
    final dest = Uri.encodeComponent(destino);
    // Omio permite búsqueda directa con origen y destino
    final uri = Uri.parse(
      'https://www.omio.es/search-frontend/results?departureCity=$orig&arrivalCity=$dest',
    );

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (e) {
      debugPrint('Error al abrir Omio: $e');
    }
  }
}
