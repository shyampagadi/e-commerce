# Dockerfile Real-World Examples

## Table of Contents
1. [Web Applications](#web-applications)
2. [Microservices](#microservices)
3. [Databases](#databases)
4. [Machine Learning Applications](#machine-learning-applications)
5. [DevOps Tools](#devops-tools)
6. [Enterprise Applications](#enterprise-applications)

## Web Applications

### 1. React Frontend Application
```dockerfile
# syntax=docker/dockerfile:1
# React production build with Nginx

# Build stage
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files for better caching
COPY package*.json ./

# Install dependencies with cache mount
RUN --mount=type=cache,target=/root/.npm \
    npm ci --prefer-offline

# Copy source code
COPY public/ ./public/
COPY src/ ./src/
COPY *.json *.js ./

# Build for production
RUN npm run build

# Production stage with Nginx
FROM nginx:alpine AS production

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

# Copy built React app
COPY --from=builder /app/build /usr/share/nginx/html

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Expose port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
```

**nginx.conf:**
```nginx
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    gzip on;
    gzip_types text/plain text/css application/json application/javascript;
    
    server {
        listen 80;
        root /usr/share/nginx/html;
        index index.html;
        
        location / {
            try_files $uri $uri/ /index.html;
        }
        
        location /health {
            access_log off;
            return 200 "healthy\n";
        }
    }
}
```

### 2. Node.js Express API
```dockerfile
# syntax=docker/dockerfile:1
# Node.js Express API with PM2

FROM node:18-alpine AS base

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create app directory and user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001 -G nodejs

WORKDIR /app

# Dependencies stage
FROM base AS dependencies
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production

# Development dependencies for building
FROM base AS dev-dependencies
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci

# Build stage
FROM dev-dependencies AS builder
COPY . .
RUN npm run build

# Test stage
FROM dev-dependencies AS tester
COPY . .
RUN npm run test
RUN npm run lint

# Production stage
FROM base AS production

# Install PM2 globally
RUN npm install -g pm2

# Copy production dependencies
COPY --from=dependencies --chown=nextjs:nodejs /app/node_modules ./node_modules

# Copy built application
COPY --from=builder --chown=nextjs:nodejs /app/dist ./dist
COPY --from=builder --chown=nextjs:nodejs /app/package.json ./

# Copy PM2 configuration
COPY ecosystem.config.js ./

# Switch to non-root user
USER nextjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Use dumb-init and PM2
ENTRYPOINT ["dumb-init", "--"]
CMD ["pm2-runtime", "start", "ecosystem.config.js"]
```

**ecosystem.config.js:**
```javascript
module.exports = {
  apps: [{
    name: 'api',
    script: './dist/server.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: '/dev/stderr',
    out_file: '/dev/stdout',
    log_file: '/dev/stdout',
    time: true
  }]
};
```

### 3. Full-Stack MEAN Application
```dockerfile
# syntax=docker/dockerfile:1
# MEAN stack application

# Frontend build
FROM node:18-alpine AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ .
RUN npm run build

# Backend build
FROM node:18-alpine AS backend-builder
WORKDIR /app/backend
COPY backend/package*.json ./
RUN npm ci --only=production
COPY backend/ .

# Production stage
FROM node:18-alpine AS production

# Install runtime dependencies
RUN apk add --no-cache dumb-init nginx

# Create user
RUN adduser -D -s /bin/sh appuser

# Setup Nginx for frontend
COPY --from=frontend-builder /app/frontend/dist /usr/share/nginx/html
COPY nginx-fullstack.conf /etc/nginx/nginx.conf

# Setup backend
WORKDIR /app
COPY --from=backend-builder /app/backend ./
RUN chown -R appuser:appuser /app

# Startup script
COPY start-fullstack.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start-fullstack.sh

EXPOSE 80 3000

ENTRYPOINT ["dumb-init", "--"]
CMD ["/usr/local/bin/start-fullstack.sh"]
```

## Microservices

### 1. Go Microservice
```dockerfile
# syntax=docker/dockerfile:1
# Go microservice with health checks and metrics

# Build stage
FROM golang:1.21-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git ca-certificates

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies with cache
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

# Copy source code
COPY . .

# Build with optimizations
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=linux go build \
    -ldflags="-s -w -X main.version=${VERSION:-dev}" \
    -o service ./cmd/service

# Production stage
FROM scratch

# Copy CA certificates for HTTPS
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copy binary
COPY --from=builder /app/service /service

# Use non-root user
USER 1001

# Expose ports
EXPOSE 8080 9090

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD ["/service", "healthcheck"]

ENTRYPOINT ["/service"]
```

### 2. Java Spring Boot Microservice
```dockerfile
# syntax=docker/dockerfile:1
# Spring Boot microservice

# Build stage
FROM maven:3.9-openjdk-17 AS builder

WORKDIR /app

# Copy pom.xml for dependency caching
COPY pom.xml .

# Download dependencies
RUN --mount=type=cache,target=/root/.m2 \
    mvn dependency:go-offline -B

# Copy source and build
COPY src ./src
RUN --mount=type=cache,target=/root/.m2 \
    mvn clean package -DskipTests -B

# Production stage
FROM openjdk:17-jre-slim AS production

# Install curl for health checks
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Create user
RUN groupadd -r spring && useradd -r -g spring spring

WORKDIR /app

# Copy JAR file
COPY --from=builder /app/target/*.jar app.jar

# Change ownership
RUN chown spring:spring app.jar

# Switch to non-root user
USER spring

# JVM optimization
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Expose ports
EXPOSE 8080 8081

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8081/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

### 3. Python FastAPI Microservice
```dockerfile
# syntax=docker/dockerfile:1
# FastAPI microservice with async support

# Build stage
FROM python:3.11-slim AS builder

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements for caching
COPY requirements.txt .

# Install Python dependencies
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY . .

# Production stage
FROM python:3.11-slim AS production

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create user
RUN groupadd -r fastapi && useradd -r -g fastapi fastapi

WORKDIR /app

# Copy installed packages
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy application
COPY --chown=fastapi:fastapi . .

# Switch to non-root user
USER fastapi

# Python optimization
ENV PYTHONOPTIMIZE=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Use Gunicorn with async workers
CMD ["gunicorn", "main:app", "-w", "4", "-k", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8000"]
```

## Databases

### 1. PostgreSQL with Custom Configuration
```dockerfile
# syntax=docker/dockerfile:1
# PostgreSQL with custom configuration and backup

FROM postgres:15-alpine

# Install additional tools
RUN apk add --no-cache \
    curl \
    pg_cron \
    postgresql-contrib

# Copy custom configuration
COPY postgresql.conf /etc/postgresql/postgresql.conf
COPY pg_hba.conf /etc/postgresql/pg_hba.conf

# Copy initialization scripts
COPY init-scripts/ /docker-entrypoint-initdb.d/

# Copy backup script
COPY backup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/backup.sh

# Create backup directory
RUN mkdir -p /backup && chown postgres:postgres /backup

# Volumes for data persistence
VOLUME ["/var/lib/postgresql/data", "/backup"]

# Environment variables
ENV POSTGRES_DB=myapp
ENV POSTGRES_USER=myapp
ENV POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD pg_isready -U $POSTGRES_USER -d $POSTGRES_DB || exit 1

# Expose port
EXPOSE 5432

# Custom entrypoint for additional setup
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
```

### 2. Redis with Persistence
```dockerfile
# syntax=docker/dockerfile:1
# Redis with custom configuration and persistence

FROM redis:7-alpine

# Install additional tools
RUN apk add --no-cache curl

# Copy Redis configuration
COPY redis.conf /etc/redis/redis.conf

# Create data directory
RUN mkdir -p /data && chown redis:redis /data

# Copy health check script
COPY redis-health.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/redis-health.sh

# Volume for persistence
VOLUME ["/data"]

# Switch to redis user
USER redis

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD /usr/local/bin/redis-health.sh || exit 1

# Expose port
EXPOSE 6379

CMD ["redis-server", "/etc/redis/redis.conf"]
```

## Machine Learning Applications

### 1. TensorFlow Serving
```dockerfile
# syntax=docker/dockerfile:1
# TensorFlow Serving with custom model

FROM tensorflow/serving:latest

# Copy model
COPY models/ /models/

# Environment variables
ENV MODEL_NAME=my_model
ENV MODEL_BASE_PATH=/models

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8501/v1/models/${MODEL_NAME} || exit 1

# Expose ports
EXPOSE 8500 8501

CMD ["/usr/bin/tf_serving_entrypoint.sh"]
```

### 2. PyTorch Model Server
```dockerfile
# syntax=docker/dockerfile:1
# PyTorch model serving

FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir -r requirements.txt

# Copy model and application
COPY models/ ./models/
COPY src/ ./src/
COPY main.py .

# Create user
RUN groupadd -r ml && useradd -r -g ml ml
RUN chown -R ml:ml /app
USER ml

# Environment variables
ENV MODEL_PATH=/app/models/model.pth
ENV WORKERS=4

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

CMD ["gunicorn", "main:app", "-w", "4", "--bind", "0.0.0.0:8000"]
```

## DevOps Tools

### 1. Jenkins Agent
```dockerfile
# syntax=docker/dockerfile:1
# Jenkins agent with Docker and tools

FROM jenkins/inbound-agent:latest

# Switch to root for installations
USER root

# Install Docker
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# Install additional tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    make \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Add jenkins user to docker group
RUN usermod -aG docker jenkins

# Switch back to jenkins user
USER jenkins

# Health check
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD pgrep -f "jenkins-agent" || exit 1
```

### 2. Monitoring Stack (Prometheus)
```dockerfile
# syntax=docker/dockerfile:1
# Prometheus with custom configuration

FROM prom/prometheus:latest

# Copy configuration files
COPY prometheus.yml /etc/prometheus/
COPY alert.rules /etc/prometheus/rules/
COPY recording.rules /etc/prometheus/rules/

# Copy web configuration for authentication
COPY web.yml /etc/prometheus/

# Create storage directory
USER root
RUN mkdir -p /prometheus-data && chown nobody:nobody /prometheus-data
USER nobody

# Volume for data
VOLUME ["/prometheus-data"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:9090/-/healthy || exit 1

# Expose port
EXPOSE 9090

CMD ["--config.file=/etc/prometheus/prometheus.yml", \
     "--storage.tsdb.path=/prometheus-data", \
     "--web.console.libraries=/etc/prometheus/console_libraries", \
     "--web.console.templates=/etc/prometheus/consoles", \
     "--storage.tsdb.retention.time=30d", \
     "--web.enable-lifecycle", \
     "--web.config.file=/etc/prometheus/web.yml"]
```

## Enterprise Applications

### 1. Enterprise Java Application
```dockerfile
# syntax=docker/dockerfile:1
# Enterprise Java application with security and monitoring

# Build stage
FROM maven:3.9-openjdk-17 AS builder

WORKDIR /app

# Copy Maven files
COPY pom.xml .
COPY .mvn/ .mvn/

# Download dependencies
RUN --mount=type=cache,target=/root/.m2 \
    mvn dependency:go-offline -B

# Copy source and build
COPY src/ ./src/
RUN --mount=type=cache,target=/root/.m2 \
    mvn clean package -DskipTests -B

# Security scan stage
FROM builder AS security-scan
RUN --mount=type=cache,target=/root/.m2 \
    mvn org.owasp:dependency-check-maven:check

# Production stage
FROM openjdk:17-jre-slim AS production

# Install security updates and tools
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Create application user
RUN groupadd -r appgroup && \
    useradd -r -g appgroup -d /app -s /sbin/nologin appuser

WORKDIR /app

# Copy JAR file
COPY --from=builder --chown=appuser:appgroup /app/target/*.jar app.jar

# Copy configuration files
COPY --chown=appuser:appgroup config/ ./config/
COPY --chown=appuser:appgroup scripts/ ./scripts/
RUN chmod +x ./scripts/*.sh

# Switch to application user
USER appuser

# JVM configuration for production
ENV JAVA_OPTS="-server \
    -XX:+UseContainerSupport \
    -XX:MaxRAMPercentage=75.0 \
    -XX:+UseG1GC \
    -XX:+UseStringDeduplication \
    -Djava.security.egd=file:/dev/./urandom"

# Application configuration
ENV SPRING_PROFILES_ACTIVE=production
ENV MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=health,metrics,prometheus

# Expose ports
EXPOSE 8080 8081

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8081/actuator/health || exit 1

# Graceful shutdown
STOPSIGNAL SIGTERM

ENTRYPOINT ["./scripts/entrypoint.sh"]
CMD ["java", "-jar", "app.jar"]
```

### 2. .NET Core Enterprise Application
```dockerfile
# syntax=docker/dockerfile:1
# .NET Core enterprise application

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS builder

WORKDIR /app

# Copy project files
COPY *.sln .
COPY src/ ./src/

# Restore dependencies
RUN dotnet restore

# Build application
RUN dotnet build -c Release --no-restore

# Test stage
FROM builder AS tester
RUN dotnet test --no-build -c Release --logger trx --results-directory /testresults

# Publish stage
FROM builder AS publisher
RUN dotnet publish src/MyApp/MyApp.csproj -c Release -o /app/publish --no-restore

# Production stage
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS production

# Install security updates
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Create user
RUN groupadd -r dotnet && useradd -r -g dotnet dotnet

WORKDIR /app

# Copy published application
COPY --from=publisher --chown=dotnet:dotnet /app/publish .

# Switch to non-root user
USER dotnet

# .NET configuration
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:8080
ENV DOTNET_RUNNING_IN_CONTAINER=true
ENV DOTNET_USE_POLLING_FILE_WATCHER=true

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["dotnet", "MyApp.dll"]
```

These real-world examples demonstrate production-ready Dockerfiles for various application types, incorporating security best practices, performance optimizations, and proper monitoring configurations.
