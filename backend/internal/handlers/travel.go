package handlers

import (
	"log"
	"net/http"
	"travel-planner-api/internal/ai"
	"travel-planner-api/internal/models"

	"github.com/gin-gonic/gin"
)

type TravelHandler struct {
	aiClient *ai.AIClient
}

func NewTravelHandler(aiClient *ai.AIClient) *TravelHandler {
	return &TravelHandler{aiClient: aiClient}
}

func (h *TravelHandler) PlanificarViaje(c *gin.Context) {
	var req models.PlanRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Parámetros inválidos: " + err.Error()})
		return
	}

	plan, err := h.aiClient.GenerarPlan(c.Request.Context(), req)
	if err != nil {
		log.Printf("ERROR GenerarPlan: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Error generando plan: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, plan)
}
func (h *TravelHandler) ExtenderCronograma(c *gin.Context) {
	var req models.ExtenderCronogramaRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
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
