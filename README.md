# Demo API

API REST simples em Spring Boot configurada com ArgoCD.

## Endpoints

- `GET /api/hello` - Retorna mensagem de boas-vindas
- `GET /api/health` - Health check
- `GET /actuator/health` - Spring Actuator health endpoint

## Executar localmente

```bash
mvn spring-boot:run
```

## Build Docker

```bash
docker build -t demo-api:latest .
```

## Deploy no Kubernetes com ArgoCD

Os manifestos Kubernetes estão no diretório `k8s/`.

## Tecnologias

- Java 17
- Spring Boot 3.2.0
- Maven
- Docker
- Kubernetes
