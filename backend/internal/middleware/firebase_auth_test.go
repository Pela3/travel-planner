package middleware

import (
	"context"
	"crypto"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
)

const proyecto = "travel-planner-test"

var ahoraFijo = time.Date(2026, 10, 1, 12, 0, 0, 0, time.UTC)

func generarClave(t *testing.T) *rsa.PrivateKey {
	t.Helper()
	k, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		t.Fatal(err)
	}
	return k
}

func firmar(t *testing.T, k *rsa.PrivateKey, kid string, claims map[string]any) string {
	t.Helper()
	enc := func(v any) string {
		b, _ := json.Marshal(v)
		return base64.RawURLEncoding.EncodeToString(b)
	}
	cuerpo := enc(map[string]string{"alg": "RS256", "kid": kid}) + "." + enc(claims)
	hash := sha256.Sum256([]byte(cuerpo))
	firma, err := rsa.SignPKCS1v15(rand.Reader, k, crypto.SHA256, hash[:])
	if err != nil {
		t.Fatal(err)
	}
	return cuerpo + "." + base64.RawURLEncoding.EncodeToString(firma)
}

func claimsValidos() map[string]any {
	return map[string]any{
		"aud":            proyecto,
		"iss":            "https://securetoken.google.com/" + proyecto,
		"sub":            "usuario-123",
		"email_verified": true,
		"iat":            ahoraFijo.Add(-10 * time.Minute).Unix(),
		"exp":            ahoraFijo.Add(50 * time.Minute).Unix(),
	}
}

// verificador con claves en memoria; cuenta cuántas veces "descarga".
func verificador(claves map[string]*rsa.PublicKey, descargas *int) *VerificadorFirebase {
	v := NewVerificadorFirebase(proyecto)
	v.ahora = func() time.Time { return ahoraFijo }
	v.descargarClaves = func(context.Context) (map[string]*rsa.PublicKey, time.Time, error) {
		if descargas != nil {
			*descargas++
		}
		return claves, ahoraFijo.Add(time.Hour), nil
	}
	return v
}

func TestVerificarTokenValido(t *testing.T) {
	k := generarClave(t)
	descargas := 0
	v := verificador(map[string]*rsa.PublicKey{"k1": &k.PublicKey}, &descargas)

	token := firmar(t, k, "k1", claimsValidos())
	for i := 0; i < 2; i++ {
		uid, err := v.Verificar(context.Background(), token)
		if err != nil || uid != "usuario-123" {
			t.Fatalf("Verificar = %q, %v; want usuario-123", uid, err)
		}
	}
	if descargas != 1 {
		t.Errorf("descargó las claves %d veces, want 1 (cacheadas)", descargas)
	}
}

func TestVerificarRechazaTokensInvalidos(t *testing.T) {
	k := generarClave(t)
	otra := generarClave(t)
	v := verificador(map[string]*rsa.PublicKey{"k1": &k.PublicKey}, nil)

	con := func(cambio func(map[string]any)) map[string]any {
		c := claimsValidos()
		cambio(c)
		return c
	}
	casos := map[string]string{
		"vencido":          firmar(t, k, "k1", con(func(c map[string]any) { c["exp"] = ahoraFijo.Add(-time.Hour).Unix() })),
		"de otro proyecto": firmar(t, k, "k1", con(func(c map[string]any) { c["aud"] = "otro" })),
		"otro emisor":      firmar(t, k, "k1", con(func(c map[string]any) { c["iss"] = "https://evil.example" })),
		"sin usuario":      firmar(t, k, "k1", con(func(c map[string]any) { c["sub"] = "" })),
		"emitido a futuro": firmar(t, k, "k1", con(func(c map[string]any) { c["iat"] = ahoraFijo.Add(time.Hour).Unix() })),
		"firmado por otro": firmar(t, otra, "k1", claimsValidos()),
		"kid desconocido":  firmar(t, k, "k9", claimsValidos()),
		"no es un JWT":     "basura",
		"firma manipulada": firmar(t, k, "k1", claimsValidos()) + "x",
	}
	for nombre, token := range casos {
		t.Run(nombre, func(t *testing.T) {
			if uid, err := v.Verificar(context.Background(), token); !errors.Is(err, errTokenInvalido) {
				t.Errorf("Verificar = %q, %v; want errTokenInvalido", uid, err)
			}
		})
	}
}

