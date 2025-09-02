# Dockerfile Performance Optimization

## Table of Contents
1. [Build Performance](#build-performance)
2. [Runtime Performance](#runtime-performance)
3. [Image Size Optimization](#image-size-optimization)
4. [Layer Caching Strategies](#layer-caching-strategies)
5. [BuildKit Advanced Features](#buildkit-advanced-features)
6. [Performance Monitoring](#performance-monitoring)

## Build Performance

### 1. Optimize Build Context
```dockerfile
# .dockerignore - Reduce build context size
node_modules
.git
*.log
.env
coverage/
.nyc_output
docs/
*.md
.DS_Store
Thumbs.db
```

### 2. Parallel Builds with BuildKit
```dockerfile
# syntax=docker/dockerfile:1
FROM alpine:3.18 AS base

# These stages can build in parallel
FROM base AS frontend-deps
COPY frontend/package*.json ./
RUN npm ci

FROM base AS backend-deps  
COPY backend/requirements.txt ./
RUN pip install -r requirements.txt

# Combine results
FROM base AS final
COPY --from=frontend-deps /node_modules ./frontend/node_modules
COPY --from=backend-deps /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
```

### 3. Cache Mount Optimization
```dockerfile
# syntax=docker/dockerfile:1
FROM node:18-alpine

# Cache npm packages across builds
RUN --mount=type=cache,target=/root/.npm \
    --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    npm ci --prefer-offline

# Cache pip packages
FROM python:3.11-slim
RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=bind,source=requirements.txt,target=requirements.txt \
    pip install -r requirements.txt
```

### 4. Build Argument Optimization
```dockerfile
# Use build args to control build behavior
ARG BUILD_PARALLEL=4
ARG SKIP_TESTS=false
ARG OPTIMIZATION_LEVEL=2

FROM node:18-alpine
RUN npm config set jobs ${BUILD_PARALLEL}

# Conditional test execution
RUN if [ "$SKIP_TESTS" = "false" ]; then npm test; fi

# Optimization level for compilation
ENV OPTIMIZATION_LEVEL=${OPTIMIZATION_LEVEL}
```

## Runtime Performance

### 1. Application Startup Optimization
```dockerfile
FROM openjdk:17-jre-slim

# JVM performance tuning
ENV JAVA_OPTS="-XX:+UseG1GC \
               -XX:+UseStringDeduplication \
               -XX:+OptimizeStringConcat \
               -Xms512m \
               -Xmx1024m \
               -XX:NewRatio=1 \
               -XX:+UnlockExperimentalVMOptions \
               -XX:+UseCGroupMemoryLimitForHeap"

COPY app.jar /app.jar
CMD ["java", "$JAVA_OPTS", "-jar", "/app.jar"]
```

### 2. Node.js Performance Optimization
```dockerfile
FROM node:18-alpine

# Node.js performance environment variables
ENV NODE_ENV=production
ENV NODE_OPTIONS="--max-old-space-size=1024 --optimize-for-size"
ENV UV_THREADPOOL_SIZE=4

# Use PM2 for production
RUN npm install -g pm2
COPY ecosystem.config.js .
CMD ["pm2-runtime", "start", "ecosystem.config.js"]
```

### 3. Python Performance Optimization
```dockerfile
FROM python:3.11-slim

# Python performance optimizations
ENV PYTHONOPTIMIZE=2
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONHASHSEED=random

# Use gunicorn for production
RUN pip install gunicorn[gevent]
CMD ["gunicorn", "--worker-class", "gevent", "--workers", "4", "app:app"]
```

## Image Size Optimization

### 1. Multi-Stage Build for Size Reduction
```dockerfile
# Build stage - larger image with build tools
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage - minimal image
FROM node:18-alpine AS production
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
CMD ["npm", "start"]

# Size comparison:
# Single stage: ~1.2GB
# Multi-stage: ~200MB (83% reduction)
```

### 2. Dependency Optimization
```dockerfile
FROM python:3.11-slim

# Install only production dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --no-compile -r requirements.txt

# Remove unnecessary packages after installation
RUN apt-get purge -y --auto-remove \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*
```

### 3. File System Optimization
```dockerfile
FROM alpine:3.18

# Combine commands to reduce layers
RUN apk add --no-cache \
    python3 \
    py3-pip \
    && pip3 install --no-cache-dir flask \
    && adduser -D appuser \
    && mkdir -p /app \
    && chown appuser:appuser /app

# Clean up in same layer
RUN apk add --no-cache --virtual .build-deps \
    gcc \
    musl-dev \
    && pip3 install --no-cache-dir some-package \
    && apk del .build-deps
```

## Layer Caching Strategies

### 1. Optimal Layer Ordering
```dockerfile
FROM node:18-alpine

# 1. System dependencies (rarely change)
RUN apk add --no-cache python3 make g++

# 2. Package dependencies (change occasionally)
COPY package*.json ./
RUN npm ci --only=production

# 3. Application code (changes frequently)
COPY src/ ./src/
COPY public/ ./public/

# 4. Build step (depends on source)
RUN npm run build
```

### 2. Dependency Layer Separation
```dockerfile
FROM python:3.11-slim

# System packages layer
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Python dependencies layer
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Application layer
COPY . .
```

### 3. Cache Invalidation Control
```dockerfile
# Use specific file patterns for better caching
COPY package.json package-lock.json ./
RUN npm ci

# Copy source files that change frequently last
COPY src/ ./src/
COPY public/ ./public/
COPY *.js *.json ./
```

## BuildKit Advanced Features

### 1. Bind Mounts for Build Context
```dockerfile
# syntax=docker/dockerfile:1
FROM alpine:3.18

# Use bind mount to avoid copying large files
RUN --mount=type=bind,source=.,target=/src \
    --mount=type=cache,target=/cache \
    cd /src && \
    make build CACHE_DIR=/cache && \
    cp output/* /app/
```

### 2. Secret Mounts for Credentials
```dockerfile
# syntax=docker/dockerfile:1
FROM alpine:3.18

# Mount secrets without storing in image
RUN --mount=type=secret,id=github_token \
    --mount=type=secret,id=npm_token \
    GITHUB_TOKEN=$(cat /run/secrets/github_token) \
    NPM_TOKEN=$(cat /run/secrets/npm_token) \
    && git clone https://${GITHUB_TOKEN}@github.com/private/repo.git \
    && npm config set //registry.npmjs.org/:_authToken ${NPM_TOKEN}
```

### 3. SSH Mounts for Git Operations
```dockerfile
# syntax=docker/dockerfile:1
FROM alpine:3.18

RUN apk add --no-cache git openssh-client

# Mount SSH keys for git operations
RUN --mount=type=ssh \
    git clone git@github.com:private/repo.git
```

### 4. Cache Mounts for Package Managers
```dockerfile
# syntax=docker/dockerfile:1

# Go modules cache
FROM golang:1.21-alpine
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

# Maven cache
FROM maven:3.9-openjdk-17
RUN --mount=type=cache,target=/root/.m2 \
    mvn dependency:go-offline

# Gradle cache
FROM gradle:8-jdk17
RUN --mount=type=cache,target=/home/gradle/.gradle \
    gradle build --no-daemon
```

## Performance Monitoring

### 1. Build Performance Metrics
```dockerfile
# Add build metadata for monitoring
ARG BUILD_DATE
ARG BUILD_VERSION
ARG BUILD_COMMIT

LABEL build.date=${BUILD_DATE}
LABEL build.version=${BUILD_VERSION}
LABEL build.commit=${BUILD_COMMIT}
LABEL build.performance.target="<5min"
```

### 2. Runtime Performance Monitoring
```dockerfile
FROM alpine:3.18

# Add performance monitoring tools
RUN apk add --no-cache \
    htop \
    iotop \
    nethogs

# Performance monitoring endpoints
EXPOSE 9090
LABEL monitoring.metrics.port="9090"
LABEL monitoring.metrics.path="/metrics"

# Health check for performance
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8080/health || exit 1
```

### 3. Resource Usage Optimization
```dockerfile
FROM node:18-alpine

# Set resource limits documentation
LABEL resources.cpu.request="100m"
LABEL resources.cpu.limit="500m"
LABEL resources.memory.request="128Mi"
LABEL resources.memory.limit="512Mi"

# Configure application for resource constraints
ENV NODE_OPTIONS="--max-old-space-size=400"
```

## Advanced Optimization Techniques

### 1. Distroless Images for Maximum Efficiency
```dockerfile
# Build stage
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o app .

# Distroless production image
FROM gcr.io/distroless/static-debian11
COPY --from=builder /app/app /app
USER 1001
ENTRYPOINT ["/app"]

# Result: ~2MB final image
```

### 2. Scratch Images for Static Binaries
```dockerfile
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags="-s -w" -o app .

FROM scratch
COPY --from=builder /app/app /app
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
USER 1001
ENTRYPOINT ["/app"]

# Result: <10MB final image
```

### 3. UPX Compression for Binaries
```dockerfile
FROM golang:1.21-alpine AS builder
RUN apk add --no-cache upx
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o app .
RUN upx --best --lzma app

FROM scratch
COPY --from=builder /app/app /app
ENTRYPOINT ["/app"]

# Additional 30-50% size reduction
```

## Performance Testing

### 1. Build Performance Testing
```bash
#!/bin/bash
# build-performance-test.sh

echo "Testing build performance..."

# Clean build
time docker build --no-cache -t myapp:test .

# Cached build
time docker build -t myapp:test .

# Parallel build with BuildKit
DOCKER_BUILDKIT=1 time docker build -t myapp:test .

# Multi-platform build
time docker buildx build --platform linux/amd64,linux/arm64 -t myapp:test .
```

### 2. Runtime Performance Testing
```bash
#!/bin/bash
# runtime-performance-test.sh

# Memory usage test
docker run --rm myapp:test /bin/sh -c "
    echo 'Memory usage:'
    cat /proc/meminfo | grep MemAvailable
    ps aux | head -1
    ps aux | grep -v grep
"

# CPU usage test
docker run --rm --cpus=0.5 myapp:test /bin/sh -c "
    echo 'CPU test with 0.5 CPU limit'
    time dd if=/dev/zero of=/dev/null bs=1M count=100
"

# Startup time test
time docker run --rm myapp:test echo "Container started"
```

### 3. Image Analysis Tools
```bash
# Analyze image layers
docker history myapp:test

# Use dive for detailed analysis
dive myapp:test

# Use docker-slim for optimization suggestions
docker-slim build --target myapp:test --tag myapp:slim

# Security and performance scan
trivy image myapp:test
```

## Performance Best Practices Summary

### Build Optimization
- ✅ Use .dockerignore to reduce build context
- ✅ Leverage BuildKit cache mounts
- ✅ Order layers by change frequency
- ✅ Use parallel builds for independent stages
- ✅ Minimize build context size

### Runtime Optimization
- ✅ Use appropriate base images
- ✅ Configure runtime parameters
- ✅ Implement proper health checks
- ✅ Monitor resource usage
- ✅ Use production-ready process managers

### Size Optimization
- ✅ Use multi-stage builds
- ✅ Choose minimal base images
- ✅ Remove unnecessary files and packages
- ✅ Combine RUN instructions
- ✅ Use distroless or scratch images when possible

### Monitoring
- ✅ Add performance labels and metadata
- ✅ Implement health checks
- ✅ Monitor build and runtime metrics
- ✅ Use performance testing tools
- ✅ Set resource limits and requests

This comprehensive performance guide ensures your Docker images are optimized for both build time and runtime efficiency.
