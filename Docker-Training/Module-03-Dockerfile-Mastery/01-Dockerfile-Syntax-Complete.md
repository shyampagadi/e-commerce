# 🐳 Dockerfile Syntax: Complete Expert Guide

## 🎯 Learning Objectives
- Master every Dockerfile instruction with all options
- Understand build context and layer optimization
- Learn advanced build techniques and patterns
- Debug Dockerfile issues like an expert

---

## 📚 Dockerfile Fundamentals

### What is a Dockerfile?
A **Dockerfile** is a text file containing a series of instructions that Docker uses to build an image automatically. Think of it as a recipe that tells Docker exactly how to create your custom image.

### Dockerfile Structure
```dockerfile
# Comments start with #
INSTRUCTION arguments
INSTRUCTION arguments
...
```

### Build Process Flow
```
Dockerfile → docker build → Docker Image → docker run → Container
     ↓              ↓              ↓             ↓           ↓
   Recipe      Build Process   Template      Create     Running App
```

---

## 🏗️ FROM - Base Image Selection

### Syntax
```dockerfile
FROM [--platform=<platform>] <image>[:<tag>] [AS <name>]
```

### All Available Options
```dockerfile
--platform=<platform>    # Specify platform for multi-platform builds
AS <name>               # Name this build stage for multi-stage builds
```

### Detailed Examples

**Basic Base Image:**
```dockerfile
# Use official Ubuntu 20.04
FROM ubuntu:20.04
```

**Expected Build Output:**
```
Step 1/1 : FROM ubuntu:20.04
20.04: Pulling from library/ubuntu
7b1a6ab2e44d: Pull complete 
Digest: sha256:626ffe58f6e7566e00254b638eb7e0f3b11d4da9675088f4781a50ae288f3322
Status: Downloaded newer image for ubuntu:20.04
 ---> ba6acccedd29
```

**Specific Version Tags:**
```dockerfile
# Use specific Node.js version
FROM node:16.19.0-alpine

# Use Python with specific patch version
FROM python:3.11.1-slim

# Use latest (not recommended for production)
FROM nginx:latest
```

**Platform-Specific Images:**
```dockerfile
# Specify platform for multi-architecture builds
FROM --platform=linux/amd64 node:16-alpine
FROM --platform=linux/arm64 python:3.11-slim
```

**Expected Build Output:**
```
Step 1/1 : FROM --platform=linux/amd64 node:16-alpine
16-alpine: Pulling from library/node
63b65145d645: Pull complete 
fce3d4d00afa: Pull complete 
7db8b8c62e8d: Pull complete 
Digest: sha256:8dafc0968fb4d62834d9b826d85a8feecc69bd72cd51723c62c7db67c6dec6fa
Status: Downloaded newer image for node:16-alpine
 ---> bef258acf10d
```

**Multi-Stage Build Names:**
```dockerfile
# Build stage
FROM node:16-alpine AS builder
# ... build instructions

# Production stage  
FROM nginx:alpine AS production
# ... production setup
```

**Common Base Images Explained:**

**Alpine Linux (Minimal):**
```dockerfile
FROM alpine:3.17
# Size: ~5MB
# Use case: Minimal production images
# Package manager: apk
```

**Ubuntu (Full-featured):**
```dockerfile
FROM ubuntu:20.04
# Size: ~72MB
# Use case: Development, complex applications
# Package manager: apt
```

**Debian Slim:**
```dockerfile
FROM debian:11-slim
# Size: ~80MB
# Use case: Balance between size and features
# Package manager: apt
```

**Scratch (Empty):**
```dockerfile
FROM scratch
# Size: 0MB
# Use case: Static binaries, minimal containers
# No shell, no package manager
```

---

## 🏷️ LABEL - Image Metadata

### Syntax
```dockerfile
LABEL <key>=<value> <key>=<value> <key>=<value> ...
```

### Detailed Examples

**Basic Labels:**
```dockerfile
# Single label
LABEL version="1.0"

# Multiple labels in one instruction (preferred)
LABEL maintainer="developer@company.com" \
      version="1.0" \
      description="E-commerce web application" \
      vendor="My Company"
```

