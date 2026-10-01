# 🌍 Travel Planner

Una aplicación integral para planificar viajes de forma inteligente, estimar presupuestos, organizar itinerarios por día y consultar traslados, clima y atracciones recomendadas.

---

## 🛠️ Stack Tecnológico

- **Frontend:** [Flutter](https://flutter.dev/) (Dart) con soporte para Android, iOS, Web y Desktop.
- **Backend:** [Go](https://go.dev/) (API REST modular con integración a servicios de IA).
- **Almacenamiento & Exportación:** Soporte para guardado local (`viajes_storage`) y exportación a PDF.
- **Hosting del backend:** [Render](https://render.com/) (Docker), definido en [`render.yaml`](render.yaml).

---

## 📂 Estructura del Proyecto

```text
travel-planner/
├── render.yaml               # Blueprint de Render para el backend
├── backend/                  # Servidor API en Go
│   ├── cmd/api/main.go       # Punto de entrada de la aplicación
│   ├── internal/
│   │   ├── ai/               # Clientes e integración con modelos de IA
│   │   ├── handlers/         # Controladores HTTP (viajes, rutas)
│   │   ├── middleware/       # Límite de pedidos (rate limit)
│   │   └── models/           # Estructuras de datos y validación
│   ├── Dockerfile            # Imagen de producción
│   ├── .env.example          # Variables de entorno documentadas
│   └── go.mod / go.sum       # Dependencias de Go
│
└── frontend/                 # Aplicación cliente en Flutter
    ├── lib/
    │   ├── main.dart         # Inicialización de la app Flutter
    │   ├── config.dart       # URL del backend (configurable al compilar)
    │   ├── models/           # Modelos de datos (clima, traslados, presupuesto)
    │   ├── screens/          # Pantallas principales (Home, Mis Viajes, Planner)
    │   │   ├── home/
    │   │   ├── mis_viajes/
    │   │   └── planner/      # Pasos guiados para armar el viaje
    │   ├── services/         # Clientes de API, storage local y exportación PDF
    │   └── utils/            # Funciones auxiliares y manejo de fechas
    ├── pubspec.yaml          # Dependencias de Flutter
    └── [android/ios/web/...] # Carpetas de plataformas soportadas
```

---

## 💻 Desarrollo local

### Backend

```bash
cd backend
cp .env.example .env   # completar GEMINI_API_KEYS
go run ./cmd/api       # http://localhost:8080
go test ./...
```

Endpoints: `POST /api/v1/planificar`, `POST /api/v1/extender-cronograma`, `GET /health`.

### Frontend

```bash
cd frontend
flutter pub get
flutter run                                              # backend local (ver lib/config.dart)
flutter run --dart-define=API_BASE_URL=https://...       # otro backend
flutter test
```

---

## 🚀 Deploy del backend en Render

1. En Render: **New → Blueprint** y elegí este repositorio. Render lee [`render.yaml`](render.yaml).
2. Cuando lo pida, cargá `GEMINI_API_KEYS` (una o varias keys separadas por coma). Nunca la subas al repo.
3. Al terminar, probá `https://<tu-servicio>.onrender.com/health` → `{"status":"ok"}`.

Cada push a `main` vuelve a desplegar automáticamente.

> El plan gratuito de Render apaga el servicio tras ~15 min sin uso; el primer pedido después tarda ~1 minuto en responder. Para producción conviene el plan pago más chico. La caché (`cache.json`) se borra en cada deploy/reinicio.

---

## 📦 Build de Android para Play Store

1. Crear la clave de firma (una sola vez, **guardarla fuera del repo y con backup**: si se pierde no se puede actualizar la app):

   ```bash
   keytool -genkey -v -keystore ~/travel-planner-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Crear `frontend/android/key.properties` (está en `.gitignore`):

   ```properties
   storePassword=...
   keyPassword=...
   keyAlias=upload
   storeFile=C:/Users/<vos>/travel-planner-upload.jks
   ```

3. Generar el bundle apuntando al backend de producción:

   ```bash
   cd frontend
   flutter build appbundle --release --dart-define=API_BASE_URL=https://<tu-servicio>.onrender.com
   ```

   El archivo queda en `build/app/outputs/bundle/release/app-release.aab` y es el que se sube a Play Console.
