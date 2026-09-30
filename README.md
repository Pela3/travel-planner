# 🌍 Travel Planner

Una aplicación integral para planificar viajes de forma inteligente, estimar presupuestos, organizar itinerarios por día y consultar traslados, clima y atracciones recomendadas.

---

## 🛠️ Stack Tecnológico

- **Frontend:** [Flutter](https://flutter.dev/) (Dart) con soporte para Android, iOS, Web y Desktop.
- **Backend:** [Go](https://go.dev/) (API REST modular con integración a servicios de IA).
- **Almacenamiento & Exportación:** Soporte para guardado local (`viajes_storage`) y exportación a PDF.

---

## 📂 Estructura del Proyecto

```text
travel-planner/
├── backend/                  # Servidor API en Go
│   ├── cmd/api/main.go       # Punto de entrada de la aplicación
│   ├── internal/
│   │   ├── ai/               # Clientes e integración con modelos de IA
│   │   ├── handlers/         # Controladores HTTP (viajes, rutas)
│   │   └── models/           # Definición de estructuras de datos (travel)
│   ├── cache.json            # Caché local de respuestas/destinos
│   ├── go.mod / go.sum       # Dependencias de Go
│   └── .gitignore
│
└── frontend/                 # Aplicación cliente en Flutter
    ├── lib/
    │   ├── main.dart         # Inicialización de la app Flutter
    │   ├── config.dart       # Variables de configuración y endpoints
    │   ├── models/           # Modelos de datos (clima, traslados, presupuesto)
    │   ├── screens/          # Pantallas principales (Home, Mis Viajes, Planner)
    │   │   ├── home/
    │   │   ├── mis_viajes/
    │   │   └── planner/      # Pasos guiados para armar el viaje
    │   ├── services/         # Clientes de API, storage local y exportación PDF
    │   └── utils/            # Funciones auxiliares y manejo de fechas
    ├── pubspec.yaml          # Dependencias de Flutter
    └── [android/ios/web/...] # Carpetas de plataformas soportadas
