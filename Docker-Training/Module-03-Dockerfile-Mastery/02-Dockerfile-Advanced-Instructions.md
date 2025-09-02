# 🐳 Advanced Dockerfile Instructions: Complete Expert Guide

## 🎯 Learning Objectives
- Master CMD, ENTRYPOINT, and their differences
- Understand VOLUME, ARG, and build-time variables
- Learn HEALTHCHECK, STOPSIGNAL, and container lifecycle
- Implement advanced Dockerfile patterns

---

## 🎯 CMD - Default Container Command

### Syntax
```dockerfile
# Exec form (preferred)
CMD ["executable","param1","param2"]

# Shell form
CMD command param1 param2

# As default parameters to ENTRYPOINT
CMD ["param1","param2"]
```

### Detailed Examples

**Exec Form (Recommended):**
```dockerfile
# Run Python application
CMD ["python", "app.py"]

# Run Node.js application
CMD ["node", "server.js"]

# Run with arguments
CMD ["python", "app.py", "--port", "8000"]
```

**Expected Build Output:**
```
Step 26/35 : CMD ["python", "app.py"]
 ---> i5j6k7l8m9n0
```

**Shell Form:**
```dockerfile
# Shell form (runs in /bin/sh -c)
CMD python app.py

# With shell features
CMD python app.py && echo "Application started"

# Environment variable expansion
CMD echo "Starting app in $NODE_ENV mode"
```

**Expected Build Output:**
```
Step 27/35 : CMD python app.py && echo "Application started"
 ---> j6k7l8m9n0o1
```

**CMD vs RUN Comparison:**

| Aspect | RUN | CMD |
|--------|-----|-----|
| **When executed** | Build time | Runtime |
| **Purpose** | Install/configure | Start application |
| **Multiple allowed** | Yes | Only last one used |
| **Can be overridden** | No | Yes (docker run args) |

**CMD Override Examples:**
```dockerfile
# Dockerfile
FROM ubuntu:20.04
CMD ["echo", "Hello from CMD"]
```

```bash
# Build image
docker build -t cmd-test .

# Run with default CMD
docker run cmd-test
# Output: Hello from CMD

# Override CMD
docker run cmd-test echo "Override CMD"
# Output: Override CMD

# Override with different command
docker run cmd-test ls -la
# Output: directory listing
```

**Complex CMD Examples:**

**Web Application:**
```dockerfile
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000

# Default command to start application
CMD ["npm", "start"]
```

**Python Application with Options:**
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 8000

# Start with Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "app:app"]
```

**Database Initialization:**
```dockerfile
FROM postgres:13
ENV POSTGRES_DB=myapp
ENV POSTGRES_USER=appuser
ENV POSTGRES_PASSWORD=secret

# Custom initialization script
COPY init.sql /docker-entrypoint-initdb.d/

# Use default PostgreSQL CMD (inherited from base image)
# CMD ["postgres"]
```

---

## 🚪 ENTRYPOINT - Container Entry Point

### Syntax
```dockerfile
# Exec form (preferred)
ENTRYPOINT ["executable", "param1", "param2"]

# Shell form
ENTRYPOINT command param1 param2
```

### Detailed Examples

**Basic ENTRYPOINT:**
```dockerfile
# Always run this executable
ENTRYPOINT ["python", "app.py"]
```

**Expected Build Output:**
```
Step 28/35 : ENTRYPOINT ["python", "app.py"]
 ---> k7l8m9n0o1p2
```

**ENTRYPOINT vs CMD:**

| Aspect | ENTRYPOINT | CMD |
|--------|------------|-----|
| **Override behavior** | Cannot override executable | Can override completely |
| **Runtime args** | Appended as arguments | Replace entire command |
| **Use case** | Fixed executable | Flexible command |

**ENTRYPOINT + CMD Pattern:**
```dockerfile
# ENTRYPOINT defines the executable
ENTRYPOINT ["python", "app.py"]

