package middleware

import (
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
)

func router(rl *RateLimiter) *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.Use(rl.Middleware())
	r.GET("/", func(c *gin.Context) { c.Status(http.StatusOK) })
	return r
}

func pedir(r *gin.Engine, ip string) int {
	w := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/", nil)
	req.RemoteAddr = ip + ":1234"
	r.ServeHTTP(w, req)
	return w.Code
}

func TestLimitePorIP(t *testing.T) {
	r := router(NewRateLimiter(3, 0))

	for i := 0; i < 3; i++ {
		if code := pedir(r, "1.1.1.1"); code != http.StatusOK {
			t.Fatalf("pedido %d: status %d, want 200", i+1, code)
		}
	}
	if code := pedir(r, "1.1.1.1"); code != http.StatusTooManyRequests {
		t.Fatalf("cuarto pedido: status %d, want 429", code)
	}
	// Otra IP tiene su propio cupo.
	if code := pedir(r, "2.2.2.2"); code != http.StatusOK {
		t.Fatalf("otra IP: status %d, want 200", code)
	}
}

func TestLimiteGlobal(t *testing.T) {
	r := router(NewRateLimiter(0, 2))

	pedir(r, "1.1.1.1")
	pedir(r, "2.2.2.2")
	if code := pedir(r, "3.3.3.3"); code != http.StatusTooManyRequests {
		t.Fatalf("status %d, want 429 al superar el límite global", code)
	}
}

func TestOlvidaClientesInactivos(t *testing.T) {
	rl := NewRateLimiter(5, 0)
	ahora := time.Now()
	rl.ahora = func() time.Time { return ahora }

	rl.limiterDe("1.1.1.1")
	ahora = ahora.Add(inactividadParaOlvidar + time.Minute)
	rl.limiterDe("2.2.2.2")

	if _, sigue := rl.clientes["1.1.1.1"]; sigue {
		t.Fatal("el cliente inactivo debería haberse eliminado")
	}
}
