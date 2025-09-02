# Dockerfile Security Hardening Guide

## Table of Contents
1. [Security Fundamentals](#security-fundamentals)
2. [Base Image Security](#base-image-security)
3. [User and Permission Management](#user-and-permission-management)
4. [Secrets and Sensitive Data](#secrets-and-sensitive-data)
5. [Network Security](#network-security)
6. [Vulnerability Management](#vulnerability-management)
7. [Security Scanning and Tools](#security-scanning-and-tools)

## Security Fundamentals

### Security-First Dockerfile Structure
```dockerfile
# syntax=docker/dockerfile:1
# Use specific, minimal base image
FROM alpine:3.18.4

# Add security labels
LABEL security.scan="enabled"
LABEL security.policy="strict"
LABEL maintainer="security@company.com"

# Create non-root user first
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Install only necessary packages
RUN apk add --no-cache --update \
    ca-certificates \
    && apk upgrade \
    && rm -rf /var/cache/apk/*

# Set secure working directory
WORKDIR /app

# Copy with proper ownership
COPY --chown=appuser:appgroup . .

# Switch to non-root user
USER appuser

# Use exec form for CMD
CMD ["./app"]
```

### Security Checklist
- [ ] Use minimal base images
- [ ] Run as non-root user
- [ ] Use specific image tags
- [ ] Scan for vulnerabilities
- [ ] Handle secrets properly
- [ ] Minimize attack surface
- [ ] Implement health checks
- [ ] Use read-only filesystems

## Base Image Security

### 1. Choose Secure Base Images
```dockerfile
# ❌ Avoid full OS distributions
FROM ubuntu:latest
FROM centos:7

# ✅ Use minimal, security-focused images
FROM alpine:3.18.4          # Minimal Linux
FROM scratch                # Empty base
FROM gcr.io/distroless/java # Distroless images
FROM chainguard/node:latest # Chainguard images
```

### 2. Distroless Images
```dockerfile
# Multi-stage with distroless
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 go build -o app .

# Distroless production image
FROM gcr.io/distroless/static-debian11
COPY --from=builder /app/app /app
USER 1001
ENTRYPOINT ["/app"]
```

### 3. Scratch Images for Static Binaries
```dockerfile
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /app/app /app
USER 1001
ENTRYPOINT ["/app"]
```

## User and Permission Management

### 1. Non-Root User Implementation
```dockerfile
FROM alpine:3.18

# Method 1: Create user with specific UID/GID
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup -h /app -s /bin/sh

# Method 2: Use existing nobody user
# USER nobody

# Method 3: Numeric user (works with any base image)
# USER 1001:1001

WORKDIR /app
COPY --chown=appuser:appgroup . .
USER appuser
```

### 2. File Permissions and Ownership
```dockerfile
FROM alpine:3.18

RUN adduser -D -s /bin/sh appuser

# Set proper ownership during copy
COPY --chown=appuser:appuser --chmod=755 entrypoint.sh /usr/local/bin/
COPY --chown=appuser:appuser --chmod=644 config.json /app/

# Create directories with proper permissions
RUN mkdir -p /app/data && \
    chown -R appuser:appuser /app && \
    chmod -R 755 /app

USER appuser
```

### 3. Capability Management
```dockerfile
FROM alpine:3.18

# Drop all capabilities and add only necessary ones
# This is typically done at runtime, not in Dockerfile
LABEL security.capabilities="drop:ALL,add:NET_BIND_SERVICE"

# Document required capabilities
LABEL security.required-caps="NET_BIND_SERVICE"
LABEL security.dropped-caps="ALL"
```

## Secrets and Sensitive Data

### 1. Build Secrets with BuildKit
```dockerfile
# syntax=docker/dockerfile:1
FROM alpine:3.18

# Use build secrets (never stored in image)
RUN --mount=type=secret,id=api_key \
    API_KEY=$(cat /run/secrets/api_key) && \
    curl -H "Authorization: Bearer $API_KEY" \
         https://api.example.com/data > /app/data.json

# Build with: docker build --secret id=api_key,src=./api_key.txt .
```

### 2. Multi-Stage Secret Handling
```dockerfile
# Build stage with secrets
FROM alpine:3.18 AS builder
RUN --mount=type=secret,id=github_token \
    GITHUB_TOKEN=$(cat /run/secrets/github_token) && \
    git clone https://${GITHUB_TOKEN}@github.com/private/repo.git

# Production stage without secrets
FROM alpine:3.18 AS production
COPY --from=builder /repo/dist /app
USER 1001
```

### 3. Environment Variable Security
```dockerfile
# ❌ Don't embed secrets in ENV
ENV API_KEY=secret123
ENV DATABASE_PASSWORD=password

# ✅ Use runtime environment or secrets
ENV API_KEY_FILE=/run/secrets/api_key
ENV DATABASE_PASSWORD_FILE=/run/secrets/db_password

# Document expected environment variables
LABEL security.env-vars="API_KEY_FILE,DATABASE_PASSWORD_FILE"
```

## Network Security

### 1. Minimal Network Exposure
```dockerfile
FROM alpine:3.18

# Only expose necessary ports
EXPOSE 8080

# Document port usage
LABEL network.ports="8080:http"
LABEL network.protocols="tcp"

# Use specific bind addresses in application
ENV BIND_ADDRESS=127.0.0.1
ENV PORT=8080
```

### 2. Network Security Labels
```dockerfile
FROM alpine:3.18

# Security metadata
LABEL network.ingress="restricted"
LABEL network.egress="internet"
LABEL security.firewall="required"
LABEL security.tls="required"
```

## Vulnerability Management

### 1. Package Management Security
```dockerfile
FROM alpine:3.18

# Update package database and upgrade
RUN apk update && apk upgrade

# Install packages with no-cache to avoid stale packages
RUN apk add --no-cache --update \
    ca-certificates \
    curl \
    && rm -rf /var/cache/apk/*

# Remove package manager after installation (if not needed)
RUN apk del apk-tools
```

### 2. Dependency Scanning
```dockerfile
FROM node:18-alpine

# Copy package files first for vulnerability scanning
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Audit dependencies
RUN npm audit --audit-level=high

# Copy application code
COPY . .
```

### 3. Regular Updates
```dockerfile
# Use specific versions with update strategy
FROM alpine:3.18.4  # Specific patch version

# Document update schedule
LABEL security.update-schedule="monthly"
LABEL security.last-updated="2024-01-15"
LABEL security.next-update="2024-02-15"
```

## Security Scanning and Tools

### 1. Trivy Integration
```dockerfile
# .trivyignore file for known acceptable vulnerabilities
# CVE-2023-1234  # Fixed in next release
# CVE-2023-5678  # Not applicable to our use case

FROM alpine:3.18

# Scan during build
RUN apk add --no-cache trivy
RUN trivy fs --exit-code 1 --severity HIGH,CRITICAL /
```

### 2. Hadolint for Dockerfile Linting
```dockerfile
# syntax=docker/dockerfile:1
# hadolint ignore=DL3008,DL3009
FROM ubuntu:20.04

# Properly pin package versions
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl=7.68.0-1ubuntu2.14 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
```

### 3. Security Scanning Pipeline
```yaml
# .gitlab-ci.yml security stage
security_scan:
  stage: security
  image: aquasec/trivy:latest
  script:
    - trivy image --exit-code 1 --severity HIGH,CRITICAL $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  allow_failure: false
```

## Advanced Security Patterns

### 1. Read-Only Root Filesystem
```dockerfile
FROM alpine:3.18

# Create necessary writable directories
RUN mkdir -p /tmp /var/tmp /var/log && \
    chmod 1777 /tmp /var/tmp

# Application expects read-only root
LABEL security.readonly-root="true"

USER 1001
```

### 2. Security Context Documentation
```dockerfile
FROM alpine:3.18

# Security requirements documentation
LABEL security.runAsNonRoot="true"
LABEL security.runAsUser="1001"
LABEL security.readOnlyRootFilesystem="true"
LABEL security.allowPrivilegeEscalation="false"
LABEL security.capabilities.drop="ALL"
LABEL security.seccompProfile="runtime/default"
```

### 3. Multi-Layer Security
```dockerfile
# syntax=docker/dockerfile:1
FROM alpine:3.18 AS base

# Security hardening base layer
RUN apk add --no-cache --update ca-certificates && \
    apk upgrade && \
    adduser -D -s /bin/sh appuser && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

FROM base AS security-scan
COPY . /src
RUN apk add --no-cache trivy && \
    trivy fs --exit-code 1 --severity HIGH,CRITICAL /src

FROM base AS production
COPY --from=security-scan /src/app /app
USER appuser
WORKDIR /app
CMD ["./app"]
```

## Security Testing

### 1. Container Security Tests
```bash
#!/bin/bash
# security-test.sh

# Test 1: Verify non-root user
docker run --rm myapp:latest id
# Should not return uid=0(root)

# Test 2: Check for sensitive files
docker run --rm myapp:latest find / -name "*.key" -o -name "*.pem" 2>/dev/null
# Should return empty

# Test 3: Verify no package managers
docker run --rm myapp:latest which apt-get yum apk 2>/dev/null
# Should return empty

# Test 4: Check exposed ports
docker inspect myapp:latest | jq '.[0].Config.ExposedPorts'
# Should only show necessary ports
```

### 2. Runtime Security Validation
```dockerfile
FROM alpine:3.18

# Add security validation script
COPY security-check.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/security-check.sh

# Run security checks
RUN security-check.sh

USER 1001
HEALTHCHECK --interval=30s --timeout=3s \
    CMD security-check.sh || exit 1
```

## Compliance and Standards

### 1. CIS Benchmark Compliance
```dockerfile
# CIS Docker Benchmark compliance
FROM alpine:3.18

# CIS 4.1: Run as non-root user
RUN adduser -D appuser
USER appuser

# CIS 4.6: Add HEALTHCHECK instruction
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8080/health || exit 1

# CIS 4.7: Do not use update instructions alone
RUN apk update && apk upgrade && apk add --no-cache curl

# CIS 4.9: Use COPY instead of ADD
COPY app.jar /app/
```

### 2. NIST Guidelines
```dockerfile
FROM alpine:3.18

# NIST SP 800-190 compliance labels
LABEL nist.ac-2="Account Management"
LABEL nist.ac-3="Access Enforcement"
LABEL nist.au-2="Audit Events"
LABEL nist.cm-2="Baseline Configuration"

# Implement principle of least privilege
RUN adduser -D -s /sbin/nologin appuser
USER appuser
```

## Security Monitoring

### 1. Runtime Security Monitoring
```dockerfile
FROM alpine:3.18

# Add monitoring capabilities
LABEL monitoring.security="enabled"
LABEL monitoring.audit="syslog"

# Security event logging
ENV SECURITY_LOG_LEVEL=INFO
ENV AUDIT_ENABLED=true

USER 1001
```

### 2. Security Metrics
```dockerfile
FROM alpine:3.18

# Expose security metrics
EXPOSE 9090
LABEL metrics.security.port="9090"
LABEL metrics.security.path="/metrics"

USER 1001
```

This comprehensive security guide covers all essential aspects of hardening Dockerfiles for production use, following industry best practices and compliance standards.
