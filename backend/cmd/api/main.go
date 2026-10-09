package main

import (
	"context"
	"errors"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"strings"
	"syscall"
	"time"
	"travel-planner-api/internal/ai"
	"travel-planner-api/internal/handlers"
	"travel-planner-api/internal/middleware"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	if err := godotenv.Load(); err != nil {
		log.Println("Aviso: No se encontró archivo .env, usando variables de entorno")
	}

	aiClient, err := ai.NewAIClient()
	if err != nil {
		log.Fatalf("Error configurando cliente IA: %v", err)
	}

	r := gin.Default()
	r.Use(middleware.HeadersSeguridad())

	// La app de Android no usa CORS (eso es de los navegadores). Solo se activa
	// si se define ALLOWED_ORIGINS, por ejemplo para una versión web; si no,
	// ningún sitio web puede llamar a la API desde el navegador de un usuario.
	if origenes := origenesPermitidos(); len(origenes) > 0 {
		r.Use(cors.New(cors.Config{
			AllowOrigins:     origenes,
			AllowMethods:     []string{"GET", "POST", "OPTIONS"},
			AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization"},
			ExposeHeaders:    []string{"Content-Length"},
			AllowCredentials: false,
			MaxAge:           12 * time.Hour,
		}))
	}

	// Para que el hosting (Render, Cloud Run, etc.) pueda chequear que el servicio vive.
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "ok"})
	})

	travelHandler := handlers.NewTravelHandler(aiClient)

	// Cada pedido a la API puede costar una llamada a Gemini: limitamos por IP
	// y en total para que nadie agote la cuota.
	limiter := middleware.NewRateLimiter(
		envInt("RATE_LIMIT_POR_MINUTO", 10),
		envInt("RATE_LIMIT_GLOBAL_POR_MINUTO", 60),
	)

	// Con FIREBASE_PROJECT_ID, solo usuarios con sesión iniciada en la app pueden
	// usar la API, y el límite por minuto se cuenta por usuario.
	middlewares := []gin.HandlerFunc{middleware.LimiteCuerpo(64 << 10)}
	if projectID := strings.TrimSpace(os.Getenv("FIREBASE_PROJECT_ID")); projectID != "" {
		middlewares = append(middlewares, middleware.NewVerificadorFirebase(projectID).Middleware())
	} else if gin.Mode() == gin.ReleaseMode {
		// En producción nunca se arranca sin login: si falta la variable, mejor
		// que el deploy falle a que la API quede abierta y gaste la cuota de Gemini.
		log.Fatal("FIREBASE_PROJECT_ID es obligatorio con GIN_MODE=release")
	} else {
		log.Println("Aviso: FIREBASE_PROJECT_ID vacío, la API no pide login (solo para desarrollo)")
	}
	cuota := middleware.NewCuotaDiaria(
		envInt("CUOTA_DIARIA_POR_USUARIO", 60),
		envInt("CUOTA_DIARIA_GLOBAL", 3000),
	)
	middlewares = append(middlewares, limiter.Middleware(), cuota.Middleware())

	api := r.Group("/api/v1", middlewares...)
	{
		api.POST("/planificar", travelHandler.PlanificarViaje)
		api.POST("/extender-cronograma", travelHandler.ExtenderCronograma)
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	srv := &http.Server{
		Addr:              ":" + port,
		Handler:           r,
		ReadHeaderTimeout: 10 * time.Second,
		// Una llamada a Gemini puede rotar por varias keys (25s c/u).
		WriteTimeout: 120 * time.Second,
		IdleTimeout:  120 * time.Second,
	}

	go func() {
		log.Printf("Servidor corriendo en http://localhost:%s", port)
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			log.Fatalf("Error al levantar el servidor: %v", err)
		}
	}()

	// Render (y casi cualquier hosting) manda SIGTERM al redeployar: terminamos
	// los pedidos en curso antes de salir.
	stop := make(chan os.Signal, 1)
	signal.Notify(stop, syscall.SIGINT, syscall.SIGTERM)
	<-stop

	log.Println("Apagando servidor...")
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	if err := srv.Shutdown(ctx); err != nil {
		log.Printf("Error al apagar el servidor: %v", err)
	}
}

func envInt(nombre string, porDefecto int) int {
	raw := strings.TrimSpace(os.Getenv(nombre))
	if raw == "" {
		return porDefecto
	}
	n, err := strconv.Atoi(raw)
	if err != nil {
		log.Printf("Aviso: %s=%q no es un número, uso %d", nombre, raw, porDefecto)
		return porDefecto
	}
	return n
}

func origenesPermitidos() []string {
	raw := strings.TrimSpace(os.Getenv("ALLOWED_ORIGINS"))
	if raw == "" {
		return nil
	}
	var origenes []string
	for _, o := range strings.Split(raw, ",") {
		if o = strings.TrimSpace(o); o != "" {
			origenes = append(origenes, o)
		}
	}
	return origenes
}
