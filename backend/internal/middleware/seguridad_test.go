package middleware

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
)

func TestHeadersSeguridad(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.Use(HeadersSeguridad())
	r.GET("/", func(c *gin.Context) { c.Status(http.StatusOK) })

	w := httptest.NewRecorder()
	r.ServeHTTP(w, httptest.NewRequest(http.MethodGet, "/", nil))

	for _, h := range []string{"Strict-Transport-Security", "X-Content-Type-Options", "X-Frame-Options",
		"Content-Security-Policy", "Referrer-Policy", "Cache-Control"} {
		if w.Header().Get(h) == "" {
			t.Errorf("falta el header %s", h)
		}
	}
}

func TestLimiteCuerpo(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.Use(LimiteCuerpo(100))
	r.POST("/", func(c *gin.Context) {
		var m map[string]any
		if err := c.ShouldBindJSON(&m); err != nil {
			c.Status(http.StatusBadRequest)
			return
		}
		c.Status(http.StatusOK)
	})

	pedir := func(cuerpo string, sinLargo bool) int {
		req := httptest.NewRequest(http.MethodPost, "/", strings.NewReader(cuerpo))
		if sinLargo {
			req.ContentLength = -1 // como un envío "chunked" que no declara el tamaño
		}
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)
		return w.Code
	}

	if code := pedir(`{"a":1}`, false); code != http.StatusOK {
		t.Errorf("pedido chico: %d, want 200", code)
	}
	grande := `{"a":"` + strings.Repeat("x", 500) + `"}`
	if code := pedir(grande, false); code != http.StatusRequestEntityTooLarge {
		t.Errorf("pedido grande: %d, want 413", code)
	}
	if code := pedir(grande, true); code == http.StatusOK {
		t.Errorf("pedido grande sin Content-Length pasó")
	}
}

func TestCuotaDiaria(t *testing.T) {
	gin.SetMode(gin.TestMode)
	q := NewCuotaDiaria(2, 3)
	dia := time.Date(2026, 10, 9, 12, 0, 0, 0, time.UTC)
	q.ahora = func() time.Time { return dia }

	r := gin.New()
	r.Use(func(c *gin.Context) { c.Set(ClaveUID, c.GetHeader("X-Usuario")); c.Next() }, q.Middleware())
	r.GET("/", func(c *gin.Context) { c.Status(http.StatusOK) })
	pedirComo := func(u string) *httptest.ResponseRecorder {
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/", nil)
		req.Header.Set("X-Usuario", u)
		r.ServeHTTP(w, req)
		return w
	}

	pedirComo("ana")
	pedirComo("ana")
	if w := pedirComo("ana"); w.Code != http.StatusTooManyRequests || !strings.Contains(w.Body.String(), "Llegaste al límite") {
		t.Errorf("tercer pedido de ana: %d %s, want 429 por usuario", w.Code, w.Body.String())
	}
	pedirComo("beto") // tercer uso total (el rechazado de ana no cuenta)
	if w := pedirComo("caro"); w.Code != http.StatusTooManyRequests || !strings.Contains(w.Body.String(), "La app alcanzó") {
		t.Errorf("con el cupo global lleno: %d %s, want 429 global", w.Code, w.Body.String())
	}

	// Al día siguiente se reinicia.
	dia = dia.Add(24 * time.Hour)
	if w := pedirComo("ana"); w.Code != http.StatusOK {
		t.Errorf("al día siguiente: %d, want 200", w.Code)
	}
}
