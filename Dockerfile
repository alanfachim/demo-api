FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Install curl for downloading Dynatrace agent at runtime
RUN apk add --no-cache curl unzip

COPY --from=build /app/target/*.jar app.jar

# Environment variables for Dynatrace (will be provided by Kubernetes secret)
ENV DT_TENANT=""
ENV DT_API_TOKEN=""

# Entrypoint script to download agent and start app
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]

