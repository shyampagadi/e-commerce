# Dockerfile Best Practices & Optimization

## Table of Contents
1. [Image Size Optimization](#image-size-optimization)
2. [Layer Caching Strategies](#layer-caching-strategies)
3. [Security Best Practices](#security-best-practices)
4. [Performance Optimization](#performance-optimization)
5. [Maintainability Guidelines](#maintainability-guidelines)
6. [Production Readiness](#production-readiness)

## Image Size Optimization

### 1. Use Multi-Stage Builds
```dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Production stage
FROM node:18-alpine AS production
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

### 2. Choose Minimal Base Images
```dockerfile
# ❌ Avoid full OS images
FROM ubuntu:20.04

# ✅ Use minimal images
FROM alpine:3.18
FROM node:18-alpine
FROM python:3.11-slim
FROM scratch  # For static binaries
```

### 3. Minimize Layers
```dockerfile
# ❌ Multiple RUN instructions
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y git
RUN apt-get clean

# ✅ Combine commands
RUN apt-get update && \
    apt-get install -y curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

### 4. Use .dockerignore
```dockerignore
# .dockerignore
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.nyc_output
coverage
.nyc_output
.coverage
.pytest_cache
```

## Layer Caching Strategies

### 1. Order Instructions by Change Frequency
```dockerfile
# ✅ Stable layers first
FROM python:3.11-slim

# System dependencies (rarely change)
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Application dependencies (change occasionally)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Application code (changes frequently)
COPY . .

CMD ["python", "app.py"]
```

### 2. Leverage Build Cache
```dockerfile
# Copy dependency files first
COPY package*.json ./
RUN npm ci --only=production

# Copy source code last
COPY src/ ./src/
```

### 3. Use BuildKit Features
```dockerfile
# syntax=docker/dockerfile:1
FROM alpine:3.18

# Mount cache for package managers
RUN --mount=type=cache,target=/var/cache/apk \
    apk add --update python3 py3-pip

# Mount secrets
RUN --mount=type=secret,id=api_key \
    API_KEY=$(cat /run/secrets/api_key) && \
    curl -H "Authorization: Bearer $API_KEY" ...
```

## Security Best Practices

### 1. Run as Non-Root User
```dockerfile
FROM alpine:3.18

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Set ownership
COPY --chown=nextjs:nodejs . .

# Switch to non-root user
USER nextjs

CMD ["node", "server.js"]
```

### 2. Use Specific Image Tags
```dockerfile
# ❌ Avoid latest tag
FROM node:latest

# ✅ Use specific versions
FROM node:18.17.0-alpine3.18
```

### 3. Scan for Vulnerabilities
```dockerfile
# Use minimal base images
FROM alpine:3.18

# Keep packages updated
RUN apk update && apk upgrade

# Remove unnecessary packages
RUN apk del build-dependencies
```

### 4. Handle Secrets Properly
```dockerfile
# ❌ Don't embed secrets
ENV API_KEY=secret123

# ✅ Use build secrets
RUN --mount=type=secret,id=api_key \
    API_KEY=$(cat /run/secrets/api_key) && \
    # Use API_KEY here
```

## Performance Optimization

### 1. Optimize Package Installation
```dockerfile
# Python optimization
RUN pip install --no-cache-dir --compile -r requirements.txt

# Node.js optimization
RUN npm ci --only=production --no-audit --no-fund

# Alpine packages
RUN apk add --no-cache python3 py3-pip
```

### 2. Use Health Checks
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1
```

### 3. Optimize File Operations
```dockerfile
# Use COPY instead of ADD when possible
COPY src/ /app/src/

# Set proper file permissions
COPY --chmod=755 entrypoint.sh /usr/local/bin/
```

## Maintainability Guidelines

### 1. Use Labels for Metadata
```dockerfile
LABEL maintainer="team@company.com"
LABEL version="1.0.0"
LABEL description="Production web application"
LABEL org.opencontainers.image.source="https://github.com/company/app"
LABEL org.opencontainers.image.documentation="https://docs.company.com"
```

### 2. Document Your Dockerfile
```dockerfile
# Build stage for compiling assets
FROM node:18-alpine AS builder

# Install build dependencies
RUN apk add --no-cache python3 make g++

# Set working directory
WORKDIR /app

# Copy package files for dependency installation
COPY package*.json ./

# Install dependencies with cache mount for faster builds
RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production
```

### 3. Use ARG for Build-Time Variables
```dockerfile
ARG NODE_VERSION=18
ARG ALPINE_VERSION=3.18

FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION}

ARG BUILD_DATE
ARG VERSION
ARG COMMIT_SHA

LABEL build-date=$BUILD_DATE
LABEL version=$VERSION
LABEL commit=$COMMIT_SHA
```

## Production Readiness

### 1. Signal Handling
```dockerfile
# Use exec form for proper signal handling
CMD ["node", "server.js"]

# Not shell form
CMD node server.js
```

### 2. Graceful Shutdown
```dockerfile
# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]
```

### 3. Resource Limits
```dockerfile
# Set memory limits in docker-compose or k8s
# Document expected resource usage
LABEL memory.limit="512MB"
LABEL cpu.limit="0.5"
```

### 4. Logging Configuration
```dockerfile
# Configure logging to stdout/stderr
ENV LOG_LEVEL=info
ENV LOG_FORMAT=json

# Don't log to files in containers
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log
```

## Complete Example: Production-Ready Dockerfile

```dockerfile
# syntax=docker/dockerfile:1
ARG NODE_VERSION=18.17.0
ARG ALPINE_VERSION=3.18

# Build stage
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS builder

# Install build dependencies
RUN apk add --no-cache python3 make g++

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev)
RUN --mount=type=cache,target=/root/.npm \
    npm ci

# Copy source code
COPY . .

# Build application
RUN npm run build

# Production stage
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS production

# Add metadata
LABEL maintainer="devops@company.com"
LABEL version="1.0.0"
LABEL description="Production Node.js application"

# Install dumb-init for signal handling
RUN apk add --no-cache dumb-init

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install production dependencies only
RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production && \
    npm cache clean --force

# Copy built application from builder stage
COPY --from=builder --chown=nextjs:nodejs /app/dist ./dist
COPY --from=builder --chown=nextjs:nodejs /app/public ./public

# Switch to non-root user
USER nextjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Use dumb-init and exec form
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/server.js"]
```

## Optimization Checklist

### Image Size
- [ ] Use multi-stage builds
- [ ] Choose minimal base images
- [ ] Combine RUN instructions
- [ ] Use .dockerignore
- [ ] Remove unnecessary files

### Security
- [ ] Run as non-root user
- [ ] Use specific image tags
- [ ] Scan for vulnerabilities
- [ ] Handle secrets properly
- [ ] Keep packages updated

### Performance
- [ ] Optimize layer caching
- [ ] Use package manager caches
- [ ] Implement health checks
- [ ] Optimize file operations
- [ ] Use BuildKit features

### Maintainability
- [ ] Add proper labels
- [ ] Document instructions
- [ ] Use build arguments
- [ ] Follow naming conventions
- [ ] Version your images

### Production
- [ ] Handle signals properly
- [ ] Configure logging
- [ ] Set resource expectations
- [ ] Test in production-like environment
- [ ] Monitor image metrics

## Common Anti-Patterns to Avoid

```dockerfile
# ❌ Don't do this
FROM ubuntu:latest
RUN apt-get update
RUN apt-get install -y python3
RUN apt-get install -y pip
ADD . /app
WORKDIR /app
RUN pip install -r requirements.txt
CMD python app.py

# ✅ Do this instead
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
USER 1001
CMD ["python", "app.py"]
```

This comprehensive guide covers all essential Dockerfile best practices for creating optimized, secure, and maintainable container images.
