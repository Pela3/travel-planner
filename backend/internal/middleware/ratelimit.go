package middleware

import (
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/time/rate"
)

// RateLimiter combina un límite por IP con un límite global.
//
// El límite por IP frena a un usuario puntual que abusa. El global protege la
// cuota de Gemini aunque alguien rote IPs o falsee X-Forwarded-For (detrás de
// un proxy la IP del cliente no es 100% confiable).
type RateLimiter struct {
	porMinutoIP int
	global      *rate.Limiter

	mu       sync.Mutex
	clientes map[string]*cliente
	ahora    func() time.Time
}

type cliente struct {
	limiter   *rate.Limiter
	ultimoUso time.Time
}

const inactividadParaOlvidar = 10 * time.Minute

// NewRateLimiter crea el limitador. Un valor <= 0 desactiva ese límite.
// Cada límite permite una ráfaga igual a su cantidad por minuto.
func NewRateLimiter(porMinutoIP, globalPorMinuto int) *RateLimiter {
	rl := &RateLimiter{
		porMinutoIP: porMinutoIP,
		clientes:    make(map[string]*cliente),
		ahora:       time.Now,
	}
	if globalPorMinuto > 0 {
		rl.global = rate.NewLimiter(porMinuto(globalPorMinuto), globalPorMinuto)
	}
	return rl
}

func porMinuto(n int) rate.Limit {
	return rate.Every(time.Minute / time.Duration(n))
}

func (rl *RateLimiter) limiterDe(ip string) *rate.Limiter {
	rl.mu.Lock()
	defer rl.mu.Unlock()

	now := rl.ahora()
	c, ok := rl.clientes[ip]
	if !ok {
		rl.olvidarInactivos(now)
		c = &cliente{limiter: rate.NewLimiter(porMinuto(rl.porMinutoIP), rl.porMinutoIP)}
		rl.clientes[ip] = c
	}
	c.ultimoUso = now
	return c.limiter
}

// olvidarInactivos evita que el mapa crezca sin límite. Se llama con rl.mu tomado.
func (rl *RateLimiter) olvidarInactivos(now time.Time) {
	for ip, c := range rl.clientes {
		if now.Sub(c.ultimoUso) > inactividadParaOlvidar {
			delete(rl.clientes, ip)
		}
	}
}

func (rl *RateLimiter) Middleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		if rl.porMinutoIP > 0 && !rl.limiterDe(c.ClientIP()).Allow() {
			rechazar(c)
			return
		}
		if rl.global != nil && !rl.global.Allow() {
			rechazar(c)
			return
		}
		c.Next()
	}
}

func rechazar(c *gin.Context) {
	c.Header("Retry-After", "60")
	c.AbortWithStatusJSON(http.StatusTooManyRequests, gin.H{
		"error": "Demasiadas solicitudes. Esperá un minuto e intentá de nuevo.",
	})
}
