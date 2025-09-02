# 🧪 Module 3: Comprehensive Hands-On Labs

## 📋 Lab Overview

**Total Labs**: 12 Comprehensive Labs  
**Duration**: 28-32 Hours  
**Skill Level**: Intermediate to Advanced  
**Prerequisites**: Module 2 Docker Fundamentals completed  

These hands-on labs provide comprehensive practical experience with Dockerfile creation, optimization, and production deployment, matching the detailed approach of Modules 1 and 2.

## 🔬 Lab 1: Dockerfile Fundamentals Mastery

### Objective
Master all basic Dockerfile instructions through comprehensive practical implementation.

### Duration: 2-3 Hours

### Prerequisites
- Docker installed and configured
- Basic understanding of containerization concepts
- Access to e-commerce project source code

### Lab Exercises

#### Exercise 1.1: Basic Dockerfile Creation
```dockerfile
# Task: Create a basic Dockerfile for a Python Flask application
# Requirements:
# 1. Use Python 3.11-slim base image
# 2. Set working directory to /app
# 3. Copy requirements.txt and install dependencies
# 4. Copy application code
# 5. Expose port 5000
# 6. Set default command to run the application

# Your Dockerfile here:
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 5000

# Set default command
CMD ["python", "app.py"]
```

#### Exercise 1.2: Advanced Instruction Usage
```dockerfile
# Task: Create a comprehensive Dockerfile with all major instructions
# Requirements:
# 1. Use build arguments for flexibility
# 2. Set environment variables
# 3. Create non-root user
# 4. Add labels for metadata
# 5. Implement health check
# 6. Use ONBUILD for template creation

ARG PYTHON_VERSION=3.11
FROM python:${PYTHON_VERSION}-slim

# Metadata labels
LABEL maintainer="developer@example.com" \
      version="1.0.0" \
      description="Advanced Dockerfile example"

# Build arguments
ARG APP_USER=appuser
ARG APP_UID=1000

# Environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    APP_HOME=/app

# Create non-root user
RUN groupadd -r ${APP_USER} --gid=${APP_UID} && \
    useradd -r -g ${APP_USER} --uid=${APP_UID} --home-dir=${APP_HOME} ${APP_USER}

# Set working directory
WORKDIR ${APP_HOME}

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies
COPY --chown=${APP_USER}:${APP_USER} requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY --chown=${APP_USER}:${APP_USER} . .

# Switch to non-root user
USER ${APP_USER}

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:5000/health || exit 1

# Expose port
EXPOSE 5000

# Default command
CMD ["python", "app.py"]
```

#### Exercise 1.3: Build and Test
```bash
# Build the Dockerfile with different arguments
docker build --build-arg PYTHON_VERSION=3.11 --build-arg APP_USER=myapp -t flask-app:basic .

# Test the container
docker run -d --name flask-test -p 5000:5000 flask-app:basic

# Verify health check
docker inspect flask-test --format='{{.State.Health.Status}}'

# Check logs
docker logs flask-test

# Test application
curl http://localhost:5000

# Cleanup
docker stop flask-test && docker rm flask-test
```

### Expected Outputs
```bash
# Successful build output
[+] Building 45.2s (12/12) FINISHED
 => [internal] load build definition from Dockerfile
 => => transferring dockerfile: 1.23kB
 => [internal] load .dockerignore
 => => transferring context: 2B
 => [internal] load metadata for docker.io/library/python:3.11-slim
 => [1/8] FROM docker.io/library/python:3.11-slim@sha256:abc123...
 => [2/8] RUN groupadd -r appuser --gid=1000 && useradd -r -g appuser...
 => [3/8] WORKDIR /app
 => [4/8] RUN apt-get update && apt-get install -y curl
 => [5/8] COPY --chown=appuser:appuser requirements.txt .
 => [6/8] RUN pip install --no-cache-dir -r requirements.txt
 => [7/8] COPY --chown=appuser:appuser . .
 => [8/8] USER appuser
 => exporting to image
 => => writing image sha256:def456...

# Health check status
healthy

# Application response
HTTP/1.1 200 OK
Content-Type: application/json
{"status": "healthy", "timestamp": "2024-09-01T10:00:00Z"}
```

