package main

import (
	"log"
	"net/http"
	"os"
	"strings"
	"time"
	"travel-planner-api/internal/ai"
	"travel-planner-api/internal/handlers"

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

	// La app móvil no necesita CORS; esto aplica solo a Flutter Web.
	// En producción definí ALLOWED_ORIGINS con los dominios permitidos (separados por coma).
	r.Use(cors.New(cors.Config{
		AllowOrigins:     origenesPermitidos(),
		AllowMethods:     []string{"GET", "POST", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: false,
		MaxAge:           12 * time.Hour,
	}))

	// Para que el hosting (Render, Cloud Run, etc.) pueda chequear que el servicio vive.
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "ok"})
	})

	travelHandler := handlers.NewTravelHandler(aiClient)

	api := r.Group("/api/v1")
	{
		api.POST("/planificar", travelHandler.PlanificarViaje)
		api.POST("/extender-cronograma", travelHandler.ExtenderCronograma)
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Servidor corriendo en http://localhost:%s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("Error al levantar el servidor: %v", err)
	}
}

func origenesPermitidos() []string {
	raw := strings.TrimSpace(os.Getenv("ALLOWED_ORIGINS"))
	if raw == "" {
		return []string{"*"}
	}
	var origenes []string
	for _, o := range strings.Split(raw, ",") {
		if o = strings.TrimSpace(o); o != "" {
			origenes = append(origenes, o)
		}
	}
	return origenes
}
