package handlers

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"travel-planner-api/internal/models"

	"github.com/gin-gonic/gin"
)

type planificadorFalso struct {
	llamadas int
	err      error
}

func (p *planificadorFalso) GenerarPlan(_ context.Context, req models.PlanRequest) (*models.PlanResponse, error) {
	p.llamadas++
	if p.err != nil {
		return nil, p.err
	}
	return &models.PlanResponse{CiudadActual: req.Destino, DiasRecomendados: 2}, nil
}

func (p *planificadorFalso) ExtenderCronograma(_ context.Context, req models.ExtenderCronogramaRequest) ([]models.ActividadDia, error) {
	p.llamadas++
	if p.err != nil {
		return nil, p.err
	}
	return []models.ActividadDia{{Dia: req.DiaInicio}}, nil
}

func nuevoRouter(p Planificador) *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := NewTravelHandler(p)
	r.POST("/planificar", h.PlanificarViaje)
	r.POST("/extender", h.ExtenderCronograma)
	return r
}

func hacerPost(r *gin.Engine, ruta, body string) *httptest.ResponseRecorder {
	w := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPost, ruta, strings.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	return w
}

func TestPlanificarViaje_OK(t *testing.T) {
	p := &planificadorFalso{}
	w := hacerPost(nuevoRouter(p), "/planificar", `{"destino":"Roma","dias_totales":10,"dias_restantes":10}`)

	if w.Code != http.StatusOK {
		t.Fatalf("status = %d, body = %s", w.Code, w.Body.String())
	}
	var plan models.PlanResponse
	if err := json.Unmarshal(w.Body.Bytes(), &plan); err != nil {
		t.Fatal(err)
	}
	if plan.CiudadActual != "Roma" {
		t.Fatalf("ciudad_actual = %q", plan.CiudadActual)
	}
}

func TestPlanificarViaje_RechazaSinLlamarALaIA(t *testing.T) {
	cuerpos := []string{
		`{"destino":"Roma","dias_totales":10,"dias_restantes":20}`,
		`{"destino":"Roma","dias_totales":500,"dias_restantes":10}`,
		`{"destino":"   ","dias_totales":10,"dias_restantes":10}`,
		`{"dias_totales":10,"dias_restantes":10}`,
		`no es json`,
	}
	for _, body := range cuerpos {
		p := &planificadorFalso{}
		w := hacerPost(nuevoRouter(p), "/planificar", body)
		if w.Code != http.StatusBadRequest {
			t.Errorf("body %s: status = %d, want 400", body, w.Code)
		}
		if p.llamadas != 0 {
			t.Errorf("body %s: se llamó a la IA con un pedido inválido", body)
		}
	}
}

func TestPlanificarViaje_ErrorInternoNoSeFiltra(t *testing.T) {
	p := &planificadorFalso{err: errors.New("detalle interno con API key")}
	w := hacerPost(nuevoRouter(p), "/planificar", `{"destino":"Roma","dias_totales":10,"dias_restantes":10}`)

	if w.Code != http.StatusInternalServerError {
		t.Fatalf("status = %d", w.Code)
	}
	if strings.Contains(w.Body.String(), "API key") {
		t.Fatalf("la respuesta expone el error interno: %s", w.Body.String())
	}
}

func TestExtenderCronograma_Validacion(t *testing.T) {
	p := &planificadorFalso{}
	r := nuevoRouter(p)

	w := hacerPost(r, "/extender", `{"ciudad":"Roma","dia_inicio":5,"dias_adicionales":2}`)
	if w.Code != http.StatusOK {
		t.Fatalf("status = %d, body = %s", w.Code, w.Body.String())
	}

	w = hacerPost(r, "/extender", `{"ciudad":"Roma","dia_inicio":5,"dias_adicionales":999}`)
	if w.Code != http.StatusBadRequest {
		t.Fatalf("status = %d, want 400", w.Code)
	}
}
