# Configuração do Dynatrace - Trial Account Limitations

## Status Atual
✅ Aplicação funcionando perfeitamente (v1.0.3)  
✅ CI/CD totalmente automatizado (GitHub Actions → Docker Hub → ArgoCD)  
✅ 3 réplicas rodando em Kubernetes  
❌ Dynatrace OneAgent **não instalado** (limitações de conta trial)

## Problema Identificado
**A conta trial do Dynatrace NÃO suporta download automatizado do OneAgent via API.**

### Confirmado após múltiplas tentativas:
1. ✅ Login bem-sucedido no Dynatrace (alanfachimbr@gmail.com)
2. ❌ API retorna **403 Forbidden** ao tentar baixar OneAgent
3. ❌ Tokens existentes são **Personal Access Tokens** (PAT)
4. ❌ PATs não têm scope `InstallerDownload` disponível
5. ❌ Contas trial não podem criar API tokens com scopes v1 necessários

```bash
# Teste realizado:
curl -I "https://zrp88793.live.dynatrace.com/api/v1/deployment/installer/agent/unix/paas/latest?Api-Token=..."
# Resultado: HTTP/1.1 403 Forbidden
```

### Limitações de Conta Trial:
- ❌ Não permite criar tokens com scope `InstallerDownload`
- ❌ Não permite criar tokens com scope `DataExport`  
- ❌ Não permite criar tokens com scope `activeGateTokenManagement.create`
- ❌ Dynatrace Operator requer esses scopes - não funciona em trial
- ⚠️ Apenas 14 dias de trial restantes

## Soluções Alternativas

### Opção 1: Upgrade para Conta Paga ⭐ RECOMENDADO
A maneira correta e suportada é fazer upgrade da conta para ter acesso completo aos API tokens:
1. Acesse Dynatrace e faça upgrade da conta trial
2. Após upgrade, gere API token com scopes:
   - `InstallerDownload`
   - `DataExport`
   - `metrics.ingest`
   - `activeGateTokenManagement.create`
3. Atualize o secret: `kubectl create secret generic dynatrace-config -n demo-api ...`
4. Faça rebuild da aplicação

### Opção 2: OpenTelemetry (Alternativa Gratuita) ⭐ MELHOR ALTERNATIVA
Usar OpenTelemetry + Jaeger/Prometheus como alternativa open-source:

```yaml
# Adicionar dependências no pom.xml
<dependency>
    <groupId>io.opentelemetry.instrumentation</groupId>
    <artifactId>opentelemetry-spring-boot-starter</artifactId>
</dependency>
```

**Vantagens:**
- ✅ 100% gratuito e open-source
- ✅ Sem limitações de trial
- ✅ Funciona em qualquer ambiente
- ✅ Vendor-neutral (pode migrar para Dynatrace depois)

### Opção 3: Manual OneAgent Download (Workaround Temporário)
Se tiver acesso à UI do Dynatrace, pode baixar manualmente:
1. Acesse Deploy Dynatrace → Linux
2. Baixe o `oneagent-unix.sh` manualmente
3. Adicione ao Docker image durante build
4. Modifique Dockerfile para copiar o arquivo local

## Conclusão e Recomendação

**Para Produção:** Recomendo **OpenTelemetry** como solução de observabilidade. É gratuito, maduro e amplamente adotado.

**Setup Atual:**
- ✅ Minikube rodando
- ✅ ArgoCD configurado (GitOps)
- ✅ CI/CD automatizado
- ✅ Aplicação funcionando perfeitamente
- ✅ 3 réplicas em alta disponibilidade

**O que já funciona:**
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
