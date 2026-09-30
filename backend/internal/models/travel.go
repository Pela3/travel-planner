package models

type PlanRequest struct {
	CiudadOrigen  string `json:"ciudad_origen"` // Ciudad de donde parte hacia el destino
	Destino       string `json:"destino" binding:"required"`
	DiasTotales   int    `json:"dias_totales" binding:"required"`
	DiasRestantes int    `json:"dias_restantes" binding:"required"`
	EstiloViaje   string `json:"estilo_viaje"` // "economico", "cultural", "relax"
	MesViaje      string `json:"mes_viaje"`    // ej: "Octubre"
}

type InfoTraslado struct {
	MedioSugerido    string `json:"medio_sugerido"`    // "Avión", "Tren de alta velocidad", "Bus", etc.
	DuracionEstimada string `json:"duracion_estimada"` // ej: "1h 45m" o "12h vuelo"
	ConsejoLogistica string `json:"consejo_logistica"` // ej: "Ir con 2h de anticipación a la estación"
}

type ProximaParada struct {
	Ciudad          string `json:"ciudad"`
	TiempoTraslado  string `json:"tiempo_traslado"`
	DiasSugeridos   int    `json:"dias_sugeridos"`
	PorQueVisitarlo string `json:"por_que_visitarlo"`
}

type ActividadDia struct {
	Dia           int    `json:"dia"`
	HorarioManana string `json:"horario_manana"`
	Manana        string `json:"manana"`
	HorarioTarde  string `json:"horario_tarde"`
	Tarde         string `json:"tarde"`
	HorarioNoche  string `json:"horario_noche"`
	Noche         string `json:"noche"`
}
type AtraccionDetallada struct {
	Nombre         string `json:"nombre"`
	RequiereTicket bool   `json:"requiere_ticket"`
	ConsejoReserva string `json:"consejo_reserva"`
}

type InfoClima struct {
	ClimaEsperado   string   `json:"clima_esperado"`
	TemperaturaProm string   `json:"temperatura_prom"`
	RopaRecomendada []string `json:"ropa_recomendada"`
}

type PresupuestoEstimado struct {
	Moneda         string `json:"moneda"`
	AlojamientoDia int    `json:"alojamiento_dia"`
	ComidaDia      int    `json:"comida_dia"`
	ActividadesDia int    `json:"actividades_dia"`
	TotalDiario    int    `json:"total_diario"`
}

type PlanResponse struct {
	CiudadActual     string               `json:"ciudad_actual"`
	DiasRecomendados int                  `json:"dias_recomendados"`
	Resumen          string               `json:"resumen"`
	Traslado         *InfoTraslado        `json:"traslado"`
	Presupuesto      PresupuestoEstimado  `json:"presupuesto"`
	Clima            InfoClima            `json:"clima"`
	Atracciones      []AtraccionDetallada `json:"atracciones"`
	CronogramaDias   []ActividadDia       `json:"cronograma_dias"`
	ProximasParadas  []ProximaParada      `json:"proximas_paradas"`
}

type ExtenderCronogramaRequest struct {
	Ciudad          string   `json:"ciudad" binding:"required"`
	Estilo          string   `json:"estilo"`
	DiaInicio       int      `json:"dia_inicio" binding:"required"`
	DiasAdicionales int      `json:"dias_adicionales" binding:"required"`
	LugaresYaVistos []string `json:"lugares_ya_vistos"`
}

type ExtenderCronogramaResponse struct {
	DiasExtendidos []ActividadDia `json:"dias_extendidos"`
}
