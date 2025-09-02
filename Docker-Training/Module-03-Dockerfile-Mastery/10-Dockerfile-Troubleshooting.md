# Dockerfile Troubleshooting Guide

## Table of Contents
1. [Common Build Errors](#common-build-errors)
2. [Runtime Issues](#runtime-issues)
3. [Performance Problems](#performance-problems)
4. [Security Issues](#security-issues)
5. [Debugging Techniques](#debugging-techniques)
6. [Best Practices for Prevention](#best-practices-for-prevention)

## Common Build Errors

### 1. Base Image Issues

#### Error: Image Not Found
```bash
# Error message
ERROR [internal] load metadata for docker.io/library/node:19-alpine
```

**Solution:**
```dockerfile
# ❌ Problematic
FROM node:19-alpine  # Version might not exist

# ✅ Fixed
FROM node:18-alpine   # Use existing version
FROM node:18.17.0-alpine  # Use specific version
```

**Debugging Steps:**
```bash
# Check available tags
docker search node
docker pull node:18-alpine  # Test pull manually

# Use Docker Hub or registry to verify tags
curl -s https://registry.hub.docker.com/v2/repositories/library/node/tags/ | jq '.results[].name'
```

#### Error: Platform Mismatch
```bash
# Error message
WARNING: The requested image's platform (linux/amd64) does not match the detected host platform
```

**Solution:**
```dockerfile
# ✅ Multi-platform support
FROM --platform=$TARGETPLATFORM node:18-alpine

# Or specify platform explicitly
FROM --platform=linux/amd64 node:18-alpine
```

### 2. COPY/ADD Errors

#### Error: File Not Found
```bash
# Error message
COPY failed: file not found in build context or excluded by .dockerignore
```

**Solution:**
```dockerfile
# ❌ Problematic
COPY nonexistent-file.txt /app/

# ✅ Fixed - Check file exists
COPY package*.json /app/
COPY src/ /app/src/

# ✅ Use wildcards carefully
COPY package.json package-lock.json* /app/
```

**Debugging Steps:**
```bash
# Check build context
docker build --no-cache -t debug .
ls -la  # Verify files exist
cat .dockerignore  # Check if files are excluded
```

#### Error: Permission Denied
```bash
# Error message
COPY failed: permission denied
```

**Solution:**
```dockerfile
# ✅ Set proper ownership
COPY --chown=appuser:appgroup src/ /app/

# ✅ Fix permissions after copy
COPY src/ /app/
RUN chown -R appuser:appgroup /app
RUN chmod -R 755 /app
```

### 3. RUN Command Failures

#### Error: Package Installation Failed
```bash
# Error message
E: Unable to locate package python3-pip
```

**Solution:**
```dockerfile
# ❌ Problematic
FROM ubuntu:20.04
RUN apt-get install -y python3-pip

# ✅ Fixed
FROM ubuntu:20.04
RUN apt-get update && \
    apt-get install -y python3-pip && \
    rm -rf /var/lib/apt/lists/*

# ✅ Alpine alternative
FROM alpine:3.18
RUN apk add --no-cache python3 py3-pip
```

#### Error: Command Not Found
```bash
# Error message
/bin/sh: npm: not found
```

**Solution:**
```dockerfile
# ❌ Problematic - Wrong base image
FROM alpine:3.18
RUN npm install

# ✅ Fixed - Use appropriate base image
FROM node:18-alpine
RUN npm install

# ✅ Or install Node.js first
FROM alpine:3.18
RUN apk add --no-cache nodejs npm
RUN npm install
```

### 4. Multi-Stage Build Issues

#### Error: Stage Not Found
```bash
# Error message
failed to solve: stage "builder" not found
```

**Solution:**
```dockerfile
# ❌ Problematic - Typo in stage name
FROM node:18-alpine AS bulder  # Typo: "bulder"
COPY --from=builder /app/dist /app/  # References "builder"

# ✅ Fixed - Consistent naming
FROM node:18-alpine AS builder
COPY --from=builder /app/dist /app/
```

#### Error: File Not Found in Previous Stage
```bash
# Error message
COPY failed: "/app/dist" not found in build context or excluded
```

**Solution:**
```dockerfile
# ❌ Problematic - File doesn't exist in stage
FROM node:18-alpine AS builder
COPY package*.json ./
RUN npm ci
# Missing: RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html  # dist doesn't exist

# ✅ Fixed - Ensure build step exists
FROM node:18-alpine AS builder
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build  # Creates dist directory

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
```

## Runtime Issues

### 1. Container Startup Failures

#### Error: Permission Denied
```bash
# Error message
docker: Error response from daemon: container init caused: exec: "./app": permission denied
```

**Solution:**
```dockerfile
# ✅ Fix executable permissions
COPY app /usr/local/bin/
RUN chmod +x /usr/local/bin/app

# ✅ Or use COPY with chmod
COPY --chmod=755 app /usr/local/bin/
```

#### Error: User/Group Not Found
```bash
# Error message
docker: Error response from daemon: unable to find user appuser: no matching entries in passwd file
```

**Solution:**
```dockerfile
# ❌ Problematic - User doesn't exist
USER appuser

# ✅ Fixed - Create user first
RUN adduser -D -s /bin/sh appuser
USER appuser

# ✅ Alternative - Use numeric UID
USER 1001:1001
```

### 2. Application Runtime Errors

#### Error: Port Already in Use
```bash
# Error message
Error: listen EADDRINUSE: address already in use :::3000
```

**Solution:**
```dockerfile
# ✅ Use environment variables for port configuration
ENV PORT=3000
EXPOSE $PORT

# ✅ Allow port override at runtime
ENV PORT=${PORT:-3000}
```

**Runtime Fix:**
```bash
# Run on different port
docker run -p 8080:3000 -e PORT=3000 myapp

# Check port usage
docker ps
netstat -tulpn | grep :3000
```

#### Error: Database Connection Failed
```bash
# Error message
Error: connect ECONNREFUSED 127.0.0.1:5432
```

**Solution:**
```dockerfile
# ✅ Use proper database host
ENV DATABASE_HOST=postgres  # Service name in Docker Compose
ENV DATABASE_HOST=host.docker.internal  # For Docker Desktop

# ✅ Add connection retry logic
COPY wait-for-it.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wait-for-it.sh
CMD ["wait-for-it.sh", "postgres:5432", "--", "npm", "start"]
```

### 3. Volume and Mount Issues

#### Error: Volume Mount Failed
```bash
# Error message
docker: Error response from daemon: invalid mount config for type "bind": bind source path does not exist
```

**Solution:**
```bash
# ❌ Problematic - Path doesn't exist
docker run -v /nonexistent/path:/app/data myapp

# ✅ Fixed - Create path first
mkdir -p /host/data
docker run -v /host/data:/app/data myapp

# ✅ Use named volumes
docker volume create myapp-data
docker run -v myapp-data:/app/data myapp
```

## Performance Problems

### 1. Slow Build Times

#### Problem: Large Build Context
```bash
# Symptoms
Sending build context to Docker daemon  2.5GB
```

**Solution:**
```dockerfile
# Create comprehensive .dockerignore
node_modules
.git
*.log
.env
coverage/
.pytest_cache/
__pycache__/
*.pyc
.DS_Store
Thumbs.db
```

**Debugging:**
```bash
# Check build context size
docker build --no-cache -t test . 2>&1 | head -1

# Analyze what's being sent
tar -czh . | wc -c  # Size of build context
find . -size +100M  # Find large files
```

#### Problem: Cache Invalidation
```dockerfile
# ❌ Problematic - Invalidates cache frequently
COPY . /app
RUN npm install

# ✅ Fixed - Dependencies first
COPY package*.json /app/
RUN npm install
COPY . /app
```

### 2. Large Image Sizes

#### Problem: Unnecessary Files in Image
```dockerfile
# ❌ Problematic - Includes build tools in final image
FROM node:18
COPY . .
RUN npm install
RUN npm run build
CMD ["npm", "start"]

# ✅ Fixed - Multi-stage build
FROM node:18 AS builder
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
CMD ["npm", "start"]
```

**Analysis Tools:**
```bash
# Analyze image layers
docker history myapp:latest
dive myapp:latest  # Use dive tool for detailed analysis

# Compare image sizes
docker images | grep myapp
```

### 3. Runtime Performance Issues

#### Problem: High Memory Usage
```dockerfile
# ✅ Set memory limits and optimize
FROM node:18-alpine

# Node.js memory optimization
ENV NODE_OPTIONS="--max-old-space-size=512"

# Use production mode
ENV NODE_ENV=production

# Clean npm cache
RUN npm ci --only=production && npm cache clean --force
```

**Monitoring:**
```bash
# Monitor container resources
docker stats myapp
docker exec myapp ps aux
docker exec myapp free -h
```

## Security Issues

### 1. Running as Root

#### Problem: Security Vulnerability
```dockerfile
# ❌ Problematic - Runs as root
FROM alpine:3.18
COPY app /app
CMD ["/app"]
```

**Solution:**
```dockerfile
# ✅ Fixed - Non-root user
FROM alpine:3.18
RUN adduser -D -s /bin/sh appuser
COPY --chown=appuser:appuser app /app
USER appuser
CMD ["/app"]
```

### 2. Secrets in Image

#### Problem: Exposed Credentials
```dockerfile
# ❌ Problematic - Secrets in environment
ENV API_KEY=secret123
ENV DATABASE_PASSWORD=password
```

**Solution:**
```dockerfile
# ✅ Fixed - Use secrets management
ENV API_KEY_FILE=/run/secrets/api_key
ENV DATABASE_PASSWORD_FILE=/run/secrets/db_password

# ✅ Or use build secrets
RUN --mount=type=secret,id=api_key \
    API_KEY=$(cat /run/secrets/api_key) && \
    # Use API_KEY here without storing it
```

## Debugging Techniques

### 1. Interactive Debugging

#### Debug Build Process
```bash
# Build up to specific stage
docker build --target builder -t debug:builder .

# Run interactive shell
docker run -it debug:builder sh

# Inspect filesystem
ls -la /app
cat /app/package.json
npm list
```

#### Debug Running Container
```bash
# Access running container
docker exec -it container_name sh

# Debug with different entrypoint
docker run -it --entrypoint sh myapp:latest

# Override CMD for debugging
docker run -it myapp:latest sh
```

### 2. Build Debugging

#### Enable BuildKit Debug
```bash
# Enable BuildKit with debug output
export DOCKER_BUILDKIT=1
docker build --progress=plain .

# Use buildx for advanced debugging
docker buildx build --progress=plain --no-cache .
```

#### Layer-by-Layer Analysis
```dockerfile
# Add debugging commands
FROM alpine:3.18
RUN echo "=== Debug: Base image ready ==="

COPY package.json .
RUN echo "=== Debug: Package.json copied ==="
RUN cat package.json

RUN npm install
RUN echo "=== Debug: Dependencies installed ==="
RUN npm list --depth=0
```

### 3. Network Debugging

#### Test Network Connectivity
```dockerfile
FROM alpine:3.18

# Install network tools
RUN apk add --no-cache curl wget netcat-openbsd

# Network test script
COPY network-debug.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/network-debug.sh

CMD ["/usr/local/bin/network-debug.sh"]
```

**network-debug.sh:**
```bash
#!/bin/sh
echo "=== Network Debug ==="
echo "Hostname: $(hostname)"
echo "IP Address: $(hostname -i)"
echo "DNS Resolution:"
nslookup google.com
echo "Port connectivity:"
nc -zv google.com 80
curl -I https://google.com
```

### 4. Volume Debugging

#### Test Volume Mounts
```dockerfile
FROM alpine:3.18

# Volume test script
COPY volume-debug.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/volume-debug.sh

VOLUME ["/data"]
CMD ["/usr/local/bin/volume-debug.sh"]
```

**volume-debug.sh:**
```bash
#!/bin/sh
echo "=== Volume Debug ==="
echo "Mount points:"
mount | grep /data
echo "Permissions:"
ls -la /data
echo "Disk usage:"
df -h /data
echo "Test write:"
echo "test" > /data/test.txt && echo "Write successful" || echo "Write failed"
```

## Best Practices for Prevention

### 1. Dockerfile Linting
```bash
# Use hadolint for Dockerfile linting
docker run --rm -i hadolint/hadolint < Dockerfile

# Use VS Code extension
# Install "ms-azuretools.vscode-docker"
```

### 2. Multi-Stage Testing
```dockerfile
# Test stage in multi-stage build
FROM node:18-alpine AS test
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm test
RUN npm run lint

# Production stage
FROM node:18-alpine AS production
COPY --from=test /app/dist ./dist
CMD ["npm", "start"]
```

### 3. Health Checks
```dockerfile
FROM alpine:3.18

# Comprehensive health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /usr/local/bin/health-check.sh || exit 1

COPY health-check.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/health-check.sh
```

**health-check.sh:**
```bash
#!/bin/sh
# Check application health
curl -f http://localhost:8080/health || exit 1

# Check dependencies
nc -z database 5432 || exit 1
nc -z redis 6379 || exit 1

# Check disk space
df / | awk 'NR==2 {if ($5+0 > 90) exit 1}'

echo "Health check passed"
```

### 4. Comprehensive Testing
```bash
#!/bin/bash
# comprehensive-test.sh

echo "=== Dockerfile Testing ==="

# 1. Lint Dockerfile
echo "Linting Dockerfile..."
hadolint Dockerfile

# 2. Build image
echo "Building image..."
docker build -t test:latest .

# 3. Security scan
echo "Security scanning..."
trivy image test:latest

# 4. Test container startup
echo "Testing container startup..."
docker run -d --name test-container test:latest
sleep 5

# 5. Test health
echo "Testing health..."
docker exec test-container /usr/local/bin/health-check.sh

# 6. Test functionality
echo "Testing functionality..."
curl -f http://localhost:8080/api/health

# 7. Cleanup
docker stop test-container
docker rm test-container

echo "All tests passed!"
```

This comprehensive troubleshooting guide covers the most common Docker and Dockerfile issues with practical solutions and debugging techniques.
