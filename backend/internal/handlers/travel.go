package handlers

import (
	"context"
	"log"
	"net/http"
	"travel-planner-api/internal/ai"
	"travel-planner-api/internal/models"

	"github.com/gin-gonic/gin"
)

// Planificador abstrae al cliente de IA para poder testear los handlers sin Gemini.
type Planificador interface {
	GenerarPlan(ctx context.Context, req models.PlanRequest) (*models.PlanResponse, error)
	ExtenderCronograma(ctx context.Context, req models.ExtenderCronogramaRequest) ([]models.ActividadDia, error)
}

var _ Planificador = (*ai.AIClient)(nil)

type TravelHandler struct {
	aiClient Planificador
}

func NewTravelHandler(aiClient Planificador) *TravelHandler {
	return &TravelHandler{aiClient: aiClient}
}

func (h *TravelHandler) PlanificarViaje(c *gin.Context) {
	var req models.PlanRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		// El detalle de Gin nombra structs internos: no se devuelve al cliente.
		c.JSON(http.StatusBadRequest, gin.H{"error": "Parámetros inválidos: el pedido no tiene el formato esperado."})
		return
	}
	if err := req.Validar(); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Parámetros inválidos: " + err.Error()})
		return
	}

	plan, err := h.aiClient.GenerarPlan(c.Request.Context(), req)
	if err != nil {
		log.Printf("ERROR GenerarPlan: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "No se pudo generar el plan. Intentá de nuevo."})
		return
	}

	c.JSON(http.StatusOK, plan)
}

func (h *TravelHandler) ExtenderCronograma(c *gin.Context) {
	var req models.ExtenderCronogramaRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		// El detalle de Gin nombra structs internos: no se devuelve al cliente.
		c.JSON(http.StatusBadRequest, gin.H{"error": "Parámetros inválidos: el pedido no tiene el formato esperado."})
		return
	}
	if err := req.Validar(); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Parámetros inválidos: " + err.Error()})
		return
	}

	dias, err := h.aiClient.ExtenderCronograma(c.Request.Context(), req)
	if err != nil {
		log.Printf("Error extendiendo cronograma: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "No se pudo generar los días adicionales"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"dias_extendidos": dias})
}
