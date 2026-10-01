# Travel Planner AI

App para planificar viajes de varias ciudades con IA (Gemini). Armás el viaje parada por parada: la IA propone traslado, clima, presupuesto, atracciones y un cronograma diario, y sugiere la siguiente ciudad hasta completar los días.

| Carpeta | Stack |
|---|---|
| `backend/` | Go + Gin, API REST que llama a Gemini |
| `frontend/` | Flutter (Android primero, luego iOS) |

## Backend

```bash
cd backend
cp .env.example .env   # completar GEMINI_API_KEYS
go run ./cmd/api       # http://localhost:8080
go test ./...
```

Endpoints: `POST /api/v1/planificar`, `POST /api/v1/extender-cronograma`, `GET /health`.

Variables de entorno: ver [`backend/.env.example`](backend/.env.example).

## Frontend

```bash
cd frontend
flutter pub get
flutter run                                   # usa la URL local de lib/config.dart
flutter run --dart-define=API_BASE_URL=https://api.ejemplo.com
flutter test
```

### Estructura de `frontend/lib`

```
models/     modelos de datos (JSON <-> Dart)
services/   API, guardado local, enlaces externos, exportación PDF/TXT
screens/    una carpeta por pantalla, con sus widgets/ (y steps/ en el planificador)
utils/      helpers (fechas, imágenes de ciudades)
data/       datos estáticos (destinos populares)
```