**Expected Build Output:**
```
Step 2/10 : LABEL maintainer="developer@company.com"       version="1.0"       description="E-commerce web application"       vendor="My Company"
 ---> Running in a1b2c3d4e5f6
Removing intermediate container a1b2c3d4e5f6
 ---> g7h8i9j0k1l2
```

**Standard Label Keys:**
```dockerfile
# OCI (Open Container Initiative) standard labels
LABEL org.opencontainers.image.title="My Application" \
      org.opencontainers.image.description="Production web application" \
      org.opencontainers.image.version="1.2.3" \
      org.opencontainers.image.created="2024-01-15T10:30:00Z" \
      org.opencontainers.image.revision="abc123def456" \
      org.opencontainers.image.source="https://github.com/company/app" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.vendor="My Company"
```

**Custom Application Labels:**
```dockerfile
# Application-specific metadata
LABEL app.environment="production" \
      app.team="backend" \
      app.monitoring.enabled="true" \
      app.backup.schedule="daily" \
      app.security.scan="passed"
```

**Verify Labels:**
```bash
# Build image with labels
docker build -t labeled-app .

# Inspect labels
docker inspect labeled-app --format='{{json .Config.Labels}}' | jq
```

**Expected Output:**
```json
{
  "app.environment": "production",
  "app.team": "backend",
  "maintainer": "developer@company.com",
  "org.opencontainers.image.title": "My Application",
  "version": "1.0"
}
```

---

## 🔧 RUN - Execute Commands

### Syntax
```dockerfile
# Shell form (runs in shell)
RUN <command>

# Exec form (direct execution)
RUN ["executable", "param1", "param2"]
```

### All Available Patterns

**Shell Form Examples:**
```dockerfile
# Simple command
RUN apt-get update

# Multiple commands with &&
RUN apt-get update && apt-get install -y curl

# Multi-line with backslash
RUN apt-get update && \
    apt-get install -y \
        curl \
        wget \
        vim && \
    rm -rf /var/lib/apt/lists/*
```

**Expected Build Output:**
```
Step 3/10 : RUN apt-get update &&     apt-get install -y         curl         wget         vim &&     rm -rf /var/lib/apt/lists/*
 ---> Running in b2c3d4e5f6g7
Get:1 http://archive.ubuntu.com/ubuntu focal InRelease [265 kB]
Get:2 http://archive.ubuntu.com/ubuntu focal-updates InRelease [114 kB]
...
Reading package lists...
Building dependency tree...
Reading state information...
The following NEW packages will be installed:
  curl wget vim
...
Removing intermediate container b2c3d4e5f6g7
 ---> h8i9j0k1l2m3
```

**Exec Form Examples:**
```dockerfile
# Direct execution (no shell interpretation)
RUN ["apt-get", "update"]
RUN ["apt-get", "install", "-y", "curl", "wget"]

# Useful when you need specific shell
RUN ["/bin/bash", "-c", "echo 'Hello World'"]
```

**Package Installation Patterns:**

**Ubuntu/Debian:**
```dockerfile
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        wget \
        ca-certificates \
        gnupg \
        lsb-release && \
    rm -rf /var/lib/apt/lists/*
```

**Alpine Linux:**
```dockerfile
RUN apk add --no-cache \
        curl \
        wget \
        ca-certificates \
        bash
```

**CentOS/RHEL:**
```dockerfile
RUN yum update -y && \
    yum install -y \
        curl \
        wget \
        ca-certificates && \
    yum clean all
```

**Application Installation Examples:**

**Node.js Application:**
```dockerfile
# Install Node.js dependencies
RUN npm ci --only=production && \
    npm cache clean --force
```

**Python Application:**
```dockerfile
# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir gunicorn
```

**Go Application:**
```dockerfile
# Build Go application
RUN go mod download && \
    CGO_ENABLED=0 GOOS=linux go build -o app .
```

