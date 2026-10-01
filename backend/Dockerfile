# --- Build ---
FROM golang:1.26-alpine AS build
WORKDIR /src

# Descargar dependencias primero para aprovechar la caché de capas.
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/api ./cmd/api

# --- Runtime ---
# Imagen mínima sin shell, con certificados CA (necesarios para llamar a Gemini por HTTPS).
FROM gcr.io/distroless/static-debian12:nonroot
WORKDIR /app
COPY --from=build /out/api /app/api

ENV GIN_MODE=release \
    PORT=8080 \
    CACHE_FILE=/tmp/cache.json

EXPOSE 8080
USER nonroot:nonroot
ENTRYPOINT ["/app/api"]