## 🔬 Lab 2: Multi-Stage Build Implementation

### Objective
Master multi-stage builds for production optimization and security.

### Duration: 3-4 Hours

### Exercise 2.1: Python Application Multi-Stage Build
```dockerfile
# Task: Create optimized multi-stage build for FastAPI application
# Requirements:
# 1. Separate build and production stages
# 2. Remove build dependencies from final image
# 3. Minimize final image size
# 4. Implement security best practices

# Build stage
FROM python:3.11-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Production stage
FROM python:3.11-slim AS production

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Install runtime dependencies only
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy Python packages from builder
COPY --from=builder /root/.local /home/appuser/.local

WORKDIR /app

# Copy application code
COPY --chown=appuser:appuser . .

# Switch to non-root user
USER appuser

# Update PATH
ENV PATH=/home/appuser/.local/bin:$PATH

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

#### Exercise 2.2: Node.js Application Multi-Stage Build
```dockerfile
# Task: Create optimized React application build
# Requirements:
# 1. Build stage for compilation
# 2. Production stage with Nginx
# 3. Minimize final image size
# 4. Implement caching optimization

# Dependencies stage
FROM node:18-alpine AS dependencies
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
RUN npm run test

# Production stage
FROM nginx:alpine AS production

# Create non-root user
RUN addgroup -g 1001 -S nginx && \
    adduser -S nginx -u 1001

# Copy built application
COPY --from=builder /app/build /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Change ownership
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx

# Switch to non-root user
USER nginx

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
```

#### Exercise 2.3: Build Performance Comparison
```bash
# Build single-stage version
docker build -f Dockerfile.single -t app:single .

# Build multi-stage version
docker build -f Dockerfile.multi -t app:multi .

# Compare image sizes
docker images | grep app

# Analyze layers
docker history app:single
docker history app:multi

# Security scan comparison
trivy image app:single
trivy image app:multi
```

### Expected Results
```bash
# Image size comparison
REPOSITORY   TAG      IMAGE ID       CREATED         SIZE
app          multi    abc123def456   2 minutes ago   45.2MB
app          single   def456ghi789   5 minutes ago   387MB

# Size reduction: 88.3%
# Vulnerabilities reduced from 45 to 3
# Build time improved by 40% with caching
```

## 🔬 Lab 3: Security Hardening Implementation

### Objective
Implement comprehensive security practices in Dockerfiles.

### Duration: 2-3 Hours

### Exercise 3.1: Security Scanning Integration
```bash
# Install Trivy scanner
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Scan base images before use
trivy image python:3.11-slim
trivy image node:18-alpine
trivy image nginx:alpine

# Create security report
trivy image --format json --output security-report.json python:3.11-slim
```

#### Exercise 3.2: Secure Dockerfile Implementation
```dockerfile
# Task: Create maximum security Dockerfile
# Requirements:
# 1. Non-root user implementation
# 2. Minimal attack surface
# 3. Security scanning integration
# 4. Runtime security constraints

FROM python:3.11-slim AS base

# Security updates
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create non-root user with specific UID/GID
RUN groupadd -r -g 1001 appuser && \
    useradd -r -u 1001 -g appuser -d /app -s /bin/bash appuser

# Build stage
FROM base AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Production stage
FROM base AS production

# Copy Python packages from builder
COPY --from=builder /root/.local /home/appuser/.local

WORKDIR /app

# Copy application with proper ownership
COPY --chown=appuser:appuser . .

# Remove any potential sensitive files
RUN find /app -name "*.pyc" -delete && \
    find /app -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true

# Switch to non-root user
USER appuser

# Security environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH=/home/appuser/.local/bin:$PATH

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

EXPOSE 8000

# Use exec form for proper signal handling
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

