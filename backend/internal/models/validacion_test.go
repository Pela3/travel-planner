package models

import (
	"strings"
	"testing"
)

func TestPlanRequestValidar(t *testing.T) {
	valido := PlanRequest{Destino: "Roma", CiudadOrigen: "Buenos Aires", DiasTotales: 10, DiasRestantes: 10}

	casos := []struct {
		nombre  string
		mutar   func(r *PlanRequest)
		wantErr bool
	}{
		{"válido", func(r *PlanRequest) {}, false},
		{"origen vacío es válido", func(r *PlanRequest) { r.CiudadOrigen = "" }, false},
		{"destino solo espacios", func(r *PlanRequest) { r.Destino = "   " }, true},
		{"destino demasiado largo", func(r *PlanRequest) { r.Destino = strings.Repeat("a", 101) }, true},
		{"días totales negativos", func(r *PlanRequest) { r.DiasTotales = -1 }, true},
		{"días totales por encima del máximo", func(r *PlanRequest) { r.DiasTotales = MaxDiasViaje + 1 }, true},
		{"restantes mayor que totales", func(r *PlanRequest) { r.DiasRestantes = 11 }, true},
		{"restantes cero", func(r *PlanRequest) { r.DiasRestantes = 0 }, true},
	}

	for _, c := range casos {
		t.Run(c.nombre, func(t *testing.T) {
			r := valido
			c.mutar(&r)
			if err := r.Validar(); (err != nil) != c.wantErr {
				t.Fatalf("Validar() error = %v, wantErr %v", err, c.wantErr)
			}
		})
	}
}

func TestExtenderCronogramaRequestValidar(t *testing.T) {
	valido := ExtenderCronogramaRequest{Ciudad: "Roma", DiaInicio: 5, DiasAdicionales: 2}

	if err := valido.Validar(); err != nil {
		t.Fatalf("request válido rechazado: %v", err)
	}

	r := valido
	r.DiasAdicionales = MaxDiasExtension + 1
	if r.Validar() == nil {
		t.Fatal("esperaba error por demasiados días adicionales")
	}

	r = valido
	r.LugaresYaVistos = make([]string, 201)
	if r.Validar() == nil {
		t.Fatal("esperaba error por demasiados lugares ya vistos")
	}
}
