# Dockerfile Networking and Volumes

## Table of Contents
1. [Networking Fundamentals](#networking-fundamentals)
2. [Port Management](#port-management)
3. [Volume Management](#volume-management)
4. [Network Security](#network-security)
5. [Advanced Networking](#advanced-networking)
6. [Volume Best Practices](#volume-best-practices)

## Networking Fundamentals

### EXPOSE Instruction
```dockerfile
FROM alpine:3.18

# Single port exposure
EXPOSE 80

# Multiple ports
EXPOSE 80 443

# Port with protocol
EXPOSE 80/tcp
EXPOSE 53/udp

# Port ranges
EXPOSE 8000-8010

# Document port usage
LABEL network.port.80="HTTP web server"
LABEL network.port.443="HTTPS web server"
LABEL network.port.9090="Metrics endpoint"
```

### Network Configuration
```dockerfile
FROM nginx:alpine

# Configure network settings
ENV NGINX_HOST=0.0.0.0
ENV NGINX_PORT=80

# Network security headers
COPY nginx.conf /etc/nginx/nginx.conf

# Expose ports with documentation
EXPOSE 80
EXPOSE 443

LABEL network.ingress="web-traffic"
LABEL network.protocols="http,https"
LABEL network.security="tls-required"
```

## Port Management

### 1. Web Application Ports
```dockerfile
FROM node:18-alpine

# Application server
ENV PORT=3000
EXPOSE $PORT

# Health check endpoint
ENV HEALTH_PORT=3001
EXPOSE $HEALTH_PORT

# Metrics endpoint
ENV METRICS_PORT=9090
EXPOSE $METRICS_PORT

# Admin interface
ENV ADMIN_PORT=8080
EXPOSE $ADMIN_PORT

# Document port purposes
LABEL ports.app="3000:application"
LABEL ports.health="3001:health-checks"
LABEL ports.metrics="9090:prometheus-metrics"
LABEL ports.admin="8080:admin-interface"

CMD ["npm", "start"]
```

### 2. Database Ports
```dockerfile
FROM postgres:15-alpine

# Standard PostgreSQL port
EXPOSE 5432

# Custom configuration
ENV POSTGRES_PORT=5432
ENV POSTGRES_HOST=0.0.0.0

# Network configuration
RUN echo "listen_addresses = '*'" >> /etc/postgresql/postgresql.conf
RUN echo "port = $POSTGRES_PORT" >> /etc/postgresql/postgresql.conf

LABEL network.database.port="5432"
LABEL network.database.protocol="postgresql"
```

### 3. Microservice Ports
```dockerfile
FROM openjdk:17-jre-slim

# Service port
ENV SERVER_PORT=8080
EXPOSE $SERVER_PORT

# Management port (actuator)
ENV MANAGEMENT_PORT=8081
EXPOSE $MANAGEMENT_PORT

# Debug port (development only)
ARG ENABLE_DEBUG=false
ENV DEBUG_PORT=5005
RUN if [ "$ENABLE_DEBUG" = "true" ]; then \
        echo "Exposing debug port $DEBUG_PORT"; \
    fi

LABEL service.port="8080:main-service"
LABEL service.management="8081:spring-actuator"
LABEL service.debug="5005:java-debug"
```

## Volume Management

### 1. VOLUME Instruction
```dockerfile
FROM alpine:3.18

# Create volume mount points
VOLUME ["/data"]
VOLUME ["/logs"]
VOLUME ["/config"]

# Multiple volumes in one instruction
VOLUME ["/data", "/logs", "/config"]

# Create directories for volumes
RUN mkdir -p /data /logs /config

# Set proper permissions
RUN chown -R 1001:1001 /data /logs /config
```

### 2. Application Data Volumes
```dockerfile
FROM postgres:15-alpine

# Database data volume
VOLUME ["/var/lib/postgresql/data"]

# Backup volume
VOLUME ["/backup"]

# Configuration volume
VOLUME ["/etc/postgresql/conf.d"]

# Create volume directories
RUN mkdir -p /backup /etc/postgresql/conf.d

# Set ownership
RUN chown -R postgres:postgres /backup /etc/postgresql/conf.d

LABEL volumes.data="/var/lib/postgresql/data:database-files"
LABEL volumes.backup="/backup:database-backups"
LABEL volumes.config="/etc/postgresql/conf.d:configuration-files"
```

### 3. Log and Cache Volumes
```dockerfile
FROM node:18-alpine

# Application directories
WORKDIR /app

# Log volume
VOLUME ["/app/logs"]
RUN mkdir -p /app/logs

# Cache volume
VOLUME ["/app/cache"]
RUN mkdir -p /app/cache

# Temporary files volume
VOLUME ["/tmp/app"]
RUN mkdir -p /tmp/app

# Set permissions for non-root user
RUN adduser -D appuser && \
    chown -R appuser:appuser /app/logs /app/cache /tmp/app

USER appuser

LABEL volumes.logs="/app/logs:application-logs"
LABEL volumes.cache="/app/cache:application-cache"
LABEL volumes.temp="/tmp/app:temporary-files"
```

## Network Security

### 1. Network Isolation
```dockerfile
FROM alpine:3.18

# Bind to specific interfaces
ENV BIND_ADDRESS=127.0.0.1
ENV PORT=8080

# Network security configuration
ENV NETWORK_POLICY=strict
ENV ALLOWED_HOSTS=localhost,127.0.0.1

# Security labels
LABEL network.isolation="container"
LABEL network.ingress="restricted"
LABEL network.egress="internet"

# Only expose necessary ports
EXPOSE $PORT

CMD ["./app", "--bind", "$BIND_ADDRESS:$PORT"]
```

### 2. TLS Configuration
```dockerfile
FROM nginx:alpine

# TLS certificate volumes
VOLUME ["/etc/nginx/certs"]
VOLUME ["/etc/nginx/dhparam"]

# TLS configuration
COPY tls.conf /etc/nginx/conf.d/
COPY ssl-params.conf /etc/nginx/snippets/

# Secure ports only
EXPOSE 443

# Security headers
LABEL security.tls="required"
LABEL security.protocols="TLSv1.2,TLSv1.3"
LABEL security.ciphers="ECDHE-ECDSA-AES128-GCM-SHA256"

CMD ["nginx", "-g", "daemon off;"]
```

### 3. Firewall Rules Documentation
```dockerfile
FROM alpine:3.18

# Document required network access
LABEL network.ingress.ports="80,443"
LABEL network.egress.dns="required"
LABEL network.egress.ntp="required"
LABEL network.egress.api="api.company.com:443"

# Security policies
LABEL security.firewall="strict"
LABEL security.network-policies="deny-all-default"

EXPOSE 80 443
```

## Advanced Networking

### 1. Multi-Port Applications
```dockerfile
FROM alpine:3.18

# Web server ports
EXPOSE 80 443

# API ports
EXPOSE 8080 8443

# Admin ports
EXPOSE 9090 9443

# Monitoring ports
EXPOSE 9100 9200

# Health check ports
EXPOSE 8081

# Port mapping documentation
LABEL ports.web="80:http,443:https"
LABEL ports.api="8080:api-http,8443:api-https"
LABEL ports.admin="9090:admin-http,9443:admin-https"
LABEL ports.monitoring="9100:node-exporter,9200:elasticsearch"
LABEL ports.health="8081:health-check"

# Network configuration
ENV ENABLE_TLS=true
ENV ENABLE_HTTP2=true
ENV ENABLE_COMPRESSION=true
```

### 2. Service Mesh Integration
```dockerfile
FROM alpine:3.18

# Application port
EXPOSE 8080

# Sidecar proxy ports (Istio/Envoy)
EXPOSE 15000 15001 15006 15090

# Service mesh labels
LABEL service-mesh="istio"
LABEL sidecar.istio.io/inject="true"
LABEL network.istio.proxy="enabled"

# Network policies
LABEL network.policy="service-mesh"
LABEL network.mtls="strict"

CMD ["./app"]
```

### 3. Load Balancer Configuration
```dockerfile
FROM nginx:alpine

# Load balancer ports
EXPOSE 80 443

# Health check port
EXPOSE 8080

# Stats/metrics port
EXPOSE 9090

# Load balancer configuration
COPY nginx-lb.conf /etc/nginx/nginx.conf
COPY upstream.conf /etc/nginx/conf.d/

# Health check configuration
COPY health-check.conf /etc/nginx/conf.d/

LABEL lb.algorithm="round-robin"
LABEL lb.health-check="enabled"
LABEL lb.sticky-sessions="false"

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1
```

## Volume Best Practices

### 1. Data Persistence Strategy
```dockerfile
FROM postgres:15-alpine

# Separate volumes for different data types
VOLUME ["/var/lib/postgresql/data"]    # Database files
VOLUME ["/var/lib/postgresql/backup"]  # Backup files
VOLUME ["/var/log/postgresql"]         # Log files
VOLUME ["/etc/postgresql/conf.d"]      # Configuration files

# Create volume directories with proper structure
RUN mkdir -p \
    /var/lib/postgresql/data \
    /var/lib/postgresql/backup \
    /var/log/postgresql \
    /etc/postgresql/conf.d

# Set proper ownership and permissions
RUN chown -R postgres:postgres \
    /var/lib/postgresql/data \
    /var/lib/postgresql/backup \
    /var/log/postgresql \
    /etc/postgresql/conf.d

RUN chmod 700 /var/lib/postgresql/data
RUN chmod 755 /var/lib/postgresql/backup
RUN chmod 755 /var/log/postgresql
RUN chmod 755 /etc/postgresql/conf.d

# Volume metadata
LABEL volumes.data.type="persistent"
LABEL volumes.data.backup="required"
LABEL volumes.logs.retention="30d"
LABEL volumes.config.source="configmap"
```

### 2. Application State Management
```dockerfile
FROM node:18-alpine

WORKDIR /app

# Stateless application design
# No VOLUME for application code (immutable)

# State volumes
VOLUME ["/app/uploads"]     # User uploads
VOLUME ["/app/sessions"]    # Session data
VOLUME ["/app/cache"]       # Application cache
VOLUME ["/app/logs"]        # Application logs

# Create state directories
RUN mkdir -p /app/uploads /app/sessions /app/cache /app/logs

# Non-root user for security
RUN adduser -D -s /bin/sh appuser
RUN chown -R appuser:appuser /app

USER appuser

# Volume documentation
LABEL volumes.uploads.size="10GB"
LABEL volumes.sessions.ttl="24h"
LABEL volumes.cache.ttl="1h"
LABEL volumes.logs.rotation="daily"
```

### 3. Configuration Management
```dockerfile
FROM alpine:3.18

# Configuration volumes
VOLUME ["/etc/app/config"]      # Application config
VOLUME ["/etc/app/secrets"]     # Secrets (mounted read-only)
VOLUME ["/etc/app/templates"]   # Configuration templates

# Runtime configuration directory
VOLUME ["/var/lib/app/runtime"] # Runtime-generated config

# Create configuration structure
RUN mkdir -p \
    /etc/app/config \
    /etc/app/secrets \
    /etc/app/templates \
    /var/lib/app/runtime

# Set permissions
RUN chmod 755 /etc/app/config /etc/app/templates /var/lib/app/runtime
RUN chmod 700 /etc/app/secrets

# Configuration metadata
LABEL config.format="yaml,json"
LABEL config.validation="schema"
LABEL config.hot-reload="supported"
LABEL secrets.mount="read-only"
```

## Networking and Volume Integration

### 1. Database with Network and Storage
```dockerfile
FROM postgres:15-alpine

# Network configuration
ENV POSTGRES_HOST=0.0.0.0
ENV POSTGRES_PORT=5432
EXPOSE $POSTGRES_PORT

# Storage configuration
VOLUME ["/var/lib/postgresql/data"]
VOLUME ["/var/lib/postgresql/backup"]

# Network security
ENV POSTGRES_SSL=on
ENV POSTGRES_SSL_CERT_FILE=/etc/ssl/certs/server.crt
ENV POSTGRES_SSL_KEY_FILE=/etc/ssl/private/server.key

# SSL certificate volume
VOLUME ["/etc/ssl/certs"]
VOLUME ["/etc/ssl/private"]

# Configuration
COPY postgresql.conf /etc/postgresql/
COPY pg_hba.conf /etc/postgresql/

LABEL network.security="ssl-required"
LABEL storage.encryption="at-rest"
LABEL backup.schedule="daily"
```

### 2. Web Application with Reverse Proxy
```dockerfile
FROM nginx:alpine

# Web server ports
EXPOSE 80 443

# Static content volume
VOLUME ["/usr/share/nginx/html"]

# Configuration volumes
VOLUME ["/etc/nginx/conf.d"]
VOLUME ["/etc/nginx/ssl"]

# Log volumes
VOLUME ["/var/log/nginx"]

# Cache volume
VOLUME ["/var/cache/nginx"]

# Nginx configuration
COPY nginx.conf /etc/nginx/
COPY default.conf /etc/nginx/conf.d/

# SSL configuration
COPY ssl-params.conf /etc/nginx/snippets/

# Health check
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

LABEL proxy.backend="app:8080"
LABEL ssl.protocols="TLSv1.2,TLSv1.3"
LABEL cache.enabled="true"
```

### 3. Monitoring Stack
```dockerfile
FROM prom/prometheus:latest

# Prometheus port
EXPOSE 9090

# Data volume
VOLUME ["/prometheus"]

# Configuration volume
VOLUME ["/etc/prometheus"]

# Rules volume
VOLUME ["/etc/prometheus/rules"]

# Copy default configuration
COPY prometheus.yml /etc/prometheus/
COPY alert.rules /etc/prometheus/rules/

# Network labels for service discovery
LABEL monitoring.scrape="true"
LABEL monitoring.port="9090"
LABEL monitoring.path="/metrics"

# Storage configuration
LABEL storage.retention="30d"
LABEL storage.size="10GB"

CMD ["--config.file=/etc/prometheus/prometheus.yml", \
     "--storage.tsdb.path=/prometheus", \
     "--web.console.libraries=/etc/prometheus/console_libraries", \
     "--web.console.templates=/etc/prometheus/consoles", \
     "--storage.tsdb.retention.time=30d", \
     "--web.enable-lifecycle"]
```

## Troubleshooting Network and Volume Issues

### 1. Network Debugging
```dockerfile
FROM alpine:3.18

# Install network debugging tools
RUN apk add --no-cache \
    curl \
    wget \
    netcat-openbsd \
    tcpdump \
    nmap \
    iperf3

# Network testing script
COPY network-test.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/network-test.sh

# Port testing
EXPOSE 8080
CMD ["./app"]

# Health check with network validation
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD /usr/local/bin/network-test.sh || exit 1
```

### 2. Volume Debugging
```dockerfile
FROM alpine:3.18

# Install debugging tools
RUN apk add --no-cache \
    lsof \
    strace \
    tree \
    du \
    df

# Volume test script
COPY volume-test.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/volume-test.sh

# Test volumes
VOLUME ["/data"]
VOLUME ["/logs"]

# Volume validation on startup
CMD ["/usr/local/bin/volume-test.sh", "&&", "./app"]
```

This comprehensive guide covers all aspects of networking and volume management in Dockerfiles, providing practical examples for real-world applications.