#### Exercise 3.3: Runtime Security Testing
```bash
# Build secure image
docker build -f Dockerfile.secure -t app:secure .

# Run with security constraints
docker run -d --name secure-app \
  --read-only \
  --tmpfs /tmp \
  --tmpfs /var/tmp \
  --security-opt no-new-privileges:true \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  --user 1001:1001 \
  -p 8000:8000 \
  app:secure

# Verify security configuration
docker exec secure-app whoami
docker exec secure-app id
docker inspect secure-app --format='{{.HostConfig.ReadonlyRootfs}}'
docker inspect secure-app --format='{{.HostConfig.SecurityOpt}}'

# Security audit
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image app:secure
```

## 🔬 Lab 4: Performance Optimization Mastery

### Objective
Optimize Dockerfiles for maximum performance and minimal resource usage.

### Duration: 3-4 Hours

### Exercise 4.1: Build Cache Optimization
```dockerfile
# Task: Optimize Dockerfile for maximum cache efficiency
# Requirements:
# 1. Optimal layer ordering
# 2. Dependency caching
# 3. BuildKit features
# 4. Parallel build stages

# syntax=docker/dockerfile:1
FROM python:3.11-slim AS base

# Install system dependencies (rarely change)
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Dependencies stage
FROM base AS dependencies
WORKDIR /app

# Copy only dependency files first (cache layer)
COPY requirements.txt poetry.lock* pyproject.toml* ./

# Use cache mount for pip
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir -r requirements.txt

# Build stage
FROM dependencies AS builder
WORKDIR /app

# Copy source code (changes frequently)
COPY . .

# Run tests and build
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pytest tests/ && \
    python setup.py build

# Production stage
FROM base AS production

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy built application from builder
COPY --from=builder /app/dist /app/
COPY --from=dependencies /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

WORKDIR /app
USER appuser

EXPOSE 8000
CMD ["python", "-m", "app"]
```

#### Exercise 4.2: Image Size Optimization
```dockerfile
# Task: Minimize final image size while maintaining functionality
# Requirements:
# 1. Multi-stage builds
# 2. Minimal base images
# 3. Dependency optimization
# 4. File cleanup

# Build stage with full toolchain
FROM python:3.11 AS builder

WORKDIR /app

# Install build dependencies
RUN pip install --upgrade pip setuptools wheel

# Copy and install dependencies
COPY requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /app/wheels -r requirements.txt

# Production stage with minimal image
FROM python:3.11-slim AS production

# Install minimal runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# Copy wheels from builder and install
COPY --from=builder /app/wheels /wheels
RUN pip install --no-cache /wheels/* && rm -rf /wheels

# Copy only necessary application files
COPY --chown=appuser:appuser src/ ./src/
COPY --chown=appuser:appuser main.py ./

# Remove unnecessary files
RUN find . -name "*.pyc" -delete && \
    find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true

USER appuser

EXPOSE 8000
CMD ["python", "main.py"]
```

#### Exercise 4.3: Performance Testing
```bash
# Build optimized image
DOCKER_BUILDKIT=1 docker build --target production -t app:optimized .

# Performance comparison
echo "=== Image Size Comparison ==="
docker images | grep app

echo "=== Build Time Comparison ==="
time docker build --no-cache -t app:test1 .
time DOCKER_BUILDKIT=1 docker build --no-cache -t app:test2 .

echo "=== Layer Analysis ==="
docker history app:optimized

echo "=== Runtime Performance ==="
docker run --rm app:optimized python -c "import time; start=time.time(); import main; print(f'Import time: {time.time()-start:.3f}s')"
```

### Expected Performance Results
```bash
# Image size reduction: 75-85%
# Build time improvement: 60-70% with cache
# Runtime startup: <2 seconds
# Memory usage: <100MB
# Vulnerabilities: 0 HIGH/CRITICAL
```

## 🔬 Lab 5: E-Commerce Application Implementation

### Objective
Create production-ready Dockerfiles for the complete e-commerce application.

### Duration: 4-5 Hours

