# Ficha de Play Store: Travel Planner

Todo lo que pide Play Console para publicar, listo para copiar y pegar. Idioma de la ficha: **Español (Latinoamérica), es-419**.

## Detalles de la app

**Nombre de la app** (máx. 30)

```
Travel Planner: Viajes con IA
```

**Descripción breve** (máx. 80)

```
Armá tu viaje ciudad por ciudad con IA: itinerario, presupuesto, clima y más.
```

**Descripción completa** (máx. 4000)

```
Planificar un viaje de varias ciudades lleva horas: qué ver, cuántos días quedarse en cada lugar, cómo moverse, cuánto cuesta. Travel Planner lo arma con vos, parada por parada, usando inteligencia artificial.

CÓMO FUNCIONA
1. Elegí desde dónde salís, a dónde vas, cuántos días tenés y cuándo viajás.
2. Contanos tu estilo (cultura, gastronomía, playa, aventura, económico o relax) y con quién viajás.
3. La IA arma la primera parada y te recomienda cuántos días quedarte. Ajustá los días a tu gusto, confirmá y elegí la siguiente ciudad entre las sugeridas, o cualquier otra.
4. Repetí hasta completar tu viaje. ¡Listo!

QUÉ INCLUYE CADA PARADA
• Cronograma día por día con actividades de mañana, tarde y noche, sin repetir lugares.
• Atracciones imperdibles, con aviso de cuáles requieren entrada y consejos para reservar.
• Presupuesto diario estimado (alojamiento, comida y actividades) y costo total del viaje.
• Clima esperado para el mes de tu viaje y qué ropa llevar.
• Traslado sugerido desde la ciudad anterior: medio de transporte, duración y consejos.

TUS VIAJES, SIEMPRE A MANO
• Guardá tus itinerarios y consultalos aunque no tengas internet.
• Exportá el viaje completo en PDF o compartilo por WhatsApp, mail o donde quieras.
• Filtrá entre próximos y pasados.

RESERVÁ CUANDO QUIERAS
Desde cada parada podés buscar alojamiento, pasajes de tren o bus y entradas a atracciones en sitios de reserva conocidos.

PRIVACIDAD
No necesitás crear una cuenta. Tus viajes guardados quedan en tu teléfono.

Los itinerarios, precios y horarios son sugerencias generadas por IA: confirmá siempre la información importante antes de viajar.
```

## Categoría y contacto

| Campo | Valor |
|---|---|
| Tipo de app | Aplicación |
| Categoría | Viajes y guías locales |
| Etiquetas sugeridas | Planificador de viajes, Itinerarios, Guías de viaje |
| Email de contacto | **[EMAIL DE CONTACTO]** (es público en la ficha) |
| Sitio web | https://pela3.github.io/travel-planner/ |
| Política de privacidad | https://pela3.github.io/travel-planner/privacidad/ |

## Recursos gráficos (en esta carpeta)

| Recurso | Archivo | Requisito de Play |
|---|---|---|
| Ícono | `icono_512.png` | 512×512 PNG |
| Gráfico destacado | `grafico_destacado.png` | 1024×500 |
| Capturas de teléfono | `capturas/captura_1.png` … `captura_5.png` | 2 a 8, 9:16 (1080×1920) |

Falta una captura de **la pantalla del itinerario** mientras se planifica (la de "Tu Itinerario"). Hoy Gemini devuelve el plan genérico y se vería el aviso de "IA no disponible", así que conviene sacarla cuando actives el plan pago.

## Formularios de "Contenido de la app"

### Acceso a la app
Toda la funcionalidad está disponible sin restricciones (no hay login).

### Anuncios
La app **no contiene anuncios**. Los botones a GetYourGuide, Booking y Omio son enlaces de afiliado que abre el usuario, no publicidad.

### Clasificación del contenido
Categoría: **Utilidad, productividad, comunicación u otra**. Responder "No" a todo (violencia, contenido sexual, lenguaje, sustancias, apuestas, etc.). Interacción entre usuarios: No. Compras digitales: No. Comparte la ubicación: No. Resultado esperado: **Apto para todo público / PEGI 3**.

### Público objetivo
Edad: **18 años o más** (también se puede marcar desde 13). No elegir menores de 13: activaría los requisitos de la Política de Familias. "¿Puede atraer a niños?": No.

### Seguridad de los datos

| Pregunta | Respuesta |
|---|---|
| ¿Recopila o comparte alguno de los tipos de datos requeridos? | **Sí** |
| ¿Los datos se encriptan en tránsito? | **Sí** (HTTPS) |
| ¿El usuario puede pedir que se borren sus datos? | **Sí** (se borran desde la app o desinstalándola) |

Tipos de datos a declarar:

| Tipo de dato | ¿Recopilado? | ¿Compartido? | Opcional | Finalidad |
|---|---|---|---|---|
| **Actividad en apps → Otro contenido generado por el usuario** (destinos, días y preferencias del viaje) | Sí, efímero (no se guarda asociado al usuario) | Sí, con Google (Gemini) para generar el itinerario | No, la función lo requiere | Funcionalidad de la app |
| **Información y rendimiento de la app → Registros de fallas / diagnóstico** (logs del servidor con IP) | Sí | No | No | Funcionalidad de la app, prevención de fraude/abuso |

No se declaran: ubicación, información personal (nombre, email), datos financieros, contactos, fotos, identificadores de dispositivo ni historial de navegación. Los viajes guardados no se declaran porque **no salen del dispositivo**.

> Nota: Google considera que procesar datos en un servidor propio y enviarlos a un proveedor (Gemini) para cumplir la función pedida por el usuario es "transferencia a proveedor de servicios", que no cuenta como compartir. Si al completar el formulario la redacción te lleva a esa opción, podés marcar "Compartido: No" para los datos del viaje. Las dos respuestas son defendibles con la política de privacidad publicada.

## Antes de enviar a revisión

- [ ] Completar `[NOMBRE DEL RESPONSABLE]` y `[EMAIL DE CONTACTO]` en `docs/privacidad/index.html` y en esta ficha.
- [ ] Activar GitHub Pages (Settings → Pages → Deploy from branch → `main` / `/docs`) y verificar que abre la URL de la política.
- [ ] Generar el bundle firmado: ver README → "Build de Android para Play Store".
- [ ] Cuentas nuevas de desarrollador: Google exige una **prueba cerrada con al menos 12 testers durante 14 días** antes de poder publicar en producción.