# CMD provides default arguments
CMD ["--port", "8000", "--workers", "4"]
```

**Runtime Behavior:**
```bash
# Build image
docker build -t entrypoint-test .

# Run with default arguments
docker run entrypoint-test
# Executes: python app.py --port 8000 --workers 4

# Run with custom arguments
docker run entrypoint-test --port 9000 --debug
# Executes: python app.py --port 9000 --debug

# Cannot override the executable (python app.py)
docker run entrypoint-test echo "hello"
# Still executes: python app.py echo hello (likely causes error)
```

**Advanced ENTRYPOINT Patterns:**

**Script-Based ENTRYPOINT:**
```dockerfile
# Create entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["python", "app.py"]
```

**docker-entrypoint.sh:**
```bash
#!/bin/bash
set -e

# Initialize database if needed
if [ "$1" = 'python' ] && [ "$2" = 'app.py' ]; then
    echo "Initializing application..."
    python manage.py migrate
    python manage.py collectstatic --noinput
fi

# Execute the main command
exec "$@"
```

**Expected Build Output:**
```
Step 29/35 : COPY docker-entrypoint.sh /usr/local/bin/
 ---> l8m9n0o1p2q3

Step 30/35 : RUN chmod +x /usr/local/bin/docker-entrypoint.sh
 ---> Running in m9n0o1p2q3r4
Removing intermediate container m9n0o1p2q3r4
 ---> n0o1p2q3r4s5

Step 31/35 : ENTRYPOINT ["docker-entrypoint.sh"]
 ---> o1p2q3r4s5t6
```

**Multi-Purpose Container:**
```dockerfile
FROM alpine:3.17

# Install multiple tools
RUN apk add --no-cache curl wget jq

# Create entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]
```

**entrypoint.sh:**
```bash
#!/bin/sh

case "$1" in
    curl)
        shift
        exec curl "$@"
        ;;
    wget)
        shift
        exec wget "$@"
        ;;
    jq)
        shift
        exec jq "$@"
        ;;
    --help)
        echo "Usage: $0 {curl|wget|jq} [options]"
        exit 0
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac
```

**Usage Examples:**
```bash
# Build multi-tool image
docker build -t multi-tool .

# Use as curl
docker run multi-tool curl -s https://api.github.com/users/octocat

# Use as wget
docker run multi-tool wget -qO- https://httpbin.org/ip

# Use as jq
echo '{"name":"John","age":30}' | docker run -i multi-tool jq '.name'

# Show help
docker run multi-tool --help
```

---

## 💾 VOLUME - Mount Points

### Syntax
```dockerfile
VOLUME ["/data"]
VOLUME ["/var/log", "/var/db"]
VOLUME /var/log /var/db
```

### Detailed Examples

**Basic Volume Declaration:**
```dockerfile
# Declare volume mount point
VOLUME ["/data"]
```

**Expected Build Output:**
```
Step 32/40 : VOLUME ["/data"]
 ---> p2q3r4s5t6u7
```

**Multiple Volumes:**
```dockerfile
# Multiple volumes in one instruction
VOLUME ["/app/data", "/app/logs", "/app/config"]

# Multiple volumes separately
VOLUME /var/lib/mysql
VOLUME /var/log/mysql
VOLUME /etc/mysql/conf.d
```

**Database Volume Example:**
```dockerfile
FROM postgres:13

# Declare data directory as volume
VOLUME ["/var/lib/postgresql/data"]

# This creates an anonymous volume if no volume is mounted
```

**Application Volume Example:**
```dockerfile
FROM node:16-alpine
WORKDIR /app

# Copy application files
COPY package*.json ./
RUN npm ci --only=production
COPY . .

# Declare volume for user uploads
VOLUME ["/app/uploads"]

# Declare volume for logs
VOLUME ["/app/logs"]

EXPOSE 3000
CMD ["npm", "start"]
```

**Volume Behavior:**
```bash
# Build image with volumes
docker build -t volume-test .

