package ai

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"strings"
	"sync"
	"time"
	"travel-planner-api/internal/models"

	"google.golang.org/genai"
)

const cacheFilePath = "cache.json"

type AIClient struct {
	clients   []*genai.Client
	current   int
	muPool    sync.Mutex
	cacheMu   sync.RWMutex
	diskCache map[string]models.PlanResponse
}

func NewAIClient() (*AIClient, error) {
	rawKeys := os.Getenv("GEMINI_API_KEYS")
	if rawKeys == "" {
		rawKeys = os.Getenv("GEMINI_API_KEY")
	}

	if rawKeys == "" {
		return nil, fmt.Errorf("no se encontraron API keys en GEMINI_API_KEYS o GEMINI_API_KEY")
	}

	keySlice := strings.Split(rawKeys, ",")
	var clients []*genai.Client

	ctx := context.Background()
	for _, key := range keySlice {
		trimmedKey := strings.TrimSpace(key)
		if trimmedKey == "" {
			continue
		}

		c, err := genai.NewClient(ctx, &genai.ClientConfig{
			APIKey:  trimmedKey,
			Backend: genai.BackendGeminiAPI,
		})
		if err != nil {
			log.Printf("Advertencia: Falló inicialización con key: %v", err)
			continue
		}
		clients = append(clients, c)
	}

	if len(clients) == 0 {
		return nil, fmt.Errorf("no se pudo inicializar ningún cliente válido de Gemini")
	}

	log.Printf("Pool de Gemini inicializado con %d cliente(s).", len(clients))

	clientInstance := &AIClient{
		clients:   clients,
		diskCache: make(map[string]models.PlanResponse),
	}

	clientInstance.cargarCacheDisco()

	return clientInstance, nil
}

func (a *AIClient) cargarCacheDisco() {
	a.cacheMu.Lock()
	defer a.cacheMu.Unlock()

	data, err := os.ReadFile(cacheFilePath)
	if err != nil {
		if os.IsNotExist(err) {
			log.Println("Archivo cache.json no encontrado; se inicializará uno nuevo al consultar.")
			return
		}
		log.Printf("Advertencia al leer cache.json: %v", err)
		return
	}

	if err := json.Unmarshal(data, &a.diskCache); err != nil {
		log.Printf("Advertencia al parsear cache.json: %v", err)
		return
	}

	log.Printf("Caché en disco cargado: %d destinos listos.", len(a.diskCache))
}

func (a *AIClient) guardarEnCache(key string, plan models.PlanResponse) {
	a.cacheMu.Lock()
	defer a.cacheMu.Unlock()

	a.diskCache[key] = plan

	bytes, err := json.MarshalIndent(a.diskCache, "", "  ")
	if err != nil {
		log.Printf("Error al serializar caché en disco: %v", err)
		return
	}

	if err := os.WriteFile(cacheFilePath, bytes, 0644); err != nil {
		log.Printf("Error al escribir cache.json: %v", err)
	}
}

func (a *AIClient) consultarCache(key string) (*models.PlanResponse, bool) {
	a.cacheMu.RLock()
	defer a.cacheMu.RUnlock()

	plan, exists := a.diskCache[key]
	if exists {
		return &plan, true
	}
	return nil, false
}

func (a *AIClient) getNextClient() *genai.Client {
	a.muPool.Lock()
	defer a.muPool.Unlock()

	client := a.clients[a.current]
	a.current = (a.current + 1) % len(a.clients)
	return client
}

