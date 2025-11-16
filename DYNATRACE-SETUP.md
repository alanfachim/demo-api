# Configuração do Dynatrace

## Status Atual
✅ Aplicação funcionando perfeitamente  
❌ Dynatrace OneAgent **não instalado** (token sem permissão)

## Problema Identificado
O token atual (`dt0c01.ZEK7Q6YVKMC5IQJO2TYGBBFS...`) é um **Personal Access Token** e **não tem permissão** para baixar o OneAgent:

```bash
curl -I "https://zrp88793.live.dynatrace.com/api/v1/deployment/installer/agent/unix/paas/latest?Api-Token=..."
# Retorna: HTTP/1.1 403 Forbidden
```

### Por que falhou?
- Personal Access Tokens não têm o scope `InstallerDownload` necessário
- O Dynatrace Operator também falhou pelos mesmos motivos de permissão
- Tentamos 3 abordagens diferentes, todas bloqueadas por limitações de token

## Soluções Possíveis

### Opção 1: Criar API Token com Scopes Corretos (Recomendado)
1. Acesse o Dynatrace: https://zrp88793.live.dynatrace.com
2. Vá em **Settings** → **Access tokens** → **Generate new token**
3. Selecione os seguintes scopes **obrigatórios**:
   - ✅ `InstallerDownload` - Download OneAgent installer
   - ✅ `DataExport` - Export data
   - ✅ `metrics.ingest` - Ingest metrics
4. Gere o token e copie-o
5. Atualize o secret no Kubernetes:
```bash
kubectl create secret generic dynatrace-config \
  --from-literal=dt-tenant=zrp88793 \
  --from-literal=dt-api-token=SEU_NOVO_TOKEN_AQUI \
  -n demo-api --dry-run=client -o yaml | kubectl apply -f -
```
6. Force rebuild da aplicação:
```bash
cd /home/alanf/demo-api
# Modifique entrypoint.sh para incluir lógica de download do OneAgent
# Commit e push para disparar CI/CD
```

### Opção 2: Usar Dynatrace Operator (Requer Token API)
Se conseguir criar um token API com os scopes corretos:
```bash
# Os arquivos já existem em k8s/dynatrace/
kubectl apply -f k8s/dynatrace/dynakube.yaml
```

### Opção 3: Usar OneAgent Container (Docker Hub)
Alternativa sem precisar baixar via API:
```dockerfile
# No Dockerfile, adicione:
FROM dynatrace/oneagent:latest AS dynatrace
FROM eclipse-temurin:17-jre-alpine
COPY --from=dynatrace /opt/dynatrace/oneagent /opt/dynatrace/oneagent
# ... resto do Dockerfile
ENTRYPOINT ["java", "-agentpath:/opt/dynatrace/oneagent/agent/lib64/liboneagentproc.so", "-jar", "app.jar"]
```

## Limitações Conhecidas
- **Personal Access Tokens** não podem criar outros tokens via API
- Alguns scopes (como `InstallerDownload`) podem não estar disponíveis em contas trial
- O Dynatrace Operator requer múltiplos scopes que podem não estar acessíveis

## Arquivos Relacionados
- `k8s/dynatrace/dynakube.yaml` - Configuração do Operator
- `k8s/dynatrace/README.md` - Documentação do Operator
- `entrypoint.sh` - Script de inicialização (atualmente sem Dynatrace)

## Recursos
- [Dynatrace OneAgent Documentation](https://www.dynatrace.com/support/help/setup-and-configuration/dynatrace-oneagent)
- [API Token Scopes](https://www.dynatrace.com/support/help/dynatrace-api/basics/dynatrace-api-authentication)
- [Operator Installation](https://www.dynatrace.com/support/help/setup-and-configuration/setup-on-kubernetes)