**Complex Build Example:**
```dockerfile
RUN set -eux; \
    # Update package lists
    apt-get update; \
    # Install build dependencies
    apt-get install -y --no-install-recommends \
        build-essential \
        libssl-dev \
        libffi-dev \
        python3-dev; \
    # Install Python packages
    pip install --no-cache-dir -r requirements.txt; \
    # Remove build dependencies
    apt-get purge -y --auto-remove \
        build-essential \
        libssl-dev \
        libffi-dev \
        python3-dev; \
    # Clean up
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*
```

**Expected Build Output:**
```
Step 4/10 : RUN set -eux;     apt-get update;     apt-get install -y --no-install-recommends         build-essential         libssl-dev         libffi-dev         python3-dev;     pip install --no-cache-dir -r requirements.txt;     apt-get purge -y --auto-remove         build-essential         libssl-dev         libffi-dev         python3-dev;     apt-get clean;     rm -rf /var/lib/apt/lists/*
 ---> Running in c3d4e5f6g7h8
+ apt-get update
Hit:1 http://archive.ubuntu.com/ubuntu focal InRelease
...
+ apt-get install -y --no-install-recommends build-essential libssl-dev libffi-dev python3-dev
Reading package lists...
...
+ pip install --no-cache-dir -r requirements.txt
Collecting flask==2.0.1
...
+ apt-get purge -y --auto-remove build-essential libssl-dev libffi-dev python3-dev
Reading package lists...
...
Removing intermediate container c3d4e5f6g7h8
 ---> i9j0k1l2m3n4
```

---

## 📁 WORKDIR - Set Working Directory

### Syntax
```dockerfile
WORKDIR /path/to/workdir
```

### Detailed Examples

**Basic Working Directory:**
```dockerfile
# Set working directory
WORKDIR /app

# All subsequent commands run from /app
RUN pwd  # Will output: /app
```

**Expected Build Output:**
```
Step 5/10 : WORKDIR /app
 ---> Running in d4e5f6g7h8i9
Removing intermediate container d4e5f6g7h8i9
 ---> j0k1l2m3n4o5

Step 6/10 : RUN pwd
 ---> Running in e5f6g7h8i9j0
/app
Removing intermediate container e5f6g7h8i9j0
 ---> k1l2m3n4o5p6
```

**Multiple WORKDIR Instructions:**
```dockerfile
# Create nested directory structure
WORKDIR /app
WORKDIR src
WORKDIR components

# Equivalent to: WORKDIR /app/src/components
RUN pwd  # Will output: /app/src/components
```

**Relative and Absolute Paths:**
```dockerfile
# Absolute path
WORKDIR /usr/src/app

# Relative path (relative to current WORKDIR)
WORKDIR ./frontend

# Back to absolute
WORKDIR /opt/backend
```

**Environment Variable in WORKDIR:**
```dockerfile
# Set environment variable
ENV APP_HOME=/application

# Use in WORKDIR
WORKDIR $APP_HOME

# Verify
RUN echo "Current directory: $(pwd)"
```

**Expected Build Output:**
```
Step 7/10 : ENV APP_HOME=/application
 ---> Running in f6g7h8i9j0k1
Removing intermediate container f6g7h8i9j0k1
 ---> l2m3n4o5p6q7

Step 8/10 : WORKDIR $APP_HOME
 ---> Running in g7h8i9j0k1l2
Removing intermediate container g7h8i9j0k1l2
 ---> m3n4o5p6q7r8

Step 9/10 : RUN echo "Current directory: $(pwd)"
 ---> Running in h8i9j0k1l2m3
Current directory: /application
Removing intermediate container h8i9j0k1l2m3
 ---> n4o5p6q7r8s9
```

**Best Practices:**
```dockerfile
# Create directory if it doesn't exist
WORKDIR /app

# Better than using RUN mkdir + cd
# DON'T DO THIS:
# RUN mkdir /app && cd /app

# WORKDIR automatically creates the directory
WORKDIR /app/data/logs  # Creates entire path
```

---

## 📋 COPY and ADD - File Operations