# Run without explicit volume mount
docker run -d --name test1 volume-test

# Check created volumes
docker inspect test1 --format='{{range .Mounts}}{{.Source}} -> {{.Destination}}{{end}}'
```

**Expected Output:**
```
/var/lib/docker/volumes/a1b2c3d4e5f6/_data -> /app/uploads
/var/lib/docker/volumes/g7h8i9j0k1l2/_data -> /app/logs
```

**Volume vs Bind Mount:**
```dockerfile
# Dockerfile declares volume
VOLUME ["/data"]
```

```bash
# Anonymous volume (Docker manages)
docker run -d --name auto-volume myapp

# Named volume (explicit)
docker run -d --name named-volume -v mydata:/data myapp

# Bind mount (host directory)
docker run -d --name bind-mount -v /host/data:/data myapp
```

**Volume Initialization:**
```dockerfile
FROM alpine:3.17

# Create directory and add initial data
RUN mkdir -p /app/data && \
    echo "Initial data" > /app/data/readme.txt

# Declare as volume
VOLUME ["/app/data"]

# When container runs:
# 1. If no volume mounted: anonymous volume created with initial data
# 2. If empty volume mounted: initial data copied to volume
# 3. If non-empty volume mounted: existing data preserved
```

---

## 🔧 ARG - Build Arguments

### Syntax
```dockerfile
ARG <name>[=<default value>]
```

### Detailed Examples

**Basic Build Arguments:**
```dockerfile
# Define build argument with default
ARG NODE_VERSION=16

# Use in FROM instruction
FROM node:${NODE_VERSION}-alpine
```

**Expected Build Output:**
```
Step 1/10 : ARG NODE_VERSION=16
 ---> q3r4s5t6u7v8

Step 2/10 : FROM node:${NODE_VERSION}-alpine
16-alpine: Pulling from library/node
...
```

**Build with Custom Argument:**
```bash
# Build with default value
docker build -t myapp .

# Build with custom value
docker build --build-arg NODE_VERSION=18 -t myapp:node18 .
```

**Multiple Build Arguments:**
```dockerfile
# Define multiple arguments
ARG BUILD_DATE
ARG VERSION=1.0.0
ARG GIT_COMMIT
ARG ENVIRONMENT=production

# Use in labels
LABEL build.date=$BUILD_DATE \
      build.version=$VERSION \
      build.commit=$GIT_COMMIT \
      build.environment=$ENVIRONMENT

# Use in environment variables
ENV APP_VERSION=$VERSION \
    APP_ENVIRONMENT=$ENVIRONMENT
```

**Build with Multiple Arguments:**
```bash
docker build \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg VERSION=2.1.0 \
  --build-arg GIT_COMMIT=$(git rev-parse HEAD) \
  --build-arg ENVIRONMENT=staging \
  -t myapp:2.1.0 .
```

**Expected Build Output:**
```
Step 3/15 : ARG BUILD_DATE
 ---> r4s5t6u7v8w9

Step 4/15 : ARG VERSION=1.0.0
 ---> s5t6u7v8w9x0

Step 5/15 : LABEL build.date=$BUILD_DATE       build.version=$VERSION       build.commit=$GIT_COMMIT       build.environment=$ENVIRONMENT
 ---> t6u7v8w9x0y1
```

**Conditional Logic with ARG:**
```dockerfile
ARG INSTALL_DEV_DEPS=false

# Base packages
RUN apt-get update && apt-get install -y \
    curl \
    wget

# Conditional development packages
RUN if [ "$INSTALL_DEV_DEPS" = "true" ]; then \
        apt-get install -y \
            vim \
            git \
            build-essential; \
    fi
```

**Build Variants:**
```bash
# Production build (minimal)
docker build -t myapp:prod .

# Development build (with dev tools)
docker build --build-arg INSTALL_DEV_DEPS=true -t myapp:dev .
```

**ARG Scope and Persistence:**
```dockerfile
# ARG before FROM is global
ARG GLOBAL_ARG=value

