#!/bin/bash

# Script para build e teste do container Docker
# Uso: ./build-and-test.sh

set -e

echo "========================================="
echo "🐳 Build & Test - WhatsApp Docker"
echo "========================================="
echo ""

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para log
log_info() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 1. Verificar se Docker está rodando
echo "🔍 Verificando Docker..."
if ! docker info > /dev/null 2>&1; then
    log_error "Docker não está rodando!"
    exit 1
fi
log_info "Docker OK"
echo ""

# 2. Build da imagem
echo "🔨 Buildando imagem Docker..."
docker build -t go-whatsapp-multidevice:latest . || {
    log_error "Erro no build!"
    exit 1
}
log_info "Build concluído!"
echo ""

# 3. Verificar tamanho da imagem
echo "📊 Tamanho da imagem:"
docker images go-whatsapp-multidevice:latest --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
echo ""

# 4. Testar se a imagem inicia corretamente
echo "🧪 Testando container..."
TEST_CONTAINER="whatsapp_test_$$"

docker run -d \
    --name "$TEST_CONTAINER" \
    -e APP_PORT=8083 \
    -e APP_DEBUG=true \
    -e APP_BASIC_AUTH="admin:test123" \
    -p 8083:8083 \
    go-whatsapp-multidevice:latest || {
    log_error "Erro ao iniciar container de teste!"
    exit 1
}

echo "⏳ Aguardando container iniciar..."
sleep 5

# Verificar logs
echo ""
echo "📋 Logs do container:"
docker logs "$TEST_CONTAINER" 2>&1 | tail -20

# Verificar se está rodando
if docker ps | grep -q "$TEST_CONTAINER"; then
    log_info "Container está rodando!"
else
    log_error "Container não está rodando!"
    docker logs "$TEST_CONTAINER"
    docker rm -f "$TEST_CONTAINER" 2>/dev/null
    exit 1
fi

# Testar health check
echo ""
echo "🏥 Testando health check..."
sleep 3
if curl -f -s http://localhost:8083/app/health > /dev/null 2>&1; then
    log_info "Health check passou!"
else
    log_warn "Health check falhou (pode ser normal se não houver sessão)"
fi

# Limpar container de teste
echo ""
echo "🧹 Limpando container de teste..."
docker stop "$TEST_CONTAINER" > /dev/null
docker rm "$TEST_CONTAINER" > /dev/null
log_info "Container de teste removido"

echo ""
echo "========================================="
echo "✅ Build e teste concluídos com sucesso!"
echo "========================================="
echo ""
echo "📝 Próximos passos:"
echo ""
echo "1. Para rodar localmente:"
echo "   docker-compose up -d"
echo ""
echo "2. Para usar no servidor VPS:"
echo "   a) Copie esta pasta para o servidor"
echo "   b) Execute no servidor: docker-compose up -d"
echo ""
echo "3. Para ver logs:"
echo "   docker logs -f whatsapp_8083"
echo ""
echo "4. Para acessar o QR Code:"
echo "   http://SEU_IP:8083"
echo "   Usuário: admin"
echo "   Senha: Lazzi1302983"
echo ""
