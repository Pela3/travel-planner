package middleware

import (
	"context"
	"crypto"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/x509"
	"encoding/base64"
	"encoding/json"
	"encoding/pem"
	"errors"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
)

// URL con las claves públicas que firman los ID tokens de Firebase Auth.
const urlClavesFirebase = "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"

// Margen para diferencias de reloj entre Google y el servidor.
const toleranciaReloj = 2 * time.Minute

// VerificadorFirebase valida los ID tokens que manda la app (Authorization:
// Bearer <token>) según https://firebase.google.com/docs/auth/admin/verify-id-tokens
// sin depender del SDK de Firebase Admin.
type VerificadorFirebase struct {
	projectID string
	ahora     func() time.Time
	// descargarClaves devuelve las claves por kid y hasta cuándo se pueden cachear.
	descargarClaves func(ctx context.Context) (map[string]*rsa.PublicKey, time.Time, error)

	mu           sync.Mutex
	claves       map[string]*rsa.PublicKey
	venceEnCache time.Time
}

func NewVerificadorFirebase(projectID string) *VerificadorFirebase {
	return &VerificadorFirebase{
		projectID:       projectID,
		ahora:           time.Now,
		descargarClaves: descargarClavesGoogle,
	}
}

type claimsFirebase struct {
	Aud string `json:"aud"`
	Iss string `json:"iss"`
	Sub string `json:"sub"`
	Exp int64  `json:"exp"`
	Iat int64  `json:"iat"`
	// Google lo trae en true; email y contraseña, recién después de tocar el
	// link del correo de verificación.
	EmailVerified bool `json:"email_verified"`
}

var (
	errTokenInvalido     = errors.New("token inválido")
	errEmailSinVerificar = errors.New("email sin verificar")
)

// Verificar devuelve el uid del usuario si el token es válido.
func (v *VerificadorFirebase) Verificar(ctx context.Context, token string) (string, error) {
	partes := strings.Split(token, ".")
	if len(partes) != 3 {
		return "", errTokenInvalido
	}

	var header struct {
		Alg string `json:"alg"`
		Kid string `json:"kid"`
	}
	if err := decodificarParte(partes[0], &header); err != nil || header.Alg != "RS256" || header.Kid == "" {
		return "", errTokenInvalido
	}

	clave, err := v.clave(ctx, header.Kid)
	if err != nil {
		return "", err
	}
	firma, err := base64.RawURLEncoding.DecodeString(partes[2])
	if err != nil {
		return "", errTokenInvalido
	}
	hash := sha256.Sum256([]byte(partes[0] + "." + partes[1]))
	if err := rsa.VerifyPKCS1v15(clave, crypto.SHA256, hash[:], firma); err != nil {
		return "", errTokenInvalido
	}

	var c claimsFirebase
	if err := decodificarParte(partes[1], &c); err != nil {
		return "", errTokenInvalido
	}
	ahora := v.ahora()
	switch {
	case c.Aud != v.projectID,
		c.Iss != "https://securetoken.google.com/"+v.projectID,
		c.Sub == "",
		ahora.After(time.Unix(c.Exp, 0).Add(toleranciaReloj)),
		ahora.Add(toleranciaReloj).Before(time.Unix(c.Iat, 0)):
		return "", errTokenInvalido
	}
	// Token válido, pero la cuenta todavía no verificó el email: así un bot
	// no puede usar la IA con cuentas de emails inventados.
	if !c.EmailVerified {
		return "", errEmailSinVerificar
	}
	return c.Sub, nil
}

func decodificarParte(parte string, destino any) error {
	raw, err := base64.RawURLEncoding.DecodeString(parte)
	if err != nil {
		return err
	}
	return json.Unmarshal(raw, destino)
}

// clave busca la clave pública del kid, descargándolas de nuevo si la caché
// venció o si Google rotó las claves y el kid es nuevo.
func (v *VerificadorFirebase) clave(ctx context.Context, kid string) (*rsa.PublicKey, error) {
	v.mu.Lock()
	defer v.mu.Unlock()

	if k, ok := v.claves[kid]; ok && v.ahora().Before(v.venceEnCache) {
		return k, nil
	}
	claves, vence, err := v.descargarClaves(ctx)
	if err != nil {
		return nil, fmt.Errorf("descargando claves de Firebase: %w", err)
	}
	v.claves, v.venceEnCache = claves, vence
	if k, ok := claves[kid]; ok {
		return k, nil
	}
	return nil, errTokenInvalido
}

func descargarClavesGoogle(ctx context.Context) (map[string]*rsa.PublicKey, time.Time, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, urlClavesFirebase, nil)
	if err != nil {
		return nil, time.Time{}, err
	}
	resp, err := (&http.Client{Timeout: 10 * time.Second}).Do(req)
	if err != nil {
		return nil, time.Time{}, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return nil, time.Time{}, fmt.Errorf("status %d", resp.StatusCode)
	}

	var certs map[string]string
	if err := json.NewDecoder(resp.Body).Decode(&certs); err != nil {
		return nil, time.Time{}, err
	}
	claves, err := parsearCertificados(certs)
	if err != nil {
		return nil, time.Time{}, err
	}
	return claves, time.Now().Add(maxAge(resp.Header.Get("Cache-Control"))), nil
}

func parsearCertificados(certs map[string]string) (map[string]*rsa.PublicKey, error) {
	claves := make(map[string]*rsa.PublicKey, len(certs))
	for kid, certPEM := range certs {
		bloque, _ := pem.Decode([]byte(certPEM))
		if bloque == nil {
			return nil, fmt.Errorf("certificado %s ilegible", kid)
		}
		cert, err := x509.ParseCertificate(bloque.Bytes)
		if err != nil {
			return nil, err
		}
		k, ok := cert.PublicKey.(*rsa.PublicKey)
		if !ok {
			return nil, fmt.Errorf("certificado %s no es RSA", kid)
		}
		claves[kid] = k
	}
	return claves, nil
}

// maxAge lee "max-age=N" de Cache-Control; si no está, cachea una hora.
func maxAge(cacheControl string) time.Duration {
	for _, d := range strings.Split(cacheControl, ",") {
		if v, ok := strings.CutPrefix(strings.TrimSpace(d), "max-age="); ok {
			if s, err := strconv.Atoi(v); err == nil && s > 0 {
				return time.Duration(s) * time.Second
			}
		}
	}
	return time.Hour
}

// ClaveUID es donde el middleware deja el uid del usuario en el contexto de gin.
const ClaveUID = "uid"

// Middleware rechaza con 401 los pedidos sin un ID token válido de Firebase.
func (v *VerificadorFirebase) Middleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		token, ok := strings.CutPrefix(c.GetHeader("Authorization"), "Bearer ")
		if !ok || token == "" {
			noAutorizado(c)
			return
		}
		uid, err := v.Verificar(c.Request.Context(), token)
		if errors.Is(err, errEmailSinVerificar) {
			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{
				"error": "Verificá tu email para usar la app: tocá el link del correo que te mandamos.",
			})
			return
		}
		if err != nil {
			if !errors.Is(err, errTokenInvalido) {
				// Falla de Google al dar las claves: no es culpa del usuario.
				c.Error(err)
				c.AbortWithStatusJSON(http.StatusServiceUnavailable, gin.H{
					"error": "No pudimos verificar tu sesión. Intentá de nuevo en un momento.",
				})
				return
			}
			noAutorizado(c)
			return
		}
		c.Set(ClaveUID, uid)
		c.Next()
	}
}

func noAutorizado(c *gin.Context) {
	c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
		"error": "Tu sesión no es válida. Volvé a iniciar sesión.",
	})
}