func (a *AIClient) GenerarPlan(ctx context.Context, req models.PlanRequest) (*models.PlanResponse, error) {
	estilo := strings.ToLower(strings.TrimSpace(req.EstiloViaje))
	if estilo == "" {
		estilo = "cultural"
	}
	mes := strings.TrimSpace(req.MesViaje)
	if mes == "" {
		mes = "Mayo"
	}
	origen := strings.TrimSpace(req.CiudadOrigen)
	if origen == "" {
		origen = "Origen"
	}

	cacheKey := fmt.Sprintf("v8-%s-%s-%s-%s-%d", strings.ToLower(origen), strings.ToLower(strings.TrimSpace(req.Destino)), estilo, strings.ToLower(mes), req.DiasRestantes)

	if cachedPlan, hit := a.consultarCache(cacheKey); hit {
		log.Printf("[Caché Disco HIT] Origen: %s ➔ Destino: %s (0ms latencia)", origen, req.Destino)
		return cachedPlan, nil
	}

	prompt := fmt.Sprintf(`Planifica una parada turística en JSON:
- Origen previo del traslado: %s
- Destino de llegada: %s
- Mes del viaje: %s
- Días totales viaje: %d
- Días restantes: %d
- Estilo: %s (ESTRICTO: si es gastronómico prioriza mercados y restaurantes icónicos; si es cultural museos e historia; si es aventura actividades al aire libre; si es relax ritmos lentos).
- En "traslado": analiza el viaje desde "%s" hacia "%s". Define "medio_sugerido" (ej: "Vuelo internacional", "Tren Frecciarossa / Alta Velocidad", "Bus interurbano"), "duracion_estimada" realista (ej: "12h vuelo" o "1h 40m tren") y "consejo_logistica" útil.
- REGLA DE DÍAS Y PRECARGA EN cronograma_dias:
  1. Define en "dias_recomendados" los días ideales base para conocer este destino (ej: 2 o 3 días).
  2. Genera en "cronograma_dias" exactamente (dias_recomendados + 2) días completos y progresivos (ej: si recomiendas 2, genera 4; si recomiendas 3, genera 5).
  3. Cada día debe tener su número correlativo ("dia": 1, "dia": 2, etc.) con "horario_manana", "horario_tarde" y "horario_noche". Cada descripción de actividad ("manana", "tarde", "noche") DEBE ser concisa y precisa (máximo 15 a 20 palabras por bloque).
  4. NO REPETIR: Cada día debe visitar atracciones, barrios o zonas completamente distintas. Los días adicionales (días 4 y 5) deben cubrir excursiones cercanas, museos secundarios o zonas gastronómicas alternativas.
- En "presupuesto": costos diarios estimados realistas en USD para %s (alojamiento_dia, comida_dia, actividades_dia, total_diario). Moneda: "USD".
- En "clima": clima_esperado, temperatura_prom y 3 prendas en ropa_recomendada para %s en %s.
- En "atracciones": 3 o 4 imperdibles con nombre, requiere_ticket y consejo_reserva.`,
		origen, req.Destino, mes, req.DiasTotales, req.DiasRestantes, estilo,
		origen, req.Destino, estilo, req.Destino, mes)
	config := &genai.GenerateContentConfig{
		ResponseMIMEType: "application/json",
		Temperature:      genai.Ptr(float32(0.1)),
		MaxOutputTokens:  int32(8192),
		ThinkingConfig: &genai.ThinkingConfig{
			ThinkingBudget: genai.Ptr(int32(0)),
		},
		ResponseSchema: &genai.Schema{
			Type: genai.TypeObject,
			Properties: map[string]*genai.Schema{
				"ciudad_actual":     {Type: genai.TypeString},
				"dias_recomendados": {Type: genai.TypeInteger},
				"resumen":           {Type: genai.TypeString},
				"traslado": {
					Type: genai.TypeObject,
					Properties: map[string]*genai.Schema{
						"medio_sugerido":    {Type: genai.TypeString},
						"duracion_estimada": {Type: genai.TypeString},
						"consejo_logistica": {Type: genai.TypeString},
					},
					Required: []string{"medio_sugerido", "duracion_estimada", "consejo_logistica"},
				},
				"presupuesto": {
					Type: genai.TypeObject,
					Properties: map[string]*genai.Schema{
						"moneda":          {Type: genai.TypeString},
						"alojamiento_dia": {Type: genai.TypeInteger},
						"comida_dia":      {Type: genai.TypeInteger},
						"actividades_dia": {Type: genai.TypeInteger},
						"total_diario":    {Type: genai.TypeInteger},
					},
					Required: []string{"moneda", "alojamiento_dia", "comida_dia", "actividades_dia", "total_diario"},
				},
				"clima": {
					Type: genai.TypeObject,
					Properties: map[string]*genai.Schema{
						"clima_esperado":   {Type: genai.TypeString},
						"temperatura_prom": {Type: genai.TypeString},
						"ropa_recomendada": {
							Type:  genai.TypeArray,
							Items: &genai.Schema{Type: genai.TypeString},
						},
					},
					Required: []string{"clima_esperado", "temperatura_prom", "ropa_recomendada"},
				},
				"atracciones": {
					Type: genai.TypeArray,
					Items: &genai.Schema{
						Type: genai.TypeObject,
						Properties: map[string]*genai.Schema{
							"nombre":          {Type: genai.TypeString},
							"requiere_ticket": {Type: genai.TypeBoolean},
							"consejo_reserva": {Type: genai.TypeString},
						},
						Required: []string{"nombre", "requiere_ticket", "consejo_reserva"},
					},
				},
				"cronograma_dias": {
					Type: genai.TypeArray,
					Items: &genai.Schema{
						Type: genai.TypeObject,
						Properties: map[string]*genai.Schema{
							"dia":            {Type: genai.TypeInteger},
							"horario_manana": {Type: genai.TypeString},
							"manana":         {Type: genai.TypeString},
							"horario_tarde":  {Type: genai.TypeString},
							"tarde":          {Type: genai.TypeString},
							"horario_noche":  {Type: genai.TypeString},
							"noche":          {Type: genai.TypeString},
						},
						Required: []string{"dia", "horario_manana", "manana", "horario_tarde", "tarde", "horario_noche", "noche"},
					},
				},
				"proximas_paradas": {
					Type: genai.TypeArray,
					Items: &genai.Schema{
						Type: genai.TypeObject,
						Properties: map[string]*genai.Schema{
							"ciudad":            {Type: genai.TypeString},
							"tiempo_traslado":   {Type: genai.TypeString},
							"dias_sugeridos":    {Type: genai.TypeInteger},
							"por_que_visitarlo": {Type: genai.TypeString},
						},
						Required: []string{"ciudad", "tiempo_traslado", "dias_sugeridos", "por_que_visitarlo"},
					},
				},
			},
			Required: []string{"ciudad_actual", "dias_recomendados", "resumen", "traslado", "presupuesto", "clima", "atracciones", "cronograma_dias", "proximas_paradas"},
		},
	}

	totalClientes := len(a.clients)
	var result *genai.GenerateContentResponse
	var lastErr error

	for i := 0; i < totalClientes; i++ {
		client := a.getNextClient()

		attemptCtx, cancel := context.WithTimeout(ctx, 25*time.Second)
		result, lastErr = client.Models.GenerateContent(attemptCtx, "gemini-3.6-flash", genai.Text(prompt), config)
		cancel()

		if lastErr == nil {
			break
		}

		log.Printf("Aviso: Key devolvió error (%v). Conmutando a la siguiente...", lastErr)
		time.Sleep(500 * time.Millisecond)
	}

	if lastErr != nil {
		log.Printf("Aviso: Fallback activado (%v).", lastErr)

		diasRec := 3
		if req.DiasRestantes < 3 {
			diasRec = req.DiasRestantes
		}

		fallbackPlan := models.PlanResponse{
			CiudadActual:     req.Destino,
			DiasRecomendados: diasRec,
			Resumen:          fmt.Sprintf("Llegada y exploración de %s.", req.Destino),
			Traslado: &models.InfoTraslado{
				MedioSugerido:    "Tren / Transporte público regional",
				DuracionEstimada: "2h 30m aprox.",
				ConsejoLogistica: fmt.Sprintf("Conexión directa desde %s.", origen),
			},
			Presupuesto: models.PresupuestoEstimado{
				Moneda:         "USD",
				AlojamientoDia: 65,
				ComidaDia:      35,
				ActividadesDia: 20,
				TotalDiario:    120,
			},
			Clima: models.InfoClima{
				ClimaEsperado:   "Templado",
				TemperaturaProm: "18°C",
				RopaRecomendada: []string{"Ropa cómoda", "Zapatillas", "Abrigo liviano"},
			},
			Atracciones: []models.AtraccionDetallada{
				{
					Nombre:         fmt.Sprintf("Centro Histórico de %s", req.Destino),
					RequiereTicket: false,
					ConsejoReserva: "Acceso libre para recorrer a pie.",
				},
			},
			CronogramaDias: []models.ActividadDia{
				{
					Dia:           1,
					HorarioManana: "09:30 - 12:30",
					Manana:        fmt.Sprintf("Traslado desde %s y check-in en alojamiento", origen),
					HorarioTarde:  "14:30 - 18:00",
					Tarde:         "Primer recorrido a pie por el centro",
					HorarioNoche:  "20:30 - 22:30",
					Noche:         "Cena de bienvenida en gastronomía local",
				},
			},
			ProximasParadas: []models.ProximaParada{
				{
					Ciudad:          fmt.Sprintf("Ciudad vecina a %s", req.Destino),
					TiempoTraslado:  "1h 30m",
					DiasSugeridos:   2,
					PorQueVisitarlo: "Pueblo pintoresco en la cercanía.",
				},
			},
		}

		a.guardarEnCache(cacheKey, fallbackPlan)
		return &fallbackPlan, nil
	}

	rawJSON := result.Text()
	var plan models.PlanResponse
	if err := json.Unmarshal([]byte(rawJSON), &plan); err != nil {
		return nil, fmt.Errorf("error al deserializar JSON: %w", err)
	}

	a.guardarEnCache(cacheKey, plan)
	return &plan, nil
}
func (a *AIClient) ExtenderCronograma(ctx context.Context, req models.ExtenderCronogramaRequest) ([]models.ActividadDia, error) {
	prompt := fmt.Sprintf(`Eres un guía de viajes experto. El usuario ya está visitando %s con estilo de viaje '%s'.
Ya tiene actividades y lugares planificados para sus primeros días: %v.

Tu tarea: Genera un plan detallado ÚNICAMENTE para %d días adicionales, comenzando en el día %d hasta el día %d.
REGLAS ESTRICTAS:
1. No repitas NINGUNO de los lugares o actividades ya visitados.
2. Enfócate en atracciones alternativas, excursiones cercanas de un día, barrios auténticos, parques o nuevas experiencias gastronómicas.
3. Responde estrictamente con un JSON que cumpla esta estructura:
{
  "dias_extendidos": [
    {
      "dia": %d,
      "horario_manana": "09:30 - 13:00",
      "manana": "Descripción concisa (máx 20 palabras)",
      "horario_tarde": "14:30 - 18:30",
      "tarde": "Descripción concisa (máx 20 palabras)",
      "horario_noche": "20:30 - 23:00",
      "noche": "Descripción concisa (máx 20 palabras)"
    }
  ]
}`,
		req.Ciudad,
		req.Estilo,
		req.LugaresYaVistos,
		req.DiasAdicionales,
		req.DiaInicio,
		req.DiaInicio+req.DiasAdicionales-1,
		req.DiaInicio,
	)

	config := &genai.GenerateContentConfig{
		ResponseMIMEType: "application/json",
		Temperature:      genai.Ptr(float32(0.2)),
		MaxOutputTokens:  int32(4000),
	}

	totalClientes := len(a.clients) // o como tengas guardado el slice/longitud de clientes
	var result *genai.GenerateContentResponse
	var lastErr error

	for i := 0; i < totalClientes; i++ {
		client := a.getNextClient()

		attemptCtx, cancel := context.WithTimeout(ctx, 25*time.Second)
		result, lastErr = client.Models.GenerateContent(attemptCtx, "gemini-3.6-flash", genai.Text(prompt), config)
		cancel()

		if lastErr == nil {
			break
		}

		log.Printf("Aviso: Key devolvió error al extender (%v). Conmutando...", lastErr)
		time.Sleep(500 * time.Millisecond)
	}

	if lastErr != nil || result == nil {
		return nil, fmt.Errorf("error llamando a Gemini al extender tras rotar keys: %w", lastErr)
	}

	var resp models.ExtenderCronogramaResponse
	if err := json.Unmarshal([]byte(result.Text()), &resp); err != nil {
		return nil, fmt.Errorf("error parseando JSON extendido: %w", err)
	}

	return resp.DiasExtendidos, nil
}
