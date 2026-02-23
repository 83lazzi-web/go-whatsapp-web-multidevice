#!/bin/bash

# Script de inicialização para o container WhatsApp
# Uso: ./setup.sh [rest|mcp]

set -e

echo "========================================="
echo "🚀 WhatsApp Web Multi-Device"
echo "========================================="
echo ""

# Configuração padrão
MODE="${1:-rest}"
APP_PORT="${APP_PORT:-8083}"

echo "📋 Configuração:"
echo "  - Modo: $MODE"
echo "  - Porta: $APP_PORT"
echo "  - Debug: ${APP_DEBUG:-false}"
echo ""

# Verificar se diretórios existem
echo "📁 Verificando diretórios..."
mkdir -p storages statics/qrcode statics/media statics/senditems
echo "✅ Diretórios OK"
echo ""

# Verificar variáveis de ambiente importantes
echo "🔍 Verificando configuração..."
if [ -n "$WHATSAPP_WEBHOOK" ]; then
    echo "✅ WHATSAPP_WEBHOOK: $WHATSAPP_WEBHOOK"
else
    echo "⚠️  WHATSAPP_WEBHOOK não configurado"
fi

if [ -n "$WHATSAPP_WEBHOOK_SECRET" ]; then
    echo "✅ WHATSAPP_WEBHOOK_SECRET: [CONFIGURADO]"
else
    echo "⚠️  WHATSAPP_WEBHOOK_SECRET não configurado"
fi
echo ""

# Iniciar aplicação
echo "🚀 Iniciando aplicação em modo: $MODE"
echo "========================================="
echo ""

# Executar binário com modo especificado
exec ./whatsapp "$MODE"