### COPY Syntax
```dockerfile
COPY [--chown=<user>:<group>] [--chmod=<perms>] <src>... <dest>
COPY [--chown=<user>:<group>] [--chmod=<perms>] ["<src>",... "<dest>"]
```

### ADD Syntax
```dockerfile
ADD [--chown=<user>:<group>] [--chmod=<perms>] <src>... <dest>
ADD [--chown=<user>:<group>] [--chmod=<perms>] ["<src>",... "<dest>"]
```

### All Available Options
```dockerfile
--chown=<user>:<group>    # Set ownership of copied files
--chmod=<permissions>     # Set permissions of copied files
```

### COPY Examples

**Basic File Copy:**
```dockerfile
# Copy single file
COPY app.py /app/

# Copy multiple files
COPY app.py requirements.txt /app/

# Copy with rename
COPY local-config.json /app/config.json
```

**Expected Build Output:**
```
Step 10/15 : COPY app.py requirements.txt /app/
 ---> o5p6q7r8s9t0
```

**Directory Copy:**
```dockerfile
# Copy entire directory
COPY src/ /app/src/

# Copy directory contents (note the trailing slash)
COPY src/ /app/

# Copy directory itself
COPY src /app/src
```

**Wildcard Patterns:**
```dockerfile
# Copy all Python files
COPY *.py /app/

# Copy all files with specific extension
COPY *.json /app/config/

# Copy files matching pattern
COPY requirements*.txt /app/
```

**Copy with Ownership:**
```dockerfile
# Copy and set ownership
COPY --chown=1000:1000 app.py /app/

# Copy with user and group names
COPY --chown=appuser:appgroup src/ /app/

# Copy with permissions
COPY --chmod=755 start.sh /app/
COPY --chmod=644 config.json /app/
```

**Expected Build Output:**
```
Step 11/15 : COPY --chown=1000:1000 app.py /app/
 ---> p6q7r8s9t0u1

Step 12/15 : COPY --chmod=755 start.sh /app/
 ---> q7r8s9t0u1v2
```

**Multi-Stage Copy:**
```dockerfile
# Copy from another build stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy from specific image
COPY --from=node:16-alpine /usr/local/bin/node /usr/local/bin/
```

### ADD Examples

**Basic ADD (Similar to COPY):**
```dockerfile
# Basic file addition
ADD app.py /app/
```

**URL Download:**
```dockerfile
# Download file from URL
ADD https://github.com/user/repo/archive/main.tar.gz /tmp/

# Download and extract
ADD https://example.com/archive.tar.gz /app/
```

**Expected Build Output:**
```
Step 13/15 : ADD https://github.com/user/repo/archive/main.tar.gz /tmp/
Downloading [==================================================>]  1.234MB/1.234MB
 ---> r8s9t0u1v2w3
```

**Automatic Extraction:**
```dockerfile
# ADD automatically extracts tar files
ADD app.tar.gz /app/

# This extracts the contents of app.tar.gz to /app/
# Equivalent to: RUN tar -xzf app.tar.gz -C /app && rm app.tar.gz
```

**COPY vs ADD Comparison:**

| Feature | COPY | ADD |
|---------|------|-----|
| Local files | ✅ | ✅ |
| URL download | ❌ | ✅ |
| Auto-extract tar | ❌ | ✅ |
| Security | ✅ Better | ⚠️ More features = more risk |
| Recommendation | ✅ Preferred | ⚠️ Use only when needed |

**Best Practices:**
```dockerfile
# PREFERRED: Use COPY for local files
COPY requirements.txt /app/
COPY src/ /app/src/

# USE ADD ONLY FOR:
# 1. URL downloads
ADD https://releases.example.com/app.tar.gz /tmp/

# 2. Automatic tar extraction
ADD app.tar.gz /app/

# DON'T USE ADD for simple file copying
# ADD app.py /app/  # Wrong - use COPY instead
```

---

## 🌍 ENV - Environment Variables

### Syntax
```dockerfile
ENV <key>=<value> ...
ENV <key> <value>
```

### Detailed Examples

**Single Environment Variable:**
```dockerfile
# Set single variable
ENV NODE_ENV=production
```