FROM ubuntu:20.04

# ARG after FROM is stage-specific
ARG STAGE_ARG=value

# ARG values don't persist to runtime
RUN echo "Build arg: $STAGE_ARG"

# To make available at runtime, use ENV
ENV RUNTIME_VAR=$STAGE_ARG
```

**Multi-Stage ARG Usage:**
```dockerfile
# Global ARG
ARG NODE_VERSION=16

# Build stage
FROM node:${NODE_VERSION}-alpine AS builder
ARG BUILD_ENV=production
RUN echo "Building for: $BUILD_ENV"

# Production stage
FROM nginx:alpine AS production
ARG NGINX_VERSION
RUN echo "Using Nginx: $NGINX_VERSION"

# ARG values need to be redeclared in each stage
```

---

## 🏥 HEALTHCHECK - Container Health Monitoring

### Syntax
```dockerfile
HEALTHCHECK [OPTIONS] CMD command
HEALTHCHECK NONE
```

### All Available Options
```dockerfile
--interval=DURATION     # Time between checks (default: 30s)
--timeout=DURATION      # Time to wait for check (default: 30s)
--start-period=DURATION # Grace period before checks start (default: 0s)
--retries=N            # Consecutive failures needed to mark unhealthy (default: 3)
```

### Detailed Examples

**Basic Health Check:**
```dockerfile
# Simple HTTP health check
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1
```

**Expected Build Output:**
```
Step 35/45 : HEALTHCHECK --interval=30s --timeout=3s --retries=3   CMD curl -f http://localhost:8000/health || exit 1
 ---> u7v8w9x0y1z2
```

**Web Application Health Check:**
```dockerfile
FROM node:16-alpine
WORKDIR /app

# Install curl for health checks
RUN apk add --no-cache curl

COPY package*.json ./
RUN npm ci --only=production
COPY . .

EXPOSE 3000

# Health check endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

CMD ["npm", "start"]
```

**Database Health Check:**
```dockerfile
FROM postgres:13

# Health check using pg_isready
HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
  CMD pg_isready -U $POSTGRES_USER -d $POSTGRES_DB || exit 1
```

**Custom Health Check Script:**
```dockerfile
FROM python:3.11-slim

# Copy health check script
COPY health-check.py /usr/local/bin/
RUN chmod +x /usr/local/bin/health-check.py

# Health check using custom script
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD python /usr/local/bin/health-check.py
```

**health-check.py:**
```python
#!/usr/bin/env python3
import sys
import requests
import psycopg2

def check_web_service():
    try:
        response = requests.get('http://localhost:8000/health', timeout=5)
        return response.status_code == 200
    except:
        return False

def check_database():
    try:
        conn = psycopg2.connect(
            host='localhost',
            database='myapp',
            user='appuser',
            password='secret'
        )
        conn.close()
        return True
    except:
        return False

if __name__ == '__main__':
    if check_web_service() and check_database():
        sys.exit(0)  # Healthy
    else:
        sys.exit(1)  # Unhealthy
```

**Health Check Testing:**
```bash
# Build image with health check
docker build -t health-app .

# Run container
docker run -d --name health-test health-app

# Check health status
docker ps
# STATUS column shows health status

# Get detailed health info
docker inspect health-test --format='{{json .State.Health}}' | jq
```

**Expected Health Status Output:**
```json
{
  "Status": "healthy",
  "FailingStreak": 0,
  "Log": [
    {
      "Start": "2024-01-15T10:30:00.123456789Z",
      "End": "2024-01-15T10:30:00.234567890Z",
      "ExitCode": 0,
      "Output": ""
    }
  ]
}
```

**Disable Health Check:**
```dockerfile
# Disable inherited health check
HEALTHCHECK NONE
```

---

## ⏹️ STOPSIGNAL - Container Stop Signal

### Syntax
```dockerfile
STOPSIGNAL signal
```

### Detailed Examples

**Default Stop Signal:**
```dockerfile
# Default is SIGTERM (15)
# Most applications handle SIGTERM gracefully
```

**Custom Stop Signal:**
```dockerfile
# Use SIGQUIT for Nginx
STOPSIGNAL SIGQUIT

