# Dockerfile Production Deployment Guide

## Table of Contents
1. [Production-Ready Dockerfile Structure](#production-ready-dockerfile-structure)
2. [Security Hardening](#security-hardening)
3. [Performance Optimization](#performance-optimization)
4. [Monitoring and Observability](#monitoring-and-observability)
5. [CI/CD Integration](#cicd-integration)
6. [Deployment Strategies](#deployment-strategies)

## Production-Ready Dockerfile Structure

### 1. Complete Production Dockerfile Template
```dockerfile
# syntax=docker/dockerfile:1
# Production-ready Dockerfile template

# Build arguments
ARG NODE_VERSION=18.17.0
ARG ALPINE_VERSION=3.18
ARG BUILD_DATE
ARG VERSION
ARG COMMIT_SHA

# Build stage
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS builder

# Metadata
LABEL maintainer="devops@company.com"
LABEL version="${VERSION}"
LABEL build-date="${BUILD_DATE}"
LABEL commit="${COMMIT_SHA}"
LABEL stage="builder"

# Install build dependencies
RUN apk add --no-cache python3 make g++

# Set working directory
WORKDIR /app

# Copy package files for dependency caching
COPY package*.json ./

# Install dependencies with cache mount
RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production

# Copy source code
COPY . .

# Build application
RUN npm run build

# Test stage
FROM builder AS tester
RUN npm ci  # Install dev dependencies
RUN npm run test
RUN npm run lint
RUN npm audit --audit-level=high

# Production stage
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS production

# Production metadata
LABEL maintainer="devops@company.com"
LABEL version="${VERSION}"
LABEL environment="production"
LABEL security.scan="required"

# Install production dependencies
RUN apk add --no-cache \
    dumb-init \
    ca-certificates \
    && apk upgrade \
    && rm -rf /var/cache/apk/*

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001 -G nodejs

# Set working directory
WORKDIR /app

# Copy built application with proper ownership
COPY --from=builder --chown=nextjs:nodejs /app/dist ./dist
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nextjs:nodejs /app/package.json ./

# Switch to non-root user
USER nextjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Use dumb-init for proper signal handling
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/server.js"]
```

### 2. Multi-Service Production Setup
```dockerfile
# syntax=docker/dockerfile:1
# Multi-service production Dockerfile

# Base stage with common dependencies
FROM alpine:3.18 AS base
RUN apk add --no-cache ca-certificates tzdata
RUN adduser -D -s /bin/sh appuser

# Frontend build
FROM node:18-alpine AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ .
RUN npm run build

# Backend build
FROM golang:1.21-alpine AS backend-builder
WORKDIR /app/backend
COPY backend/go.mod backend/go.sum ./
RUN go mod download
COPY backend/ .
RUN CGO_ENABLED=0 GOOS=linux go build -o server .

# Production frontend
FROM nginx:alpine AS frontend-production
COPY --from=frontend-builder /app/frontend/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

# Production backend
FROM base AS backend-production
COPY --from=backend-builder /app/backend/server /usr/local/bin/
USER appuser
EXPOSE 8080
CMD ["server"]
```

## Security Hardening

### 1. Security-First Dockerfile
```dockerfile
# syntax=docker/dockerfile:1
FROM alpine:3.18.4  # Use specific patch version

# Security labels
LABEL security.policy="strict"
LABEL security.scan="enabled"
LABEL security.compliance="cis-docker-benchmark"

# Update packages and install security updates
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
    ca-certificates \
    && rm -rf /var/cache/apk/*

# Create non-root user with specific UID/GID
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup -h /app -s /bin/sh

# Set secure working directory
WORKDIR /app

# Copy application with proper ownership
COPY --chown=appuser:appgroup --chmod=755 app /app/
COPY --chown=appuser:appgroup --chmod=644 config.json /app/

# Remove unnecessary packages and files
RUN rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

# Switch to non-root user
USER appuser

# Use read-only root filesystem
LABEL security.readonly-root="true"

# Security context requirements
LABEL security.runAsNonRoot="true"
LABEL security.runAsUser="1001"
LABEL security.allowPrivilegeEscalation="false"
LABEL security.capabilities.drop="ALL"

# Minimal port exposure
EXPOSE 8080

# Health check with security validation
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD ./health-check.sh || exit 1

CMD ["./app"]
```

### 2. Secrets Management
```dockerfile
# syntax=docker/dockerfile:1
FROM alpine:3.18

# Use build secrets for sensitive operations
RUN --mount=type=secret,id=github_token \
    --mount=type=secret,id=npm_token \
    GITHUB_TOKEN=$(cat /run/secrets/github_token) && \
    NPM_TOKEN=$(cat /run/secrets/npm_token) && \
    git clone https://${GITHUB_TOKEN}@github.com/private/repo.git && \
    npm config set //registry.npmjs.org/:_authToken ${NPM_TOKEN} && \
    npm install

# Runtime secrets via files (not environment variables)
ENV API_KEY_FILE=/run/secrets/api_key
ENV DATABASE_PASSWORD_FILE=/run/secrets/db_password
ENV JWT_SECRET_FILE=/run/secrets/jwt_secret

# Validate secrets on startup
COPY validate-secrets.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/validate-secrets.sh

ENTRYPOINT ["/usr/local/bin/validate-secrets.sh"]
CMD ["./app"]
```

## Performance Optimization

### 1. High-Performance Production Build
```dockerfile
# syntax=docker/dockerfile:1
FROM golang:1.21-alpine AS builder

# Performance build flags
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64

WORKDIR /app

# Cache dependencies
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

# Build with optimizations
COPY . .
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go build -ldflags="-s -w -X main.version=${VERSION}" -o app .

# Compress binary (optional)
RUN apk add --no-cache upx && upx --best app

# Minimal production image
FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /app/app /app
USER 1001
EXPOSE 8080
ENTRYPOINT ["/app"]
```

### 2. Node.js Performance Optimization
```dockerfile
FROM node:18-alpine AS builder

# Build-time performance
ENV NODE_OPTIONS="--max-old-space-size=4096"
WORKDIR /app

# Optimize dependency installation
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --prefer-offline --no-audit --no-fund

COPY . .
RUN npm run build

# Production stage with performance tuning
FROM node:18-alpine AS production

# Runtime performance environment
ENV NODE_ENV=production
ENV NODE_OPTIONS="--max-old-space-size=1024 --optimize-for-size"
ENV UV_THREADPOOL_SIZE=4

# Install PM2 for production process management
RUN npm install -g pm2

WORKDIR /app

# Copy optimized build
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY ecosystem.config.js ./

# Non-root user
RUN adduser -D appuser
USER appuser

EXPOSE 3000

# Use PM2 for clustering and monitoring
CMD ["pm2-runtime", "start", "ecosystem.config.js"]
```

## Monitoring and Observability

### 1. Observability-Ready Dockerfile
```dockerfile
FROM alpine:3.18

# Install monitoring tools
RUN apk add --no-cache \
    curl \
    wget \
    procps \
    htop

# Application with metrics
COPY app /usr/local/bin/
COPY metrics-exporter /usr/local/bin/

# Monitoring configuration
ENV METRICS_PORT=9090
ENV HEALTH_CHECK_PORT=8081
ENV LOG_LEVEL=info
ENV LOG_FORMAT=json

# Expose monitoring ports
EXPOSE 8080 9090 8081

# Monitoring labels
LABEL monitoring.metrics.port="9090"
LABEL monitoring.metrics.path="/metrics"
LABEL monitoring.health.port="8081"
LABEL monitoring.health.path="/health"
LABEL monitoring.logs.format="json"

# Health check with detailed monitoring
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8081/health || exit 1

# Startup script with monitoring
COPY start-with-monitoring.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start-with-monitoring.sh

CMD ["/usr/local/bin/start-with-monitoring.sh"]
```

### 2. Logging and Tracing
```dockerfile
FROM alpine:3.18

# Structured logging setup
ENV LOG_LEVEL=info
ENV LOG_FORMAT=json
ENV LOG_OUTPUT=stdout

# Tracing configuration
ENV JAEGER_AGENT_HOST=jaeger
ENV JAEGER_AGENT_PORT=6831
ENV JAEGER_SERVICE_NAME=myapp

# APM configuration
ENV NEW_RELIC_LICENSE_KEY_FILE=/run/secrets/newrelic_key
ENV DATADOG_API_KEY_FILE=/run/secrets/datadog_key

# Log rotation (if needed)
RUN apk add --no-cache logrotate
COPY logrotate.conf /etc/logrotate.d/app

# Application with observability
COPY app /usr/local/bin/
COPY observability-init.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/observability-init.sh

ENTRYPOINT ["/usr/local/bin/observability-init.sh"]
CMD ["app"]
```

## CI/CD Integration

### 1. CI/CD Optimized Dockerfile
```dockerfile
# syntax=docker/dockerfile:1
# CI/CD optimized Dockerfile

# Build arguments from CI/CD pipeline
ARG BUILD_NUMBER
ARG BRANCH_NAME
ARG COMMIT_SHA
ARG BUILD_DATE
ARG VERSION

FROM node:18-alpine AS base

# CI/CD metadata
LABEL ci.build-number="${BUILD_NUMBER}"
LABEL ci.branch="${BRANCH_NAME}"
LABEL ci.commit="${COMMIT_SHA}"
LABEL ci.build-date="${BUILD_DATE}"
LABEL ci.version="${VERSION}"

# Dependencies stage (cached in CI/CD)
FROM base AS dependencies
WORKDIR /app
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm,sharing=locked \
    npm ci

# Build stage
FROM dependencies AS builder
COPY . .
RUN npm run build

# Test stage (parallel in CI/CD)
FROM dependencies AS tester
COPY . .
RUN npm run test:ci
RUN npm run lint
RUN npm audit --audit-level=high

# Security scan stage
FROM builder AS security-scan
RUN npm audit --audit-level=critical
COPY --from=aquasec/trivy:latest /usr/local/bin/trivy /usr/local/bin/
RUN trivy fs --exit-code 1 --severity HIGH,CRITICAL .

# Production stage
FROM node:18-alpine AS production
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=dependencies /app/node_modules ./node_modules

# Runtime metadata
LABEL version="${VERSION}"
LABEL commit="${COMMIT_SHA}"
LABEL build-date="${BUILD_DATE}"

USER 1001
EXPOSE 3000
CMD ["node", "dist/server.js"]
```

### 2. Multi-Environment Build
```dockerfile
# syntax=docker/dockerfile:1
ARG ENVIRONMENT=production
ARG BUILD_TARGET=production

FROM node:18-alpine AS base
WORKDIR /app

# Development configuration
FROM base AS development
ENV NODE_ENV=development
ENV DEBUG=true
ENV LOG_LEVEL=debug
COPY package*.json ./
RUN npm install  # Include dev dependencies
COPY . .
CMD ["npm", "run", "dev"]

# Staging configuration
FROM base AS staging
ENV NODE_ENV=staging
ENV DEBUG=false
ENV LOG_LEVEL=info
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build
CMD ["npm", "start"]

# Production configuration
FROM base AS production
ENV NODE_ENV=production
ENV DEBUG=false
ENV LOG_LEVEL=warn
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build
USER 1001
CMD ["npm", "start"]

# Final stage selection
FROM ${BUILD_TARGET} AS final
```

## Deployment Strategies

### 1. Blue-Green Deployment Ready
```dockerfile
FROM alpine:3.18

# Deployment metadata
LABEL deployment.strategy="blue-green"
LABEL deployment.health-check="required"
LABEL deployment.graceful-shutdown="30s"

# Application
COPY app /usr/local/bin/
COPY health-check.sh /usr/local/bin/
COPY graceful-shutdown.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*

# Health check for deployment validation
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=5 \
    CMD /usr/local/bin/health-check.sh || exit 1

# Graceful shutdown handling
STOPSIGNAL SIGTERM

# Deployment configuration
ENV DEPLOYMENT_TIMEOUT=30
ENV HEALTH_CHECK_TIMEOUT=5
ENV READINESS_PROBE_DELAY=10

EXPOSE 8080
CMD ["/usr/local/bin/app"]
```

### 2. Rolling Update Compatible
```dockerfile
FROM alpine:3.18

# Rolling update configuration
LABEL deployment.strategy="rolling-update"
LABEL deployment.max-unavailable="25%"
LABEL deployment.max-surge="25%"

# Application with zero-downtime support
COPY app /usr/local/bin/
COPY prestart.sh /usr/local/bin/
COPY prestop.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*

# Readiness and liveness probes
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/health/live || exit 1

# Readiness probe endpoint
LABEL health.readiness="/health/ready"
LABEL health.liveness="/health/live"

# Graceful shutdown
ENV SHUTDOWN_TIMEOUT=30
STOPSIGNAL SIGTERM

# Pre-start initialization
ENTRYPOINT ["/usr/local/bin/prestart.sh"]
CMD ["/usr/local/bin/app"]
```

### 3. Canary Deployment Support
```dockerfile
FROM alpine:3.18

# Canary deployment metadata
LABEL deployment.strategy="canary"
LABEL deployment.canary-weight="10"
LABEL deployment.success-threshold="95"

# Feature flags for canary testing
ENV FEATURE_FLAGS_ENDPOINT=http://feature-flags:8080
ENV CANARY_ENABLED=true
ENV METRICS_DETAILED=true

# Enhanced monitoring for canary
ENV METRICS_PORT=9090
ENV TRACES_PORT=9091
EXPOSE 8080 9090 9091

# Application with canary support
COPY app /usr/local/bin/
COPY canary-metrics.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*

# Detailed health checks for canary validation
HEALTHCHECK --interval=15s --timeout=3s --start-period=30s --retries=2 \
    CMD /usr/local/bin/canary-metrics.sh || exit 1

CMD ["/usr/local/bin/app"]
```

## Production Checklist

### Security Checklist
- [ ] Non-root user configured
- [ ] Specific image tags used
- [ ] Secrets handled securely
- [ ] Security scanning enabled
- [ ] Minimal attack surface
- [ ] Read-only root filesystem
- [ ] Capabilities dropped

### Performance Checklist
- [ ] Multi-stage builds used
- [ ] Image size optimized
- [ ] Layer caching optimized
- [ ] Runtime performance tuned
- [ ] Resource limits documented
- [ ] Health checks implemented

### Monitoring Checklist
- [ ] Structured logging configured
- [ ] Metrics endpoints exposed
- [ ] Health checks comprehensive
- [ ] Tracing enabled
- [ ] Error handling robust
- [ ] Graceful shutdown implemented

### Deployment Checklist
- [ ] CI/CD integration complete
- [ ] Environment-specific configs
- [ ] Deployment strategy defined
- [ ] Rollback plan available
- [ ] Monitoring alerts configured
- [ ] Documentation updated

This comprehensive production deployment guide ensures your Dockerfiles are ready for enterprise-grade deployments with security, performance, and reliability built-in.
