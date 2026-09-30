package main

import (
	"log"
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

	// Responder a las peticiones OPTIONS y permitir peticiones cruzadas
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: false,
		MaxAge:           12 * time.Hour,
	}))

	travelHandler := handlers.NewTravelHandler(aiClient)

	api := r.Group("/api/v1")
	{
		api.POST("/planificar", travelHandler.PlanificarViaje)
		api.POST("/extender-cronograma", travelHandler.ExtenderCronograma)
	}

	log.Println("Servidor corriendo en http://localhost:8080")
	if err := r.Run(":8080"); err != nil {
		log.Fatalf("Error al levantar el servidor: %v", err)
	}
}