**Expected Build Output:**
```
Step 14/20 : ENV NODE_ENV=production
 ---> s9t0u1v2w3x4
```

**Multiple Environment Variables:**
```dockerfile
# Multiple variables in one instruction (preferred)
ENV NODE_ENV=production \
    PORT=3000 \
    DATABASE_URL=postgresql://localhost:5432/myapp \
    LOG_LEVEL=info
```

**Environment Variable Types:**

**Application Configuration:**
```dockerfile
ENV APP_NAME="E-Commerce API" \
    APP_VERSION="1.2.3" \
    APP_ENVIRONMENT="production" \
    APP_DEBUG="false"
```

**Database Configuration:**
```dockerfile
ENV DB_HOST=localhost \
    DB_PORT=5432 \
    DB_NAME=ecommerce \
    DB_USER=app_user \
    DB_POOL_SIZE=10
```

**Path Configuration:**
```dockerfile
ENV PATH="/app/bin:${PATH}" \
    PYTHONPATH="/app/src" \
    NODE_PATH="/app/node_modules"
```

**Using Environment Variables:**
```dockerfile
# Set environment variable
ENV APP_HOME=/application

# Use in subsequent instructions
WORKDIR $APP_HOME
COPY app.py $APP_HOME/
RUN echo "App installed in: $APP_HOME"
```

**Expected Build Output:**
```
Step 15/20 : ENV APP_HOME=/application
 ---> t0u1v2w3x4y5

Step 16/20 : WORKDIR $APP_HOME
 ---> u1v2w3x4y5z6

Step 17/20 : RUN echo "App installed in: $APP_HOME"
 ---> Running in v2w3x4y5z6a7
App installed in: /application
Removing intermediate container v2w3x4y5z6a7
 ---> w3x4y5z6a7b8
```

**Runtime vs Build-time Variables:**
```dockerfile
# ENV variables are available at runtime
ENV RUNTIME_CONFIG=production

# ARG variables are only available during build
ARG BUILD_VERSION=1.0.0

# Use ARG in ENV for runtime availability
ENV APP_VERSION=$BUILD_VERSION
```

**Complex Environment Setup:**
```dockerfile
# Development environment
ENV NODE_ENV=development \
    DEBUG=true \
    LOG_LEVEL=debug \
    WATCH_FILES=true \
    HOT_RELOAD=true

# Production environment (override in production)
# ENV NODE_ENV=production \
#     DEBUG=false \
#     LOG_LEVEL=info \
#     WATCH_FILES=false \
#     HOT_RELOAD=false
```

---

## 🚪 EXPOSE - Document Ports

### Syntax
```dockerfile
EXPOSE <port> [<port>/<protocol>...]
```

### Detailed Examples

**Basic Port Exposure:**
```dockerfile
# Expose HTTP port
EXPOSE 80

# Expose HTTPS port
EXPOSE 443

# Expose custom application port
EXPOSE 3000
```

**Expected Build Output:**
```
Step 18/25 : EXPOSE 80
 ---> x4y5z6a7b8c9

Step 19/25 : EXPOSE 443
 ---> y5z6a7b8c9d0

Step 20/25 : EXPOSE 3000
 ---> z6a7b8c9d0e1
```

**Protocol Specification:**
```dockerfile
# TCP port (default)
EXPOSE 80/tcp

# UDP port
EXPOSE 53/udp

# Both TCP and UDP
EXPOSE 80/tcp 80/udp
```

**Multiple Ports:**
```dockerfile
# Multiple ports in one instruction
EXPOSE 80 443 3000

# Different protocols
EXPOSE 80/tcp 443/tcp 53/udp 123/udp
```

**Common Port Patterns:**

**Web Applications:**
```dockerfile
# Standard web ports
EXPOSE 80 443

# Development server
EXPOSE 3000 3001

# API server
EXPOSE 8000 8080
```

**Database Services:**
```dockerfile
# PostgreSQL
EXPOSE 5432

# MySQL
EXPOSE 3306

# MongoDB
EXPOSE 27017

# Redis
EXPOSE 6379
```

