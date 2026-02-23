#!/bin/bash

# Script para iniciar o servidor WhatsApp Web Multi-device
# Autor: Configuração automática

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  WhatsApp Web Multi-device Server${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Navegar para o diretório do projeto
cd "$(dirname "$0")/src" || exit 1

# Verificar se o executável existe
if [ ! -f "whatsapp" ]; then
    echo -e "${RED}Executável não encontrado. Compilando...${NC}"
    /usr/local/go/bin/go build -o whatsapp
    if [ $? -ne 0 ]; then
        echo -e "${RED}Erro ao compilar o projeto!${NC}"
        exit 1
    fi
    echo -e "${GREEN}Compilação concluída!${NC}"
fi

# Verificar se o arquivo .env existe
if [ ! -f ".env" ]; then
    echo -e "${RED}Arquivo .env não encontrado!${NC}"
    exit 1
fi

echo -e "${GREEN}Iniciando servidor...${NC}"
echo ""
echo -e "${BLUE}Configurações:${NC}"
echo -e "  Porta: ${GREEN}8080${NC}"
echo -e "  OS: ${GREEN}Photu${NC}"
echo -e "  Webhook: ${GREEN}http://127.0.0.1:8001/api/v1/webhook/whatsapp${NC}"
echo -e "  Autenticação: ${GREEN}admin:Lazzi1302983${NC}"
echo ""
echo -e "${BLUE}Acesse: ${GREEN}http://localhost:8080${NC}"
echo ""

# Iniciar o servidor
./whatsapp rest

