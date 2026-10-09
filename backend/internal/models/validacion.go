package models

import (
	"fmt"
	"strings"
	"unicode"
)

const (
	MaxDiasViaje       = 60
	MaxDiasExtension   = 30
	maxLargoCiudad     = 100
	maxLugaresYaVistos = 200
	maxLargoLugar      = 150
)

// Valores que manda la app. Todo lo que llega se mete en el prompt de Gemini:
// con listas cerradas nadie puede colar instrucciones en estos campos.
var (
	estilosValidos  = conjunto("cultural", "gastronomico", "playa", "aventura", "economico", "relax")
	companiaValidas = conjunto("solo", "pareja", "familia", "amigos")
	mesesValidos    = conjunto("enero", "febrero", "marzo", "abril", "mayo", "junio", "julio",
		"agosto", "septiembre", "octubre", "noviembre", "diciembre")
)

func conjunto(valores ...string) map[string]bool {
	m := make(map[string]bool, len(valores))
	for _, v := range valores {
		m[v] = true
	}
	return m
}

// validarOpcion acepta vacío (el backend usa un valor por defecto) o uno de la lista.
func validarOpcion(campo, valor string, validos map[string]bool) error {
	v := strings.ToLower(strings.TrimSpace(valor))
	if v != "" && !validos[v] {
		return fmt.Errorf("%s no es un valor válido", campo)
	}
	return nil
}

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
	if err := validarOpcion("estilo_viaje", r.EstiloViaje, estilosValidos); err != nil {
		return err
	}
	if err := validarOpcion("compania", r.Compania, companiaValidas); err != nil {
		return err
	}
	return validarOpcion("mes_viaje", r.MesViaje, mesesValidos)
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
	if err := validarOpcion("estilo", r.Estilo, estilosValidos); err != nil {
		return err
	}
	if len(r.LugaresYaVistos) > maxLugaresYaVistos {
		return fmt.Errorf("lugares_ya_vistos admite como máximo %d elementos", maxLugaresYaVistos)
	}
	for _, l := range r.LugaresYaVistos {
		if len([]rune(l)) > maxLargoLugar {
			return fmt.Errorf("cada lugar de lugares_ya_vistos admite como máximo %d caracteres", maxLargoLugar)
		}
	}
	return nil
}

// LimpiarTexto saca saltos de línea y caracteres de control. Los lugares ya
// vistos vienen de respuestas anteriores de la IA y pueden traer cualquier
// signo, así que no se rechazan: se limpian antes de ir al prompt.
func LimpiarTexto(s string) string {
	return strings.Join(strings.FieldsFunc(s, unicode.IsControl), " ")
}

func validarCiudad(campo, valor string, requerido bool) error {
	v := strings.TrimSpace(valor)
	if requerido && v == "" {
		return fmt.Errorf("%s es obligatorio", campo)
	}
	if len([]rune(v)) > maxLargoCiudad {
		return fmt.Errorf("%s no puede superar %d caracteres", campo, maxLargoCiudad)
	}
	// Nombres de lugares: letras de cualquier idioma, números, espacios y
	// algunos signos (São Paulo, Saint-Malo, L'Aquila, Tokio (Japón)). Sin
	// saltos de línea ni símbolos que sirvan para darle órdenes a la IA.
	for _, c := range v {
		if !(unicode.IsLetter(c) || unicode.IsMark(c) || unicode.IsDigit(c) || c == ' ' || strings.ContainsRune(".,'’-()/&", c)) {
			return fmt.Errorf("%s tiene caracteres no permitidos", campo)
		}
	}
	return nil
}