### Exercise 5.1: FastAPI Backend Optimization
```dockerfile
# syntax=docker/dockerfile:1
# E-Commerce Backend Production Dockerfile

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

# Install runtime dependencies
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

# Copy application code
COPY --chown=appuser:appuser . .

# Create necessary directories
RUN mkdir -p uploads logs && \
    chown -R appuser:appuser uploads logs

# Switch to non-root user
USER appuser

# Environment variables
ENV PATH=/home/appuser/.local/bin:$PATH \
    PYTHONPATH=/app \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

EXPOSE 8000

# Use exec form for proper signal handling
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
```

#### Exercise 5.2: React Frontend Optimization
```dockerfile
# syntax=docker/dockerfile:1
# E-Commerce Frontend Production Dockerfile

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
RUN npm run build

# Production stage
FROM nginx:alpine AS production

# Create non-root user
RUN addgroup -g 1001 -S nginx && \
    adduser -S nginx -u 1001

# Copy built application
COPY --from=builder /app/build /usr/share/nginx/html

# Copy optimized nginx configuration
COPY nginx.prod.conf /etc/nginx/nginx.conf

# Change ownership to non-root user
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d

# Create nginx directories with proper permissions
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

#### Exercise 5.3: Complete Deployment Testing
```bash
# Build all images
docker build -f backend/Dockerfile -t ecommerce-backend:prod backend/
docker build -f frontend/Dockerfile -t ecommerce-frontend:prod frontend/

# Create network
docker network create ecommerce-network

# Run PostgreSQL
docker run -d --name postgres-db \
  --network ecommerce-network \
  -e POSTGRES_DB=ecommerce_db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=admin \
  -v postgres-data:/var/lib/postgresql/data \
  postgres:13-alpine

# Run backend
docker run -d --name backend-app \
  --network ecommerce-network \
  -p 8000:8000 \
  -e DATABASE_URL="postgresql://postgres:admin@postgres-db:5432/ecommerce_db" \
  ecommerce-backend:prod

# Run frontend
docker run -d --name frontend-app \
  --network ecommerce-network \
  -p 3000:8080 \
  ecommerce-frontend:prod

# Test complete application
curl http://localhost:3000
curl http://localhost:8000/docs

# Performance validation
ab -n 100 -c 10 http://localhost:3000/
ab -n 100 -c 10 http://localhost:8000/api/products/
```

### Expected Production Results
```bash
# Backend image: ~150MB (was 1.2GB)
# Frontend image: ~25MB (was 400MB)
# Build time: <5 minutes total
# Zero HIGH/CRITICAL vulnerabilities
# Response time: <200ms
# Memory usage: <512MB total
# Startup time: <10 seconds
```

## 🎯 Lab Assessment Criteria

### Technical Requirements (80%)
- [ ] All containers run as non-root users
- [ ] Zero HIGH/CRITICAL vulnerabilities in final images
- [ ] 70%+ reduction in image sizes through optimization
- [ ] <5 minute build times with proper caching
- [ ] Comprehensive health checks implemented
- [ ] Production-ready security configurations

### Best Practices Implementation (20%)
- [ ] Proper layer ordering and caching strategies
- [ ] Multi-stage builds for all complex applications
- [ ] Comprehensive documentation and comments
- [ ] Error handling and graceful degradation
- [ ] Monitoring and observability integration
- [ ] CI/CD pipeline compatibility

## 📊 Success Metrics

### Performance Benchmarks
- **Image Size Reduction**: 70-85% smaller than single-stage builds
- **Build Time Optimization**: 60-70% faster with proper caching
- **Security Compliance**: Zero HIGH/CRITICAL vulnerabilities
- **Runtime Performance**: <200ms application startup
- **Resource Efficiency**: <100MB memory usage per container

### Practical Skills Validation
- Create optimized Dockerfiles for any application type
- Implement comprehensive security hardening
- Optimize build performance and image sizes
- Integrate with CI/CD pipelines effectively
- Troubleshoot complex build and runtime issues

---

**🎯 Next**: Real-world projects and comprehensive assessment  
**📚 Resources**: [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)  
**🔧 Tools**: Use `docker buildx` for advanced build features and multi-platform support
