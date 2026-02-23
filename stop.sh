#!/bin/bash

# Script para parar o servidor WhatsApp Web Multi-device

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${RED}Parando servidor WhatsApp...${NC}"

# Encontrar e matar o processo
pkill -f "whatsapp rest"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Servidor parado com sucesso!${NC}"
else
    echo -e "${RED}Nenhum processo encontrado ou erro ao parar.${NC}"
fi

