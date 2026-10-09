package middleware

import (
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
)

// HeadersSeguridad agrega los encabezados recomendados a toda respuesta. La API
// solo devuelve JSON, así que se le prohíbe al navegador interpretarla de otra
// forma, mostrarla dentro de otra página o guardarla en caché.
func HeadersSeguridad() gin.HandlerFunc {
	return func(c *gin.Context) {
		h := c.Writer.Header()
		h.Set("Strict-Transport-Security", "max-age=31536000; includeSubDomains")
		h.Set("X-Content-Type-Options", "nosniff")
		h.Set("X-Frame-Options", "DENY")
		h.Set("Content-Security-Policy", "default-src 'none'; frame-ancestors 'none'")
		h.Set("Referrer-Policy", "no-referrer")
		h.Set("Cache-Control", "no-store")
		c.Next()
	}
}

// LimiteCuerpo corta los pedidos más grandes que [maxBytes]. Un viaje real
// ocupa unos pocos KB; sin límite alguien podría mandar megas para trabar el
// servidor o inflar el prompt.
func LimiteCuerpo(maxBytes int64) gin.HandlerFunc {
	return func(c *gin.Context) {
		if c.Request.ContentLength > maxBytes {
			c.AbortWithStatusJSON(http.StatusRequestEntityTooLarge, gin.H{"error": "El pedido es demasiado grande."})
			return
		}
		c.Request.Body = http.MaxBytesReader(c.Writer, c.Request.Body, maxBytes)
		c.Next()
	}
}

// CuotaDiaria limita cuántas consultas a la IA se hacen por día: por usuario
// (frena a una cuenta que abusa) y en total (pone techo al gasto de Gemini
// aunque alguien cree muchas cuentas). Se reinicia a la medianoche UTC y
// también si el servidor se reinicia; para un techo duro de gasto está el
// presupuesto de Google Cloud.
type CuotaDiaria struct {
	porUsuario int
	global     int
	ahora      func() time.Time

	mu        sync.Mutex
	dia       string
	usos      map[string]int
	usosTotal int
}

// NewCuotaDiaria crea la cuota. Un valor <= 0 desactiva ese límite.
func NewCuotaDiaria(porUsuario, global int) *CuotaDiaria {
	return &CuotaDiaria{porUsuario: porUsuario, global: global, ahora: time.Now, usos: map[string]int{}}
}

// permitir registra un uso de [clave] y dice si entra en la cuota.
func (q *CuotaDiaria) permitir(clave string) (bool, string) {
	q.mu.Lock()
	defer q.mu.Unlock()

	if hoy := q.ahora().UTC().Format("2006-01-02"); hoy != q.dia {
		q.dia, q.usos, q.usosTotal = hoy, map[string]int{}, 0
	}
	if q.global > 0 && q.usosTotal >= q.global {
		return false, "La app alcanzó el límite de consultas de hoy. Probá de nuevo mañana."
	}
	if q.porUsuario > 0 && q.usos[clave] >= q.porUsuario {
		return false, "Llegaste al límite de consultas de hoy. Probá de nuevo mañana."
	}
	q.usos[clave]++
	q.usosTotal++
	return true, ""
}

func (q *CuotaDiaria) Middleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		clave := c.GetString(ClaveUID)
		if clave == "" {
			clave = "ip:" + c.ClientIP()
		}
		if ok, mensaje := q.permitir(clave); !ok {
			c.AbortWithStatusJSON(http.StatusTooManyRequests, gin.H{"error": mensaje})
			return
		}
		c.Next()
	}
}
