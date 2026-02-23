# ========================================
# Stage 1: Build
# ========================================
FROM golang:1.25-alpine AS builder

# Instalar dependências de build
RUN apk add --no-cache \
    git \
    gcc \
    musl-dev \
    sqlite-dev

# Diretório de trabalho
WORKDIR /build

# Copiar go.mod e go.sum primeiro (melhor cache)
COPY src/go.mod src/go.sum ./
RUN go mod download

# Copiar código fonte
COPY src/ ./

# Build do binário (estático para Alpine)
# CGO_ENABLED=1 porque usa sqlite3
RUN CGO_ENABLED=1 GOOS=linux go build \
    -a \
    -ldflags '-linkmode external -extldflags "-static"' \
    -o whatsapp \
    main.go

# ========================================
# Stage 2: Runtime
# ========================================
FROM alpine:latest

# Instalar dependências runtime
RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    ffmpeg \
    imagemagick \
    bash

# Criar usuário não-root
RUN addgroup -g 1000 whatsapp && \
    adduser -D -u 1000 -G whatsapp whatsapp

# Diretório de trabalho
WORKDIR /app

# Copiar binário do stage de build
COPY --from=builder /build/whatsapp .

# Copiar arquivos estáticos necessários
COPY --from=builder /build/statics ./statics
COPY --from=builder /build/views ./views

# Criar diretórios necessários
RUN mkdir -p storages statics/qrcode statics/media statics/senditems && \
    chown -R whatsapp:whatsapp /app

# Copiar script de setup
COPY setup.sh .
RUN chmod +x setup.sh && \
    chown whatsapp:whatsapp setup.sh

# Mudar para usuário não-root
USER whatsapp

# Expor porta (será definida por variável de ambiente)
EXPOSE 8083

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:${APP_PORT:-8083}/app/health || exit 1

# Entrypoint
ENTRYPOINT ["./setup.sh"]

# Comando padrão
CMD ["rest"]
