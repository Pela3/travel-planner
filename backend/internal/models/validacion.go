package models

import (
	"fmt"
	"strings"
)

const (
	MaxDiasViaje       = 60
	MaxDiasExtension   = 30
	maxLargoCiudad     = 100
	maxLugaresYaVistos = 200
)

// Validar controla los rangos que el binding de Gin no cubre, para no gastar
// llamadas a la IA con pedidos absurdos (días negativos, textos gigantes, etc.).
func (r PlanRequest) Validar() error {
	if err := validarCiudad("destino", r.Destino, true); err != nil {
		return err
	}
	if err := validarCiudad("ciudad_origen", r.CiudadOrigen, false); err != nil {
		return err
	}
	if r.DiasTotales < 1 || r.DiasTotales > MaxDiasViaje {
		return fmt.Errorf("dias_totales debe estar entre 1 y %d", MaxDiasViaje)
	}
	if r.DiasRestantes < 1 || r.DiasRestantes > r.DiasTotales {
		return fmt.Errorf("dias_restantes debe estar entre 1 y dias_totales")
	}
	return nil
}

func (r ExtenderCronogramaRequest) Validar() error {
	if err := validarCiudad("ciudad", r.Ciudad, true); err != nil {
		return err
	}
	if r.DiaInicio < 1 || r.DiaInicio > MaxDiasViaje {
		return fmt.Errorf("dia_inicio debe estar entre 1 y %d", MaxDiasViaje)
	}
	if r.DiasAdicionales < 1 || r.DiasAdicionales > MaxDiasExtension {
		return fmt.Errorf("dias_adicionales debe estar entre 1 y %d", MaxDiasExtension)
	}
	if len(r.LugaresYaVistos) > maxLugaresYaVistos {
		return fmt.Errorf("lugares_ya_vistos admite como máximo %d elementos", maxLugaresYaVistos)
	}
	return nil
}

func validarCiudad(campo, valor string, requerido bool) error {
	v := strings.TrimSpace(valor)
	if requerido && v == "" {
		return fmt.Errorf("%s es obligatorio", campo)
	}
	if len([]rune(v)) > maxLargoCiudad {
		return fmt.Errorf("%s no puede superar %d caracteres", campo, maxLargoCiudad)
	}
	return nil
}