func TestVerificarRecargaClavesSiAparecenNuevas(t *testing.T) {
	vieja, nueva := generarClave(t), generarClave(t)
	claves := map[string]*rsa.PublicKey{"vieja": &vieja.PublicKey}
	v := verificador(nil, nil)
	v.descargarClaves = func(context.Context) (map[string]*rsa.PublicKey, time.Time, error) {
		return claves, ahoraFijo.Add(time.Hour), nil
	}

	if _, err := v.Verificar(context.Background(), firmar(t, vieja, "vieja", claimsValidos())); err != nil {
		t.Fatal(err)
	}
	// Google rota las claves: el kid nuevo no está en caché y fuerza una descarga.
	claves = map[string]*rsa.PublicKey{"nueva": &nueva.PublicKey}
	if _, err := v.Verificar(context.Background(), firmar(t, nueva, "nueva", claimsValidos())); err != nil {
		t.Fatalf("token con clave rotada: %v", err)
	}
}

func TestMiddlewareFirebase(t *testing.T) {
	gin.SetMode(gin.TestMode)
	k := generarClave(t)
	v := verificador(map[string]*rsa.PublicKey{"k1": &k.PublicKey}, nil)

	r := gin.New()
	r.Use(v.Middleware())
	r.GET("/", func(c *gin.Context) { c.String(http.StatusOK, c.GetString(ClaveUID)) })

	pedirCon := func(auth string) *httptest.ResponseRecorder {
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/", nil)
		if auth != "" {
			req.Header.Set("Authorization", auth)
		}
		r.ServeHTTP(w, req)
		return w
	}

	if w := pedirCon(""); w.Code != http.StatusUnauthorized {
		t.Errorf("sin token: status %d, want 401", w.Code)
	}
	if w := pedirCon("Bearer basura"); w.Code != http.StatusUnauthorized {
		t.Errorf("token inválido: status %d, want 401", w.Code)
	}
	w := pedirCon("Bearer " + firmar(t, k, "k1", claimsValidos()))
	if w.Code != http.StatusOK || w.Body.String() != "usuario-123" {
		t.Errorf("token válido: status %d body %q, want 200 usuario-123", w.Code, w.Body.String())
	}

	// Cuenta de email y contraseña que todavía no tocó el link del correo
	// (o un token sin el dato): 403 con un mensaje que explica qué hacer.
	for _, verificado := range []any{false, nil} {
		claims := claimsValidos()
		if verificado == nil {
			delete(claims, "email_verified")
		} else {
			claims["email_verified"] = verificado
		}
		w = pedirCon("Bearer " + firmar(t, k, "k1", claims))
		if w.Code != http.StatusForbidden || !strings.Contains(w.Body.String(), "Verificá tu email") {
			t.Errorf("email_verified=%v: status %d body %q, want 403 Verificá tu email", verificado, w.Code, w.Body.String())
		}
	}
}

func TestMiddlewareFirebaseSinClavesDevuelve503(t *testing.T) {
	gin.SetMode(gin.TestMode)
	k := generarClave(t)
	v := verificador(nil, nil)
	v.descargarClaves = func(context.Context) (map[string]*rsa.PublicKey, time.Time, error) {
		return nil, time.Time{}, errors.New("google caído")
	}
	r := gin.New()
	r.Use(v.Middleware())
	r.GET("/", func(c *gin.Context) { c.Status(http.StatusOK) })

	w := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/", nil)
	req.Header.Set("Authorization", "Bearer "+firmar(t, k, "k1", claimsValidos()))
	r.ServeHTTP(w, req)
	if w.Code != http.StatusServiceUnavailable {
		t.Errorf("status %d, want 503", w.Code)
	}
}

func TestLimitePorUsuarioYNoPorIP(t *testing.T) {
	gin.SetMode(gin.TestMode)
	rl := NewRateLimiter(2, 0)
	r := gin.New()
	r.Use(func(c *gin.Context) { c.Set(ClaveUID, c.GetHeader("X-Usuario")); c.Next() }, rl.Middleware())
	r.GET("/", func(c *gin.Context) { c.Status(http.StatusOK) })

	pedirComo := func(usuario string) int {
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/", nil)
		req.RemoteAddr = "9.9.9.9:1234" // todos desde la misma IP (p. ej. un wifi compartido)
		req.Header.Set("X-Usuario", usuario)
		r.ServeHTTP(w, req)
		return w.Code
	}

	pedirComo("ana")
	pedirComo("ana")
	if code := pedirComo("ana"); code != http.StatusTooManyRequests {
		t.Errorf("tercer pedido de ana: %d, want 429", code)
	}
	if code := pedirComo("beto"); code != http.StatusOK {
		t.Errorf("beto desde la misma IP: %d, want 200", code)
	}
}

func TestMaxAge(t *testing.T) {
	if got := maxAge("public, max-age=19302, must-revalidate"); got != 19302*time.Second {
		t.Errorf("maxAge = %v", got)
	}
	if got := maxAge(""); got != time.Hour {
		t.Errorf("maxAge vacío = %v, want 1h", got)
	}
}
