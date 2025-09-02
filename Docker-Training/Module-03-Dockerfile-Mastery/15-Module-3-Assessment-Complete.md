# 🎯 Module 3: Dockerfile Mastery - Complete Assessment

## 📋 Assessment Overview

**Assessment Type**: Comprehensive Practical Evaluation  
**Duration**: 6-8 Hours  
**Passing Score**: 85% (340/400 points)  
**Prerequisites**: All Module 3 content completed  

This assessment validates your Dockerfile mastery through practical exercises, real-world scenarios, and comprehensive evaluation matching the rigor of Modules 1 and 2.

## 🎯 Assessment Structure

### Part A: Dockerfile Fundamentals (120 points - 30%)
**Duration**: 2 hours  
**Format**: Practical Dockerfile creation and optimization  

### Part B: Multi-Stage Build Mastery (160 points - 40%)
**Duration**: 3-4 hours  
**Format**: Complex production-ready implementations  

### Part C: Security & Performance (120 points - 30%)
**Duration**: 2 hours  
**Format**: Security hardening and optimization challenges  

## 📚 Part A: Dockerfile Fundamentals (120 points)

### Section A1: Instruction Mastery (40 points)

#### Task A1.1: Complete Dockerfile Creation (20 points)
```dockerfile
# Create a comprehensive Dockerfile for a Python FastAPI application
# Requirements:
# 1. Use Python 3.11-slim base image with build argument flexibility
# 2. Implement all major instructions (FROM, RUN, COPY, ENV, ARG, etc.)
# 3. Create non-root user with specific UID/GID
# 4. Add comprehensive labels and metadata
# 5. Implement health check
# 6. Use proper instruction ordering for cache optimization

# Your Dockerfile implementation:
ARG PYTHON_VERSION=3.11
FROM python:${PYTHON_VERSION}-slim

# Metadata and labels
LABEL maintainer="developer@ecommerce.com" \
      version="2.0.0" \
      description="E-commerce FastAPI backend" \
      org.opencontainers.image.source="https://github.com/company/ecommerce"

# Build arguments
ARG APP_USER=appuser
ARG APP_UID=1001
ARG APP_GID=1001

# Environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    APP_HOME=/app \
    PATH="/home/${APP_USER}/.local/bin:$PATH"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r -g ${APP_GID} ${APP_USER} && \
    useradd -r -u ${APP_UID} -g ${APP_USER} -d ${APP_HOME} -s /bin/bash ${APP_USER}

# Set working directory
WORKDIR ${APP_HOME}

# Copy requirements first for better caching
COPY --chown=${APP_USER}:${APP_USER} requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY --chown=${APP_USER}:${APP_USER} . .

# Create necessary directories
RUN mkdir -p uploads logs && \
    chown -R ${APP_USER}:${APP_USER} uploads logs

# Switch to non-root user
USER ${APP_USER}

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# Expose port
EXPOSE 8000

# Default command
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

#### Task A1.2: Advanced Instruction Usage (20 points)
```dockerfile
# Demonstrate advanced Dockerfile patterns
# Requirements:
# 1. Use ONBUILD instructions for template creation
# 2. Implement conditional logic with build arguments
# 3. Use SHELL instruction for custom shell
# 4. Implement STOPSIGNAL for graceful shutdown
# 5. Use VOLUME for data persistence

ARG BUILD_ENV=production
ARG ENABLE_DEBUG=false

FROM python:3.11-slim