# Use SIGINT for Node.js applications
STOPSIGNAL SIGINT

# Use signal number
STOPSIGNAL 9
```

**Expected Build Output:**
```
Step 36/45 : STOPSIGNAL SIGQUIT
 ---> v8w9x0y1z2a3
```

**Application-Specific Signals:**

**Nginx Configuration:**
```dockerfile
FROM nginx:alpine

# Nginx handles SIGQUIT for graceful shutdown
STOPSIGNAL SIGQUIT

# Copy custom configuration
COPY nginx.conf /etc/nginx/nginx.conf
```

**Node.js Application:**
```dockerfile
FROM node:16-alpine
WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production
COPY . .

# Node.js applications typically handle SIGINT
STOPSIGNAL SIGINT

EXPOSE 3000
CMD ["node", "server.js"]
```

**Python Application with Signal Handling:**
```dockerfile
FROM python:3.11-slim
WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .

# Python app handles SIGTERM
STOPSIGNAL SIGTERM

CMD ["python", "app.py"]
```

**Signal Handling in Application:**
```python
# app.py
import signal
import sys
import time

def signal_handler(sig, frame):
    print(f'Received signal {sig}, shutting down gracefully...')
    # Cleanup code here
    sys.exit(0)

# Register signal handlers
signal.signal(signal.SIGTERM, signal_handler)
signal.signal(signal.SIGINT, signal_handler)

print('Application starting...')
try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    signal_handler(signal.SIGINT, None)
```

**Testing Stop Signals:**
```bash
# Build and run container
docker build -t signal-test .
docker run -d --name test-signals signal-test

# Stop with default timeout (10 seconds)
docker stop test-signals

# Stop with custom timeout
docker stop -t 30 test-signals

# Force kill (SIGKILL)
docker kill test-signals
```

---

## 🐚 SHELL - Default Shell

### Syntax
```dockerfile
SHELL ["executable", "parameters"]
```

### Detailed Examples

**Default Shell Override:**
```dockerfile
# Change default shell from /bin/sh to /bin/bash
SHELL ["/bin/bash", "-c"]

# Now RUN instructions use bash
RUN echo "Using bash: $BASH_VERSION"
```

**Expected Build Output:**
```
Step 37/45 : SHELL ["/bin/bash", "-c"]
 ---> w9x0y1z2a3b4

Step 38/45 : RUN echo "Using bash: $BASH_VERSION"
 ---> Running in x0y1z2a3b4c5
Using bash: 5.1.16(1)-release
Removing intermediate container x0y1z2a3b4c5
 ---> y1z2a3b4c5d6
```

**PowerShell on Windows:**
```dockerfile
# Windows container with PowerShell
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Use PowerShell as default shell
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# PowerShell commands
RUN Write-Host 'Using PowerShell'
RUN Get-ChildItem C:\
```

**Advanced Shell Configuration:**
```dockerfile
FROM ubuntu:20.04

# Install bash and set as default
RUN apt-get update && apt-get install -y bash
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Now all RUN commands use bash with pipefail
RUN curl -s https://example.com/script.sh | bash
```

**Shell Options Explained:**
- `-c`: Execute command
- `-o pipefail`: Fail if any command in pipeline fails
- `-e`: Exit on error
- `-x`: Print commands before execution

---

## 🔄 ONBUILD - Trigger Instructions

### Syntax
```dockerfile
ONBUILD <INSTRUCTION>
```

### Detailed Examples

**Base Image with ONBUILD:**
```dockerfile
# base-node-app/Dockerfile
FROM node:16-alpine
WORKDIR /app

# These instructions run when child image is built
ONBUILD COPY package*.json ./
ONBUILD RUN npm ci --only=production
ONBUILD COPY . .

