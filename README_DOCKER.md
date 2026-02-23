# 🐳 Docker para WhatsApp Web Multi-Device

Configuração Docker para o servidor WhatsApp com suporte ao backend Lazzi.

## 📋 Arquivos Criados

- `Dockerfile` - Multi-stage build otimizado
- `setup.sh` - Script de inicialização do container
- `.dockerignore` - Arquivos ignorados no build
- `docker-compose.example.yml` - Exemplo standalone
- `build-and-test.sh` - Script de build e teste

## 🚀 Uso Local (Teste)

### 1. Build da Imagem

```bash
cd /home/vilson/projetos_vilson/lazaro/go-whatsapp-web-multidevice
docker build -t go-whatsapp-multidevice:latest .
```

### 2. Rodar Container

```bash
docker run -d \
  --name whatsapp_test \
  -p 8083:8083 \
  -e APP_PORT=8083 \
  -e APP_BASIC_AUTH="admin:Lazzi1302983" \
  -e WHATSAPP_WEBHOOK="https://lazzi-app-backend.onrender.com/api/v1/webhook/whatsapp" \
  -e WHATSAPP_WEBHOOK_SECRET="whuV7ZqR+1WZ0DfXhCkzO8ApG6r9X7tNnSxPqvMbq2U=" \
  -v whatsapp_data:/app/storages \
  go-whatsapp-multidevice:latest
```

### 3. Ver Logs

```bash
docker logs -f whatsapp_test
```

### 4. Acessar Interface Web

Abra no navegador:
```
http://localhost:8083
```

Credenciais:
- **Usuário**: admin
- **Senha**: Lazzi1302983

## 📦 Uso com Docker Compose (Produção)

O arquivo `/home/vilson/projetos_vilson/lazaro/deploy/docker-compose.yml` já foi atualizado para usar o novo Dockerfile.

### Deploy no Servidor VPS

#### 1. Copiar projeto para o VPS

```bash
# Do seu computador local
cd /home/vilson/projetos_vilson/lazaro
tar czf whatsapp.tar.gz go-whatsapp-web-multidevice/
scp whatsapp.tar.gz root@158.220.86.60:/root/

# No servidor VPS
ssh root@158.220.86.60
cd /root
tar xzf whatsapp.tar.gz
```

#### 2. Copiar docker-compose.yml

```bash
# Do seu computador local
scp /home/vilson/projetos_vilson/lazaro/deploy/docker-compose.yml root@158.220.86.60:/root/deploy/
```

#### 3. Build e Start no VPS

```bash
# No servidor VPS
ssh root@158.220.86.60
cd /root/deploy

# Build da imagem
docker-compose build zap_go_8083

# Iniciar container
docker-compose up -d zap_go_8083

# Ver logs
docker-compose logs -f zap_go_8083
```

## 🔧 Estrutura do Container

### Diretórios

```
/app/
├── whatsapp              # Binário compilado
├── setup.sh              # Script de inicialização
├── statics/
│   ├── qrcode/          # QR codes gerados
│   ├── media/           # Mídia recebida
│   └── senditems/       # Itens enviados
├── views/               # Templates HTML
└── storages/            # Dados persistentes (volume)
    ├── whatsapp.db      # Sessões WhatsApp
    └── chatstorage.db   # Histórico de chat
```

### Variáveis de Ambiente Importantes

| Variável | Descrição | Padrão |
|----------|-----------|--------|
| `APP_PORT` | Porta do servidor | 8083 |
| `APP_DEBUG` | Modo debug | false |
| `APP_BASIC_AUTH` | Autenticação (user:pass) | admin:Lazzi1302983 |
| `WHATSAPP_WEBHOOK` | URL do webhook | - |
| `WHATSAPP_WEBHOOK_SECRET` | Segredo HMAC | - |
| `WHATSAPP_LOG_LEVEL` | Nível de log | INFO |

## 📊 Monitoramento

### Health Check

O container tem health check automático:

```bash
# Ver status de health
docker inspect --format='{{.State.Health.Status}}' zap_go_8083
```

### Logs

```bash
# Últimas 100 linhas
docker logs --tail 100 zap_go_8083

# Tempo real
docker logs -f zap_go_8083

# Com timestamp
docker logs -f --timestamps zap_go_8083

# Filtrar erros
docker logs zap_go_8083 2>&1 | grep -i error
```

### Métricas

```bash
# CPU e Memória
docker stats zap_go_8083

# Detalhes do container
docker inspect zap_go_8083
```

## 🧪 Testes

### Teste Automatizado

```bash
cd /home/vilson/projetos_vilson/lazaro/go-whatsapp-web-multidevice
./build-and-test.sh
```

### Teste Manual do Webhook

```bash
# Do seu computador local
/home/vilson/projetos_vilson/lazaro/test_webhook.sh
```

### Teste de Conexão

```bash
# Verificar se servidor está respondendo
curl -u admin:Lazzi1302983 http://158.220.86.60:8083/app/devices

# Deve retornar algo como:
# {"code":"SUCCESS","message":"Fetch device success","results":[...]}
```

## 🐛 Troubleshooting

### Container não inicia

```bash
# Ver logs de erro
docker logs zap_go_8083

# Verificar se porta está em uso
lsof -i :8083

# Reiniciar container
docker-compose restart zap_go_8083
```

### Webhook não está funcionando

```bash
# Verificar variável no container rodando
docker exec zap_go_8083 env | grep WHATSAPP_WEBHOOK

# Deve mostrar:
# WHATSAPP_WEBHOOK=https://lazzi-app-backend.onrender.com/api/v1/webhook/whatsapp
```

### Sessão WhatsApp perdida

```bash
# Verificar volume
docker volume inspect zap_go_8083_data

# Backup do volume
docker run --rm -v zap_go_8083_data:/data -v $(pwd):/backup alpine tar czf /backup/whatsapp-backup.tar.gz /data
```

## 📝 Manutenção

### Atualizar Imagem

```bash
# Rebuild
docker-compose build zap_go_8083

# Recriar container
docker-compose up -d --force-recreate zap_go_8083
```

### Backup

```bash
# Backup completo
docker-compose stop zap_go_8083
docker run --rm -v zap_go_8083_data:/data -v $(pwd):/backup alpine tar czf /backup/whatsapp-data.tar.gz /data
docker-compose start zap_go_8083
```

### Restore

```bash
docker-compose stop zap_go_8083
docker run --rm -v zap_go_8083_data:/data -v $(pwd):/backup alpine tar xzf /backup/whatsapp-data.tar.gz -C /
docker-compose start zap_go_8083
```

## ✅ Checklist de Deploy

- [ ] Projeto copiado para o VPS
- [ ] docker-compose.yml atualizado
- [ ] Variáveis de ambiente configuradas
- [ ] `WHATSAPP_WEBHOOK` aponta para Render
- [ ] Build da imagem concluído
- [ ] Container iniciado
- [ ] Logs verificados
- [ ] QR Code escaneado
- [ ] Webhook testado
- [ ] Mensagem OTP recebida

## 📞 Suporte

Se algo der errado, verifique:

1. **Logs do container**: `docker logs -f zap_go_8083`
2. **Logs do Render**: https://dashboard.render.com
3. **Health check**: `docker inspect zap_go_8083 | grep Health -A 10`
4. **Conectividade**: `curl https://lazzi-app-backend.onrender.com/api/v1/health`