# Change default shell for better error handling
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# Conditional package installation
RUN if [ "$BUILD_ENV" = "development" ]; then \
        apt-get update && apt-get install -y \
            vim \
            git \
            htop; \
    fi && \
    rm -rf /var/lib/apt/lists/*

# ONBUILD instructions for child images
ONBUILD COPY requirements.txt .
ONBUILD RUN pip install -r requirements.txt
ONBUILD COPY . .

# Volume for persistent data
VOLUME ["/app/data", "/app/logs"]

# Custom stop signal
STOPSIGNAL SIGTERM

# Conditional debug configuration
RUN if [ "$ENABLE_DEBUG" = "true" ]; then \
        pip install debugpy; \
    fi

WORKDIR /app
EXPOSE 8000

CMD ["python", "main.py"]
```

**Evaluation Criteria**:
- Correct instruction usage and syntax (10 points)
- Proper ordering and optimization (10 points)
- Security best practices (10 points)
- Advanced pattern implementation (10 points)

### Section A2: Build Optimization (40 points)

#### Task A2.1: Layer Optimization Challenge (20 points)
```dockerfile
# Optimize this inefficient Dockerfile
# Original (inefficient):
FROM ubuntu:20.04
RUN apt-get update
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
RUN apt-get install -y curl
RUN apt-get install -y git
COPY requirements.txt .
RUN pip3 install flask
RUN pip3 install requests
RUN pip3 install psycopg2-binary
COPY . .
RUN apt-get clean
EXPOSE 5000
CMD ["python3", "app.py"]

# Your optimized version:
FROM python:3.11-slim

# Combine RUN instructions and clean up in same layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install all Python dependencies in one layer
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code last (changes most frequently)
COPY . .

EXPOSE 5000
CMD ["python", "app.py"]
```

#### Task A2.2: BuildKit Features Implementation (20 points)
```dockerfile
# syntax=docker/dockerfile:1
# Implement advanced BuildKit features
# Requirements:
# 1. Use cache mounts for package managers
# 2. Implement secret mounts for sensitive data
# 3. Use bind mounts for build context optimization
# 4. Implement parallel build stages

FROM python:3.11-slim AS base

# Use cache mount for apt packages
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y \
    curl \
    build-essential

# Dependencies stage with pip cache
FROM base AS dependencies
WORKDIR /app

COPY requirements.txt .

# Use cache mount for pip
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt

# Build stage with secret mount
FROM dependencies AS builder
WORKDIR /app

# Use secret mount for private repositories
RUN --mount=type=secret,id=github_token \
    git config --global url."https://$(cat /run/secrets/github_token)@github.com/".insteadOf "https://github.com/"

COPY . .
RUN python setup.py build

# Production stage
FROM python:3.11-slim AS production
WORKDIR /app

COPY --from=dependencies /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /app/dist ./

CMD ["python", "main.py"]
```

**Evaluation Criteria**:
- Layer optimization techniques (10 points)
- BuildKit feature usage (10 points)
- Cache efficiency implementation (10 points)
- Build performance improvement (10 points)

### Section A3: Error Handling & Debugging (40 points)

#### Task A3.1: Dockerfile Debugging (20 points)
```dockerfile
# Debug and fix this problematic Dockerfile
# Issues to identify and fix:
FROM node:latest
WORKDIR app
COPY package.json
RUN npm install
COPY .
EXPOSE 3000
USER root
CMD npm start

# Your corrected version with explanations:
# Issue 1: Using 'latest' tag - not reproducible
FROM node:18-alpine

# Issue 2: Missing absolute path for WORKDIR
WORKDIR /app

# Issue 3: Missing destination in COPY
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Issue 4: Missing destination in COPY
COPY . .

# Issue 5: Running as root user - security risk
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001 -G nodejs

# Change ownership of app directory
RUN chown -R nextjs:nodejs /app

# Switch to non-root user
USER nextjs

EXPOSE 3000

# Issue 6: Using npm start instead of exec form
CMD ["npm", "start"]
```

#### Task A3.2: Build Troubleshooting (20 points)
```bash
# Troubleshoot these build scenarios and provide solutions

# Scenario 1: Build fails with "No space left on device"
# Your solution:
docker system prune -a -f
docker builder prune -a -f
# Increase Docker disk space allocation
# Use multi-stage builds to reduce intermediate layers

# Scenario 2: Dependencies not found during build
# Your solution:
# Check .dockerignore file
# Verify COPY paths are correct
# Ensure package files exist in build context
# Use COPY --from for multi-stage builds

# Scenario 3: Permission denied errors
# Your solution:
# Use --chown flag in COPY instructions
# Create user before copying files
# Set proper file permissions with RUN chmod
# Avoid running as root user

# Scenario 4: Slow build performance
# Your solution:
# Optimize layer ordering (dependencies first)
# Use .dockerignore to exclude unnecessary files
# Implement BuildKit cache mounts
# Use multi-stage builds to parallelize
```

**Evaluation Criteria**:
- Problem identification accuracy (10 points)
- Solution implementation quality (10 points)
- Best practices application (10 points)
- Troubleshooting methodology (10 points)

## 🛠️ Part B: Multi-Stage Build Mastery (160 points)

### Section B1: E-Commerce Backend Implementation (80 points)

#### Task B1.1: Production-Ready FastAPI Dockerfile (40 points)
```dockerfile
# Create production-optimized Dockerfile for e-commerce backend
# Requirements:
# 1. Multi-stage build with builder and production stages
# 2. Security hardening with non-root user
# 3. Dependency optimization and caching
# 4. Health checks and monitoring integration
# 5. Size optimization (target: <200MB)

# syntax=docker/dockerfile:1

# Build stage
FROM python:3.11-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libpq-dev \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Use cache mount for pip
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --user --no-cache-dir -r requirements.txt

# Production stage
FROM python:3.11-slim AS production

# Install runtime dependencies only
RUN apt-get update && apt-get install -y \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r -g 1001 appuser && \
    useradd -r -u 1001 -g appuser -d /app -s /bin/bash appuser

# Copy Python packages from builder
COPY --from=builder /root/.local /home/appuser/.local

WORKDIR /app

# Copy application code with proper ownership
COPY --chown=appuser:appuser . .

# Create necessary directories
RUN mkdir -p uploads logs && \
    chown -R appuser:appuser uploads logs

# Switch to non-root user
USER appuser

# Environment configuration
ENV PATH=/home/appuser/.local/bin:$PATH \
    PYTHONPATH=/app \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

EXPOSE 8000

# Use exec form for proper signal handling
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
```

#### Task B1.2: Performance Validation (40 points)
```bash
# Build and validate the backend Dockerfile
# Requirements:
# 1. Build time optimization
# 2. Image size validation
# 3. Security scanning
# 4. Performance testing

# Build with BuildKit
DOCKER_BUILDKIT=1 docker build -t ecommerce-backend:assessment .

# Validate image size (should be <200MB)
docker images ecommerce-backend:assessment

# Security scan (should have 0 HIGH/CRITICAL vulnerabilities)
trivy image ecommerce-backend:assessment

# Performance test
docker run -d --name backend-test -p 8000:8000 ecommerce-backend:assessment

# Test startup time (should be <10 seconds)
time curl --retry 10 --retry-delay 1 http://localhost:8000/health

# Test API performance
ab -n 100 -c 10 http://localhost:8000/api/products/

# Memory usage validation (should be <256MB)
docker stats backend-test --no-stream

# Cleanup
docker stop backend-test && docker rm backend-test
```

**Evaluation Criteria**:
- Multi-stage implementation quality (20 points)
- Security hardening completeness (20 points)
- Performance optimization results (20 points)
- Production readiness validation (20 points)

### Section B2: E-Commerce Frontend Implementation (80 points)

#### Task B2.1: React Application Optimization (40 points)
```dockerfile
# Create optimized Dockerfile for React frontend
# Requirements:
# 1. Multi-stage build with dependencies, build, and production stages
# 2. Nginx integration with custom configuration
# 3. Security headers and non-root execution
# 4. Size optimization (target: <50MB)

# syntax=docker/dockerfile:1

# Dependencies stage
FROM node:18-alpine AS dependencies

WORKDIR /app

# Use cache mount for npm
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production && npm cache clean --force

# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Copy dependencies from previous stage
COPY --from=dependencies /app/node_modules ./node_modules
COPY package*.json ./

# Install all dependencies (including dev)
RUN --mount=type=cache,target=/root/.npm \
    npm ci

# Copy source code and build
COPY . .

# Build application with optimization
RUN npm run build && \
    npm run test:ci

# Production stage
FROM nginx:alpine AS production

# Create non-root user
RUN addgroup -g 1001 -S nginx && \
    adduser -S nginx -u 1001 -G nginx

# Copy built application
COPY --from=builder /app/build /usr/share/nginx/html

# Copy optimized nginx configuration
COPY nginx.prod.conf /etc/nginx/nginx.conf

# Change ownership to non-root user
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d

# Create nginx runtime directories
RUN mkdir -p /var/cache/nginx/client_temp && \
    chown -R nginx:nginx /var/cache/nginx

# Switch to non-root user
USER nginx

EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
```

#### Task B2.2: Nginx Configuration (40 points)
```nginx
# Create nginx.prod.conf for the frontend
# Requirements:
# 1. Security headers implementation
# 2. Gzip compression optimization
# 3. Caching strategies for static assets
# 4. API proxy configuration

events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    # Security headers
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';" always;
    
    # Performance optimizations
    sendfile        on;
    tcp_nopush      on;
    tcp_nodelay     on;
    keepalive_timeout  65;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;
    
    server {
        listen       8080;
        server_name  localhost;
        
        # Root directory
        root   /usr/share/nginx/html;
        index  index.html index.htm;
        
        # Main application
        location / {
            try_files $uri $uri/ /index.html;
            
            # Cache HTML files for short time
            location ~* \.html$ {
                expires 1h;
                add_header Cache-Control "public, must-revalidate";
            }
        }
        
        # Static assets with long-term caching
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
            log_not_found off;
        }
        
        # API proxy
        location /api/ {
            proxy_pass http://backend:8000/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # CORS headers
            add_header Access-Control-Allow-Origin "http://localhost:3000" always;
            add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
            add_header Access-Control-Allow-Headers "Authorization, Content-Type" always;
            
            # Handle preflight requests
            if ($request_method = OPTIONS) {
                return 204;
            }
        }
        
        # Error pages
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/share/nginx/html;
        }
    }
}
```

**Evaluation Criteria**:
- Multi-stage optimization quality (20 points)
- Nginx configuration completeness (20 points)
- Security implementation (20 points)
- Performance optimization (20 points)

## 🔒 Part C: Security & Performance (120 points)

### Section C1: Security Hardening (60 points)

#### Task C1.1: Comprehensive Security Implementation (30 points)
```dockerfile
# Create maximum security Dockerfile
# Requirements:
# 1. Vulnerability scanning integration
# 2. Non-root user with minimal privileges
# 3. Read-only filesystem compatibility
# 4. Security scanning automation

# syntax=docker/dockerfile:1
FROM python:3.11-slim AS base

# Security updates first
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Build stage
FROM base AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install dependencies with security scanning
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Production stage
FROM base AS production

# Create non-root user with specific UID/GID
RUN groupadd -r -g 1001 appuser && \
    useradd -r -u 1001 -g appuser -d /app -s /bin/bash appuser

# Copy Python packages from builder
COPY --from=builder /root/.local /home/appuser/.local

WORKDIR /app

# Copy application with proper ownership
COPY --chown=appuser:appuser . .

# Remove any potential sensitive files
RUN find /app -name "*.pyc" -delete && \
    find /app -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true && \
    find /app -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true

# Create necessary directories for read-only filesystem
RUN mkdir -p /tmp/app /var/log/app && \
    chown -R appuser:appuser /tmp/app /var/log/app

# Switch to non-root user
USER appuser

# Security environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH=/home/appuser/.local/bin:$PATH \
    TMPDIR=/tmp/app

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

EXPOSE 8000

# Use exec form for proper signal handling
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

#### Task C1.2: Runtime Security Testing (30 points)
```bash
# Implement comprehensive security testing
# Requirements:
# 1. Container security scanning
# 2. Runtime security validation
# 3. Compliance checking
# 4. Vulnerability assessment

# Build secure image
docker build -f Dockerfile.secure -t app:secure .

# Security scan with Trivy
trivy image --severity HIGH,CRITICAL app:secure

# Run with maximum security constraints
docker run -d --name secure-test \
  --read-only \
  --tmpfs /tmp \
  --tmpfs /var/tmp \
  --tmpfs /tmp/app \
  --security-opt no-new-privileges:true \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  --user 1001:1001 \
  --memory=256m \
  --cpus=0.5 \
  -p 8000:8000 \
  app:secure

# Verify security configuration
echo "=== Security Validation ==="
echo "User: $(docker exec secure-test whoami)"
echo "UID/GID: $(docker exec secure-test id)"
echo "Read-only: $(docker inspect secure-test --format='{{.HostConfig.ReadonlyRootfs}}')"
echo "Capabilities: $(docker inspect secure-test --format='{{.HostConfig.CapDrop}}')"
echo "Security Options: $(docker inspect secure-test --format='{{.HostConfig.SecurityOpt}}')"

# Test application functionality
curl -f http://localhost:8000/health

# Security audit with custom script
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image --security-checks vuln,config app:secure

# Cleanup
docker stop secure-test && docker rm secure-test
```

**Evaluation Criteria**:
- Security implementation completeness (15 points)
- Vulnerability mitigation effectiveness (15 points)
- Runtime security validation (15 points)
- Compliance with security standards (15 points)

### Section C2: Performance Optimization (60 points)

#### Task C2.1: Build Performance Challenge (30 points)
```dockerfile
# Optimize this Dockerfile for maximum build performance
# Target: <3 minutes build time, <100MB final image

# syntax=docker/dockerfile:1
FROM golang:1.21-alpine AS builder

# Use cache mount for go modules
WORKDIR /app

COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

# Copy source and build with cache
COPY . .
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Minimal production image
FROM scratch AS production

# Copy SSL certificates for HTTPS
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copy binary
COPY --from=builder /app/main /main

# Expose port
EXPOSE 8080

# Run binary
ENTRYPOINT ["/main"]
```

#### Task C2.2: Performance Validation (30 points)
```bash
# Validate performance optimizations
# Requirements:
# 1. Build time measurement
# 2. Image size validation
# 3. Runtime performance testing
# 4. Resource usage monitoring

echo "=== Build Performance Test ==="

# Clean build (no cache)
time docker build --no-cache -t app:perf-test .

# Cached build (should be much faster)
time docker build -t app:perf-test .

# Image size validation
echo "=== Image Size Analysis ==="
docker images app:perf-test
docker history app:perf-test

# Runtime performance test
echo "=== Runtime Performance Test ==="
docker run -d --name perf-test -p 8080:8080 app:perf-test

# Startup time measurement
start_time=$(date +%s)
while ! curl -f http://localhost:8080/health 2>/dev/null; do
  sleep 0.1
done
end_time=$(date +%s)
echo "Startup time: $((end_time - start_time)) seconds"

# Load testing
ab -n 1000 -c 50 http://localhost:8080/

# Resource monitoring
docker stats perf-test --no-stream

# Cleanup
docker stop perf-test && docker rm perf-test
```

**Evaluation Criteria**:
- Build time optimization (15 points)
- Image size minimization (15 points)
- Runtime performance (15 points)
- Resource efficiency (15 points)

## 📊 Assessment Scoring

### Scoring Breakdown
| Section | Points | Weight | Criteria |
|---------|--------|--------|----------|
| **Part A: Fundamentals** | 120 | 30% | Instruction mastery, optimization, debugging |
| **Part B: Multi-Stage Builds** | 160 | 40% | Production implementations, performance |
| **Part C: Security & Performance** | 120 | 30% | Security hardening, optimization |
| **Total** | 400 | 100% | Complete Dockerfile mastery |

### Grading Scale
- **Expert (360-400 points)**: 90-100% - Ready for advanced container topics
- **Proficient (340-359 points)**: 85-89% - Solid Dockerfile mastery
- **Developing (280-339 points)**: 70-84% - Needs additional practice
- **Novice (0-279 points)**: 0-69% - Requires Module 3 review

## 🎯 Success Criteria

### Technical Requirements
- [ ] All Dockerfiles use non-root users
- [ ] Zero HIGH/CRITICAL vulnerabilities in final images
- [ ] 70%+ reduction in image sizes through optimization
- [ ] <5 minute build times with proper caching
- [ ] Production-ready security configurations
- [ ] Comprehensive health checks implemented

### Skill Demonstration
- [ ] Master all 20+ Dockerfile instructions
- [ ] Create complex multi-stage builds
- [ ] Implement comprehensive security hardening
- [ ] Optimize build performance and image sizes
- [ ] Integrate with CI/CD pipelines
- [ ] Debug and troubleshoot complex build issues

## 🎉 Certification

Upon successful completion (≥340 points), you will receive:

- **Dockerfile Mastery Certificate** - Expert container image creation
- **Build Optimization Badge** - Performance and security specialist
- **Production Readiness Recognition** - Enterprise-grade implementations
- **Security Hardening Certification** - Container security expert

---

**🎯 Assessment Timeline**: Complete within 2 weeks of Module 3 content completion  
**🔄 Retake Policy**: One retake allowed after additional study  
**📞 Support**: Instructor available for clarification questions  

**Good luck with your Dockerfile Mastery Assessment! 🐳**