EXPOSE 3000
CMD ["npm", "start"]
```

**Expected Build Output:**
```
Step 39/45 : ONBUILD COPY package*.json ./
 ---> z2a3b4c5d6e7

Step 40/45 : ONBUILD RUN npm ci --only=production
 ---> a3b4c5d6e7f8

Step 41/45 : ONBUILD COPY . .
 ---> b4c5d6e7f8g9
```

**Child Image Using ONBUILD Base:**
```dockerfile
# my-app/Dockerfile
FROM base-node-app

# ONBUILD instructions from base image execute here automatically
# No need to repeat COPY and RUN instructions
```

**Child Image Build Output:**
```
Step 1/1 : FROM base-node-app
# Executing 3 build triggers
 ---> ONBUILD COPY package*.json ./
 ---> ONBUILD RUN npm ci --only=production
Removing intermediate container c5d6e7f8g9h0
 ---> ONBUILD COPY . .
 ---> d6e7f8g9h0i1
```

**Python Base Image Example:**
```dockerfile
# python-base/Dockerfile
FROM python:3.11-slim
WORKDIR /app

# Install common dependencies
RUN pip install --no-cache-dir gunicorn

# ONBUILD instructions for child images
ONBUILD COPY requirements.txt .
ONBUILD RUN pip install --no-cache-dir -r requirements.txt
ONBUILD COPY . .

EXPOSE 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]
```

**ONBUILD Best Practices:**
```dockerfile
# Good: Copy dependency files first for better caching
ONBUILD COPY requirements.txt package.json ./
ONBUILD RUN pip install -r requirements.txt || npm install

# Good: Copy source code last
ONBUILD COPY . .

# Avoid: Complex logic in ONBUILD
# ONBUILD RUN if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
```

---

## 🚀 Complete Dockerfile Example

### Production-Ready Multi-Stage Dockerfile

```dockerfile
# Build arguments
ARG NODE_VERSION=16
ARG NGINX_VERSION=alpine

# Build stage
FROM node:${NODE_VERSION}-alpine AS builder

# Build metadata
ARG BUILD_DATE
ARG VERSION
ARG GIT_COMMIT
LABEL build.date=$BUILD_DATE \
      build.version=$VERSION \
      build.commit=$GIT_COMMIT

# Install build dependencies
RUN apk add --no-cache python3 make g++

# Set working directory
WORKDIR /app

# Copy dependency files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Copy source code
COPY . .

# Build application
RUN npm run build

# Production stage
FROM nginx:${NGINX_VERSION} AS production

# Install curl for health checks
RUN apk add --no-cache curl

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Copy built application
COPY --from=builder --chown=nextjs:nodejs /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Set stop signal
STOPSIGNAL SIGQUIT

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# Expose port
EXPOSE 80

# Switch to non-root user
USER nextjs

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
```

**Build and Run:**
```bash
# Build with arguments
docker build \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg VERSION=1.0.0 \
  --build-arg GIT_COMMIT=$(git rev-parse HEAD) \
  -t myapp:1.0.0 .

# Run container
docker run -d -p 80:80 --name myapp myapp:1.0.0

# Check health
docker ps
```

---

## 🚀 Next Steps

You now have complete mastery of advanced Dockerfile instructions:

- ✅ **CMD**: Default container commands and override behavior
- ✅ **ENTRYPOINT**: Fixed entry points and argument handling
- ✅ **VOLUME**: Volume declarations and mount points
- ✅ **ARG**: Build-time arguments and conditional logic
- ✅ **HEALTHCHECK**: Container health monitoring
- ✅ **STOPSIGNAL**: Graceful shutdown configuration
- ✅ **SHELL**: Custom shell configuration
- ✅ **ONBUILD**: Trigger instructions for base images

**Ready for Part 3: Multi-Stage Builds and Optimization** where you'll learn to create minimal, secure, and efficient Docker images!