**Microservices:**
```dockerfile
# Service ports
EXPOSE 8080  # Main service
EXPOSE 8081  # Health check
EXPOSE 8082  # Metrics
EXPOSE 8083  # Admin interface
```

**Important Notes:**
```dockerfile
# EXPOSE does NOT publish ports
# It only documents which ports the container listens on
EXPOSE 3000

# To actually publish ports, use -p flag when running:
# docker run -p 3000:3000 myapp
```

**Verify Exposed Ports:**
```bash
# Build image
docker build -t myapp .

# Check exposed ports
docker inspect myapp --format='{{.Config.ExposedPorts}}'
```

**Expected Output:**
```
map[3000/tcp:{} 80/tcp:{} 443/tcp:{}]
```

---

## 👤 USER - Set User Context

### Syntax
```dockerfile
USER <user>[:<group>]
USER <UID>[:<GID>]
```

### Detailed Examples

**Basic User Switch:**
```dockerfile
# Switch to existing user
USER nginx

# Switch to user by UID
USER 1000

# Switch to user and group
USER appuser:appgroup
USER 1000:1000
```

**Expected Build Output:**
```
Step 21/30 : USER 1000:1000
 ---> a7b8c9d0e1f2
```

**Create User and Switch:**
```dockerfile
# Create user and group
RUN groupadd -r appgroup && \
    useradd -r -g appgroup -s /bin/bash -d /app appuser

# Switch to the user
USER appuser
```

**Expected Build Output:**
```
Step 22/30 : RUN groupadd -r appgroup &&     useradd -r -g appgroup -s /bin/bash -d /app appuser
 ---> Running in b8c9d0e1f2g3
Removing intermediate container b8c9d0e1f2g3
 ---> c9d0e1f2g3h4

Step 23/30 : USER appuser
 ---> d0e1f2g3h4i5
```

**Alpine Linux User Creation:**
```dockerfile
# Alpine uses different commands
RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup

USER appuser
```

**Security Best Practices:**
```dockerfile
# DON'T run as root in production
# USER root  # Dangerous!

# DO create and use non-root user
RUN groupadd -r appuser && \
    useradd -r -g appuser -d /app -s /sbin/nologin appuser

# Set ownership of app directory
COPY --chown=appuser:appuser . /app

# Switch to non-root user
USER appuser
```

**User Context for Different Operations:**
```dockerfile
# Install packages as root
USER root
RUN apt-get update && apt-get install -y curl

# Create application user
RUN useradd -m -s /bin/bash appuser

# Copy files with correct ownership
COPY --chown=appuser:appuser app.py /app/

# Switch to app user for runtime
USER appuser

# All subsequent instructions run as appuser
WORKDIR /app
CMD ["python", "app.py"]
```

**Verify User Context:**
```dockerfile
# Check current user
RUN whoami
RUN id
```

**Expected Build Output:**
```
Step 24/30 : RUN whoami
 ---> Running in e1f2g3h4i5j6
appuser
Removing intermediate container e1f2g3h4i5j6
 ---> f2g3h4i5j6k7

Step 25/30 : RUN id
 ---> Running in g3h4i5j6k7l8
uid=1000(appuser) gid=1000(appuser) groups=1000(appuser)
Removing intermediate container g3h4i5j6k7l8
 ---> h4i5j6k7l8m9
```

---

## 🚀 Next Steps

You now understand the fundamental Dockerfile instructions with complete detail:

- ✅ **FROM**: Base image selection with platform options
- ✅ **LABEL**: Comprehensive metadata management
- ✅ **RUN**: Command execution with optimization patterns
- ✅ **WORKDIR**: Working directory management
- ✅ **COPY/ADD**: File operations with ownership and permissions
- ✅ **ENV**: Environment variable configuration
- ✅ **EXPOSE**: Port documentation
- ✅ **USER**: Security-focused user management

**Ready for Part 2: Advanced Dockerfile Instructions** where you'll master CMD, ENTRYPOINT, VOLUME, ARG, ONBUILD, STOPSIGNAL, HEALTHCHECK, and SHELL instructions!
