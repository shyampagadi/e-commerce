# Advanced Multi-Stage Builds Mastery

## Table of Contents
1. [Multi-Stage Build Fundamentals](#multi-stage-build-fundamentals)
2. [Advanced Patterns](#advanced-patterns)
3. [Build Optimization Techniques](#build-optimization-techniques)
4. [Real-World Examples](#real-world-examples)
5. [Performance Analysis](#performance-analysis)
6. [Troubleshooting](#troubleshooting)

## Multi-Stage Build Fundamentals

### Basic Multi-Stage Structure
```dockerfile
# Stage 1: Build environment
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Production environment
FROM nginx:alpine AS production
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Named Stages Benefits
```dockerfile
# Named stages for clarity
FROM golang:1.21-alpine AS dependencies
FROM golang:1.21-alpine AS builder
FROM golang:1.21-alpine AS tester
FROM alpine:3.18 AS production
```

### Stage Targeting
```bash
# Build specific stage
docker build --target builder -t myapp:builder .
docker build --target production -t myapp:prod .
```

## Advanced Patterns

### 1. Parallel Build Stages
```dockerfile
# Base stage with common dependencies
FROM node:18-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm ci

# Development dependencies
FROM base AS dev-deps
RUN npm ci --include=dev

# Production dependencies
FROM base AS prod-deps
RUN npm ci --only=production

# Build stage
FROM dev-deps AS builder
COPY . .
RUN npm run build
RUN npm run test

# Production stage
FROM prod-deps AS production
COPY --from=builder /app/dist ./dist
CMD ["npm", "start"]
```

### 2. Multi-Architecture Builds
```dockerfile
# syntax=docker/dockerfile:1
FROM --platform=$BUILDPLATFORM node:18-alpine AS builder
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "Building on $BUILDPLATFORM for $TARGETPLATFORM"

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM --platform=$TARGETPLATFORM alpine:3.18 AS production
COPY --from=builder /app/dist /app
CMD ["/app/server"]
```

### 3. Conditional Stages
```dockerfile
FROM alpine:3.18 AS base
ARG BUILD_ENV=production

# Development stage
FROM base AS development
RUN apk add --no-cache curl vim
COPY . /app

# Production stage  
FROM base AS production
COPY --from=builder /app/dist /app

# Final stage selection
FROM ${BUILD_ENV} AS final
```

## Build Optimization Techniques

### 1. Cache Mount Optimization
```dockerfile
FROM node:18-alpine AS builder

# Cache npm packages
RUN --mount=type=cache,target=/root/.npm \
    --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    npm ci

COPY . .
RUN npm run build

FROM nginx:alpine AS production
COPY --from=builder /app/dist /usr/share/nginx/html
```

### 2. Shared Base Optimization
```dockerfile
# Shared base for multiple services
FROM node:18-alpine AS node-base
RUN apk add --no-cache python3 make g++
WORKDIR /app

# Frontend build
FROM node-base AS frontend-builder
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ .
RUN npm run build

# Backend build
FROM node-base AS backend-builder
COPY backend/package*.json ./
RUN npm ci
COPY backend/ .
RUN npm run build

# Production images
FROM nginx:alpine AS frontend
COPY --from=frontend-builder /app/dist /usr/share/nginx/html

FROM node:18-alpine AS backend
COPY --from=backend-builder /app/dist ./
CMD ["node", "server.js"]
```

### 3. Build Context Optimization
```dockerfile
# syntax=docker/dockerfile:1
FROM alpine:3.18 AS base

# Use bind mounts to avoid copying large files
RUN --mount=type=bind,source=.,target=/src \
    --mount=type=cache,target=/cache \
    cd /src && \
    make build CACHE_DIR=/cache

FROM scratch AS export
COPY --from=base /src/output /
```

## Real-World Examples

### 1. Go Application with Testing
```dockerfile
# syntax=docker/dockerfile:1
FROM golang:1.21-alpine AS base
WORKDIR /app
RUN apk add --no-cache git ca-certificates

# Dependencies stage
FROM base AS deps
COPY go.mod go.sum ./
RUN go mod download

# Build stage
FROM deps AS builder
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# Test stage
FROM deps AS tester
COPY . .
RUN go test -v ./...
RUN go vet ./...

# Security scan stage
FROM builder AS security
RUN go install github.com/securecodewarrior/gosec/v2/cmd/gosec@latest
RUN gosec ./...

# Production stage
FROM scratch AS production
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /app/main /main
EXPOSE 8080
USER 1001
ENTRYPOINT ["/main"]
```

### 2. Python Application with ML Dependencies
```dockerfile
FROM python:3.11-slim AS base
RUN apt-get update && apt-get install -y \
    gcc g++ \
    && rm -rf /var/lib/apt/lists/*

# Dependencies compilation
FROM base AS deps-builder
COPY requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /wheels -r requirements.txt

# Application builder
FROM base AS app-builder
COPY --from=deps-builder /wheels /wheels
RUN pip install --no-cache /wheels/*
COPY . .
RUN python -m compileall .

# Testing stage
FROM app-builder AS tester
RUN pip install pytest pytest-cov
RUN pytest --cov=app tests/

# Production stage
FROM python:3.11-slim AS production
RUN groupadd -r app && useradd -r -g app app
COPY --from=app-builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=app-builder /app /app
WORKDIR /app
USER app
CMD ["python", "main.py"]
```

### 3. Full-Stack Application
```dockerfile
# Frontend build
FROM node:18-alpine AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ .
RUN npm run build

# Backend build
FROM maven:3.9-openjdk-17 AS backend-builder
WORKDIR /app/backend
COPY backend/pom.xml .
RUN mvn dependency:go-offline
COPY backend/src ./src
RUN mvn clean package -DskipTests

# Database migrations
FROM flyway/flyway:9-alpine AS migrations
COPY database/migrations /flyway/sql

# Production backend
FROM openjdk:17-jre-slim AS backend
RUN groupadd -r app && useradd -r -g app app
COPY --from=backend-builder /app/backend/target/*.jar app.jar
USER app
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]

# Production frontend
FROM nginx:alpine AS frontend
COPY --from=frontend-builder /app/frontend/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
```

## Performance Analysis

### Size Comparison Example
```dockerfile
# Single-stage (larger image)
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build
CMD ["npm", "start"]
# Result: ~1.2GB

# Multi-stage (optimized)
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine AS production
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
CMD ["npm", "start"]
# Result: ~200MB (83% reduction)
```

### Build Time Optimization
```dockerfile
# Parallel builds with BuildKit
FROM alpine:3.18 AS base

# These stages can build in parallel
FROM base AS stage1
RUN sleep 10 && echo "Stage 1 complete"

FROM base AS stage2  
RUN sleep 10 && echo "Stage 2 complete"

FROM base AS final
COPY --from=stage1 /tmp/stage1 /
COPY --from=stage2 /tmp/stage2 /
```

## Advanced Techniques

### 1. External Stage References
```dockerfile
# Reference external images as stages
FROM myregistry.com/base:latest AS external-base
FROM node:18-alpine AS builder

# Use external stage
COPY --from=external-base /app/tools /tools
```

### 2. Build Arguments in Stages
```dockerfile
ARG BUILD_ENV=production
ARG NODE_VERSION=18

FROM node:${NODE_VERSION}-alpine AS base

FROM base AS development
RUN apk add --no-cache curl vim

FROM base AS production
RUN apk add --no-cache dumb-init

FROM ${BUILD_ENV} AS final
```

### 3. Conditional Copying
```dockerfile
FROM alpine:3.18 AS base
ARG INCLUDE_DOCS=false

FROM base AS docs-builder
COPY docs/ /docs
RUN mkdocs build

FROM base AS final
COPY app/ /app
# Conditionally include docs
COPY --from=docs-builder /docs/site /app/docs
```

## Troubleshooting Multi-Stage Builds

### Common Issues and Solutions

#### 1. Stage Not Found Error
```bash
# Error: failed to solve: stage "builder" not found
# Solution: Ensure stage names are correct
FROM node:18-alpine AS builder  # Correct case
COPY --from=builder /app/dist /  # Must match exactly
```

#### 2. File Not Found in Stage
```dockerfile
# Debug by building intermediate stages
docker build --target builder -t debug:builder .
docker run -it debug:builder sh
# Check if files exist in expected locations
```

#### 3. Cache Invalidation Issues
```dockerfile
# Use specific COPY commands to maintain cache
COPY package*.json ./          # Cache layer
RUN npm ci                     # Cached if package.json unchanged
COPY . .                       # Only invalidates if source changes
```

### Debugging Techniques

#### 1. Inspect Intermediate Stages
```bash
# Build and inspect each stage
docker build --target deps -t myapp:deps .
docker run -it myapp:deps sh

docker build --target builder -t myapp:builder .
docker run -it myapp:builder sh
```

#### 2. Use BuildKit for Better Debugging
```bash
# Enable BuildKit for better error messages
export DOCKER_BUILDKIT=1
docker build .

# Use buildx for advanced features
docker buildx build --progress=plain .
```

#### 3. Layer Analysis
```bash
# Analyze image layers
docker history myapp:latest
docker inspect myapp:latest

# Use dive for detailed analysis
dive myapp:latest
```

## Best Practices Summary

### Do's
- ✅ Use specific stage names
- ✅ Order stages by build dependencies
- ✅ Leverage parallel builds
- ✅ Use cache mounts for package managers
- ✅ Copy only necessary files between stages
- ✅ Use minimal base images for production

### Don'ts
- ❌ Don't copy unnecessary files between stages
- ❌ Don't use latest tags in production
- ❌ Don't ignore .dockerignore
- ❌ Don't build everything in final stage
- ❌ Don't forget to clean up build artifacts

### Performance Tips
1. **Minimize stage transitions**: Reduce COPY operations between stages
2. **Use cache mounts**: Leverage BuildKit cache features
3. **Parallel builds**: Structure stages for parallel execution
4. **Selective copying**: Copy only required artifacts
5. **Base image optimization**: Choose appropriate base images per stage

This advanced guide provides comprehensive coverage of multi-stage builds for creating highly optimized, secure, and maintainable Docker images.
